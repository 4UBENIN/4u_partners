import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/services/location_tracking_service.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:location/location.dart' as loc;

class TrackingService {
  final _sharedPrefs = SharedpreferencesService();
  final _locationService = LocationTrackingService();

  Timer? _trackingTimer;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool _isTracking = false;

  // Headers par défaut (ajoutez votre token d'authentification si nécessaire)

  /// Vérifie et demande les permissions de géolocalisation
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de géolocalisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de géolocalisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Les permissions de géolocalisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Les permissions de géolocalisation sont refusées définitivement');
    }

    return true;
  }

  /// Obtient la position actuelle avec une adresse lisible
  static Future<Map<String, dynamic>> _getCurrentLocationWithAddress() async {
    // Obtenir la position GPS
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    // Reverse geocoding pour obtenir l'adresse
    String adresse = "Position non disponible";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        adresse = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
    } catch (e) {
      print('Erreur lors du reverse geocoding: $e');
      adresse = 'Adresse non disponible';
    }

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'adresse': adresse,
    };
  }

  /// Envoie la position actuelle du conducteur à l'API
  Future<Map<String, dynamic>> envoyerPositionActuelle() async {
    final token = await _sharedPrefs.getToken();
    print("TOKEN: $token");
    try {
      // Vérifier les permissions
      await _handleLocationPermission();

      // Obtenir la position et l'adresse
      Map<String, dynamic> locationData =
          await _getCurrentLocationWithAddress();

      print(
          'Position obtenue: ${locationData['latitude']}, ${locationData['longitude']}');
      print('Adresse: ${locationData['adresse']}');

      // Préparer les données à envoyer
      Map<String, dynamic> requestBody = {
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'adresse': locationData['adresse'],
      };

      print('Envoi de la position: $requestBody');

      // Envoyer la requête POST
      final response = await http
          .post(
            Uri.parse("$baseUrl/conducteur/position"),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      // Traiter la réponse
      if (response.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print('✅ Position envoyée avec succès: ${responseData['message']}');
        return {
          'success': true,
          'data': responseData,
          'localData': locationData,
        };
      } else if (response.statusCode == 422) {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception('Erreur de validation: ${errorData['error']}');
      } else {
        throw Exception(
            'Erreur serveur: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de la position: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Envoie périodiquement la position (tracking en continu)
  Future<void> demarrerTrackingContinu({
    Duration intervalle = const Duration(minutes: 2),
    Function(Map<String, dynamic>)? onSuccess,
    Function(String)? onError,
  }) async {
    print('🚗 Démarrage du tracking continu...');

    // Timer périodique pour envoyer la position
    Stream.periodic(intervalle).listen((_) async {
      try {
        Map<String, dynamic> result = await envoyerPositionActuelle();

        if (result['success']) {
          onSuccess?.call(result);
        } else {
          onError?.call(result['error']);
        }
      } catch (e) {
        onError?.call(e.toString());
      }
    });
  }

  /// NEW: Send position update using LocationTrackingService (continuous tracking)
  /// This uses the unified location service and sends updates to /conducteur/position
  Future<bool> sendPositionUpdate({
    required double latitude,
    required double longitude,
    String? adresse,
  }) async {
    try {
      final token = await _sharedPrefs.getToken();

      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'adresse': adresse ?? 'Position en cours...',
      };

      debugPrint('🗺️ [General Position] ========== SENDING POSITION UPDATE ==========');
      debugPrint('🗺️ [General Position] URL: $baseUrl/conducteur/position');
      debugPrint('🗺️ [General Position] Latitude: $latitude');
      debugPrint('🗺️ [General Position] Longitude: $longitude');
      debugPrint('🗺️ [General Position] Adresse: ${body['adresse']}');
      debugPrint('🗺️ [General Position] Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/conducteur/position'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('🗺️ [General Position] Response status: ${response.statusCode}');
      debugPrint('🗺️ [General Position] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          debugPrint('✅ [General Position] Success! Message: ${responseData['message']}');
          if (responseData['position'] != null) {
            final pos = responseData['position'];
            debugPrint('✅ [General Position] Saved position:');
            debugPrint('   - ID: ${pos['id']}');
            debugPrint('   - Latitude: ${pos['latitude']}');
            debugPrint('   - Longitude: ${pos['longitude']}');
            debugPrint('   - Adresse: ${pos['adresse']}');
            debugPrint('   - En service: ${pos['en_service']}');
          }
        } catch (e) {
          debugPrint('✅ [General Position] Response is not JSON: ${response.body}');
        }
        return true;
      } else if (response.statusCode == 422) {
        try {
          final errorData = jsonDecode(response.body);
          debugPrint('❌ [General Position] Validation error: ${errorData['error']}');
        } catch (e) {
          debugPrint('❌ [General Position] Error response: ${response.body}');
        }
        return false;
      } else {
        debugPrint('❌ [General Position] Failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [General Position] Exception: $e');
      return false;
    }
  }

  /// Start continuous general position tracking using LocationTrackingService
  /// This will send driver's position to /conducteur/position every [interval]
  Future<void> startContinuousTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {
    try {
      if (_isTracking) {
        debugPrint('⚠️ [General Position Tracking] Already tracking');
        return;
      }

      debugPrint('🎯 [General Position Tracking] ========== STARTING CONTINUOUS TRACKING ==========');
      debugPrint('🎯 [General Position Tracking] Interval: ${interval.inSeconds} seconds');

      // Ensure LocationTrackingService is initialized and tracking
      debugPrint('🎯 [General Position Tracking] Checking LocationTrackingService status...');
      debugPrint('🎯 [General Position Tracking] isTracking: ${_locationService.isTracking}');

      if (!_locationService.isTracking) {
        debugPrint('🎯 [General Position Tracking] Starting LocationTrackingService...');
        try {
          await _locationService.initialize();
          debugPrint('✅ [General Position Tracking] LocationTrackingService initialized');
          await _locationService.startTracking();
          debugPrint('✅ [General Position Tracking] LocationTrackingService started');
        } catch (e) {
          debugPrint('❌ [General Position Tracking] Failed to start LocationTrackingService: $e');
          throw e;
        }
      } else {
        debugPrint('✅ [General Position Tracking] LocationTrackingService already running');
      }

      _isTracking = true;

      // Send initial position immediately if available
      final currentLocation = _locationService.currentLocation;
      debugPrint('🎯 [General Position Tracking] Current location: ${currentLocation?.latitude}, ${currentLocation?.longitude}');

      if (currentLocation != null &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        debugPrint('🎯 [General Position Tracking] Sending initial position immediately...');
        await _sendPositionWithAddress(currentLocation);
        debugPrint('✅ [General Position Tracking] Initial position sent');
      } else {
        debugPrint('⚠️ [General Position Tracking] No initial location available yet');
        debugPrint('⚠️ [General Position Tracking] Will send on first timer tick');
      }

      // Set up periodic timer to send position
      debugPrint('🎯 [General Position Tracking] Setting up timer (${interval.inSeconds}s)...');
      _trackingTimer = Timer.periodic(interval, (timer) async {
        debugPrint('⏰ [General Position Tracking] ========== TIMER TICK ==========');
        debugPrint('⏰ [General Position Tracking] Timer iteration: ${timer.tick}');

        final location = _locationService.currentLocation;
        debugPrint('⏰ [General Position Tracking] Location: ${location?.latitude}, ${location?.longitude}');

        if (location != null &&
            location.latitude != null &&
            location.longitude != null) {
          debugPrint('⏰ [General Position Tracking] Sending position update...');
          await _sendPositionWithAddress(location);
          debugPrint('✅ [General Position Tracking] Position update complete');
        } else {
          debugPrint('⚠️ [General Position Tracking] No location available, skipping update');
          debugPrint('⚠️ [General Position Tracking] Location object: $location');
        }
      });

      debugPrint('✅ [General Position Tracking] ========== TRACKING STARTED ==========');
      debugPrint('✅ [General Position Tracking] Timer is active: ${_trackingTimer?.isActive}');
      debugPrint('✅ [General Position Tracking] Next update in ${interval.inSeconds} seconds');
    } catch (e, stackTrace) {
      debugPrint('❌ [General Position Tracking] FAILED TO START: $e');
      debugPrint('❌ [General Position Tracking] Stack trace: $stackTrace');
      _isTracking = false;
      rethrow;
    }
  }

  /// Stop continuous general position tracking
  Future<void> stopContinuousTracking() async {
    if (!_isTracking) {
      debugPrint('ℹ️ [General Position Tracking] Not currently tracking');
      return;
    }

    debugPrint('🛑 [General Position Tracking] Stopping continuous tracking...');

    _trackingTimer?.cancel();
    _trackingTimer = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;

    debugPrint('✅ [General Position Tracking] Tracking stopped');
  }

  /// Helper method to send position with reverse geocoded address
  Future<void> _sendPositionWithAddress(loc.LocationData location) async {
    try {
      debugPrint('📤 [_sendPositionWithAddress] ========== PREPARING TO SEND ==========');
      debugPrint('📤 [_sendPositionWithAddress] Latitude: ${location.latitude}');
      debugPrint('📤 [_sendPositionWithAddress] Longitude: ${location.longitude}');

      // Get address via reverse geocoding
      String adresse = 'Position en cours...';
      debugPrint('📍 [_sendPositionWithAddress] Starting reverse geocoding...');

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude!,
          location.longitude!,
        );

        debugPrint('📍 [_sendPositionWithAddress] Placemarks found: ${placemarks.length}');

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          adresse = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          debugPrint('✅ [_sendPositionWithAddress] Reverse geocoded: $adresse');
        } else {
          debugPrint('⚠️ [_sendPositionWithAddress] No placemarks returned');
        }
      } catch (e) {
        debugPrint('⚠️ [_sendPositionWithAddress] Reverse geocoding failed: $e');
        debugPrint('⚠️ [_sendPositionWithAddress] Will use default address');
      }

      // Send position update
      debugPrint('📤 [_sendPositionWithAddress] Calling sendPositionUpdate API...');
      final success = await sendPositionUpdate(
        latitude: location.latitude!,
        longitude: location.longitude!,
        adresse: adresse,
      );

      if (success) {
        debugPrint('✅ [_sendPositionWithAddress] Position sent successfully!');
      } else {
        debugPrint('❌ [_sendPositionWithAddress] Position send FAILED');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [_sendPositionWithAddress] Error sending position: $e');
      debugPrint('❌ [_sendPositionWithAddress] Stack trace: $stackTrace');
    }
  }

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Dispose resources
  void dispose() {
    stopContinuousTracking();
  }
}
