import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/services/marker_icon_service.dart';
import 'package:for_u_partners/ui/views/drivers/courses/functions_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iconsax/iconsax.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:for_u_partners/app/core/constants.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

// AppColors class with logo property
class AppColors {
  static const Color logo = primaryColor;
}

class PickUpPage extends StatefulWidget {
  const PickUpPage({super.key});

  @override
  State<PickUpPage> createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> with TickerProviderStateMixin {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _departFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();

  bool isFocus1 = false;
  bool isFocus2 = false;
  bool isCurrentLocationVisible = true;
  bool isLoadingCurrentLocation = false;

  double? departLat;
  double? departLng;
  double? arriveeLat;
  double? arriveeLng;

  List<Map<String, String>> addressSuggestions = [];
  bool isLoadingAddresses = false;
  Timer? _debounceTimer;
  String _lastSearchQuery = "";

  final FunctionsService _functionsService = FunctionsService();
  final _driverService = locator<DriverService>();
  final _navigationService = locator<NavigationService>();
  final _restorationService = locator<CourseRestorationService>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Pickup course state
  bool _isCreatingCourse = false;
  int? _createdCourseId;

  // Google Maps
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(6.3703, 2.3912); // Centre Bénin
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = PolylinePoints(apiKey: AppConstants.googleApiKey);
  
  // Informations sur le trajet
  String? _distance;
  String? _duration;
  double? _price; // Prix de la course
  bool _isCalculatingRoute = false;

  bool get _canContinue =>
      _departController.text.isNotEmpty &&
      _destinationController.text.isNotEmpty &&
      departLat != null &&
      arriveeLat != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupFocusListeners();
    _setupTextListeners();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _setupFocusListeners() {
    _departFocus.addListener(() {
      setState(() => isFocus1 = _departFocus.hasFocus);
    });
    _destinationFocus.addListener(() {
      setState(() => isFocus2 = _destinationFocus.hasFocus);
    });
  }

  void _setupTextListeners() {
    _departController.addListener(() => _handleTextChange(_departController.text));
    _destinationController.addListener(() => _handleTextChange(_destinationController.text));
  }

  void _handleTextChange(String text) {
    if (text.isEmpty || text == "Position actuelle" || text == _lastSearchQuery) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if ((isFocus1 || isFocus2) && text.isNotEmpty && text != "Position actuelle") {
        _lastSearchQuery = text;
        _searchAddresses(text);
      }
    });
  }

  Future<void> _searchAddresses(String query) async {
    if (query.length < 2) return;
    setState(() => isLoadingAddresses = true);

    try {
      final suggestions = await _functionsService.getAddressSuggestions(query);
      setState(() {
        addressSuggestions = suggestions;
        isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAddresses = false;
        addressSuggestions = [];
      });
    }
  }

  void _onAddressSelected(Map<String, String> suggestion) async {
    final wasFocus1 = isFocus1;
    final wasFocus2 = isFocus2;

    setState(() {
      if (wasFocus1) {
        _departController.text = suggestion['description']!;
        _departFocus.unfocus();
      } else if (wasFocus2) {
        _destinationController.text = suggestion['description']!;
        _destinationFocus.unfocus();
      }
      addressSuggestions.clear();
    });

    _lastSearchQuery = suggestion['description']!;

    // 🎯 Récupérer les coordonnées via l'API
    final placeId = suggestion['place_id'];
    if (placeId != null && placeId.isNotEmpty) {
      try {
        print('🔍 Récupération des coordonnées pour: $placeId');
        final details = await _functionsService.getPlaceDetails(placeId);
        
        if (details.isNotEmpty) {
          final lat = details['latitude'] as double?;
          final lng = details['longitude'] as double?;

          if (lat != null && lng != null) {
            // Load custom markers
            final pickupIcon = await MarkerIconService.getPickupMarker();
            final destinationIcon = await MarkerIconService.getDestinationMarker();

            setState(() {
              if (wasFocus1) {
                departLat = lat;
                departLng = lng;
                _markers.removeWhere((m) => m.markerId.value == 'depart');
                _markers.add(Marker(
                    markerId: const MarkerId('depart'),
                    position: LatLng(lat, lng),
                    icon: pickupIcon,
                    infoWindow: InfoWindow(
                      title: '📍 Départ',
                      snippet: _departController.text,
                    )));
                print('✅ Départ: $lat, $lng');
              } else if (wasFocus2) {
                arriveeLat = lat;
                arriveeLng = lng;
                _markers.removeWhere((m) => m.markerId.value == 'arrivee');
                _markers.add(Marker(
                    markerId: const MarkerId('arrivee'),
                    position: LatLng(lat, lng),
                    icon: destinationIcon,
                    infoWindow: InfoWindow(
                      title: '🎯 Destination',
                      snippet: _destinationController.text,
                    )));
                print('✅ Arrivée: $lat, $lng');
              }
              _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
            });
            
            // 🗺️ Si les deux points sont définis, calculer distance et durée
            if (departLat != null && departLng != null && arriveeLat != null && arriveeLng != null) {
              _calculateDistanceAndDurationOnly();
            }
          }
        }
      } catch (e) {
        print('❌ Erreur récupération coordonnées: $e');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    // Prevent multiple simultaneous calls
    if (isLoadingCurrentLocation) {
      debugPrint('⚠️ [PickUpPage] Location request already in progress');
      return;
    }

    setState(() => isLoadingCurrentLocation = true);

    try {
      debugPrint('📍 [PickUpPage] Starting location request...');

      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ [PickUpPage] Location services disabled');
        if (mounted) {
          _showLocationServiceDialog();
        }
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 [PickUpPage] Current permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📍 [PickUpPage] Requesting location permission...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          debugPrint('❌ [PickUpPage] Location permission denied');
          if (mounted) {
            _showPermissionDeniedMessage();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ [PickUpPage] Location permission permanently denied');
        if (mounted) {
          _showPermissionPermanentlyDeniedDialog();
        }
        return;
      }

      debugPrint('✅ [PickUpPage] Permission granted, getting location...');

      // 3. Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      debugPrint('✅ [PickUpPage] Location obtained: ${position.latitude}, ${position.longitude}');

      // 4. Reverse geocode to get address
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('⚠️ [PickUpPage] Geocoding failed: $e (using coordinates only)');
      }

      String address = 'Position actuelle';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = [
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
        ];
        address = addressParts.isNotEmpty ? addressParts.join(', ') : 'Position actuelle';
      }

      debugPrint('✅ [PickUpPage] Address: $address');

      // 5. Load custom pickup marker
      final pickupIcon = await MarkerIconService.getPickupMarker();

      // 6. Update UI
      if (mounted) {
        setState(() {
          isCurrentLocationVisible = false;
          _departController.text = address;
          departLat = position.latitude;
          departLng = position.longitude;
          _markers.removeWhere((m) => m.markerId.value == 'depart');
          _markers.add(Marker(
            markerId: const MarkerId('depart'),
            position: LatLng(departLat!, departLng!),
            icon: pickupIcon,
            infoWindow: InfoWindow(
              title: '📍 Départ (Position actuelle)',
              snippet: _departController.text,
            ),
          ));
        });

        // Animate camera to new position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(departLat!, departLng!), 15),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Position actuelle obtenue avec succès'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Calculate route if destination is set
        if (arriveeLat != null && arriveeLng != null) {
          _calculateDistanceAndDurationOnly();
        }
      }

      debugPrint('✅ [PickUpPage] Location set successfully');
    } on TimeoutException catch (e) {
      debugPrint('❌ [PickUpPage] Location timeout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Impossible d\'obtenir votre position. Vérifiez que vous êtes à l\'extérieur ou près d\'une fenêtre.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [PickUpPage] Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Erreur lors de la récupération de la position: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingCurrentLocation = false);
      }
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Services de localisation désactivés'),
          ],
        ),
        content: const Text(
          'Veuillez activer les services de localisation dans les paramètres de votre appareil pour utiliser cette fonctionnalité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_off, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Permission de localisation refusée. Activez-la pour utiliser cette fonctionnalité.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('Permission refusée')),
          ],
        ),
        content: const Text(
          'La permission de localisation a été définitivement refusée. Veuillez l\'activer manuellement dans les paramètres de l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logo,
            ),
            child: const Text('Ouvrir les paramètres'),
          ),
        ],
      ),
    );
  }

  // 📏 Calculer uniquement distance et durée (sans tracer) - utilise l'API d'estimation
  Future<void> _calculateDistanceAndDurationOnly() async {
    // Appeler la méthode principale qui utilise maintenant l'API
    await _calculateDistanceAndDuration();
  }

  // 🗺️ Tracer l'itinéraire entre départ et destination (NON UTILISÉ)
  Future<void> _drawRoute() async {
    if (departLat == null || departLng == null || arriveeLat == null || arriveeLng == null) {
      return;
    }

    setState(() => _isCalculatingRoute = true);
    print('🗺️ Calcul de l\'itinéraire...');
    
    bool useDirectionsAPI = false; // Mettre à true quand l'API Directions est activée
    
    try {
      // Réinitialiser les polylines
      _polylineCoordinates.clear();
      
      // OPTION 1: Essayer d'utiliser l'API Google Directions (nécessite facturation)
        // OPTION 2: Ligne droite simple (par défaut)
        _polylineCoordinates = [
          LatLng(departLat!, departLng!),
          LatLng(arriveeLat!, arriveeLng!),
        ];

      // Calculer la distance et la durée
      _calculateDistanceAndDuration();

      // Créer la polyline
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.logo,
            width: 5,
            points: _polylineCoordinates,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
      });

      // Ajuster la caméra pour afficher tout l'itinéraire
      _fitMapToRoute();
      
      print('✅ Itinéraire tracé avec ${_polylineCoordinates.length} points');
      print('📏 Distance: $_distance | ⏱️ Durée: $_duration');
    } catch (e) {
      print('❌ Erreur lors du tracé de l\'itinéraire: $e');
    } finally {
      setState(() => _isCalculatingRoute = false);
    }
  }

  // 📏 Calculer la distance et la durée estimée via l'API
  Future<void> _calculateDistanceAndDuration() async {
    if (departLat == null || departLng == null || arriveeLat == null || arriveeLng == null) {
      debugPrint('❌ [PickUpPage] Missing coordinates for estimation');
      return;
    }

    try {
      debugPrint('⚡ [PickUpPage] Calling estimation API...');

      // Calculer une durée estimée simple pour l'API
      double totalDistance = 0.0;
      if (_polylineCoordinates.length >= 2) {
        for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
          totalDistance += Geolocator.distanceBetween(
            _polylineCoordinates[i].latitude,
            _polylineCoordinates[i].longitude,
            _polylineCoordinates[i + 1].latitude,
            _polylineCoordinates[i + 1].longitude,
          );
        }
      } else {
        totalDistance = Geolocator.distanceBetween(
          departLat!,
          departLng!,
          arriveeLat!,
          arriveeLng!,
        );
      }

      double distanceInKm = totalDistance / 1000;
      double adjustedDistance = _polylineCoordinates.length == 2 ? distanceInKm * 1.3 : distanceInKm;
      int durationInMinutes = ((adjustedDistance / 30) * 60).toInt();

      // Appeler l'API d'estimation
      final estimationData = await _driverService.estimatePickupCourse(
        typeCourse: 'distance', // ou 'temps' selon le type de course
        departLat: departLat!,
        departLng: departLng!,
        arriveeLat: arriveeLat!,
        arriveeLng: arriveeLng!,
        dureeMin: durationInMinutes,
        adresseDepart: _departController.text,
        adresseArrivee: _destinationController.text,
      );

      debugPrint('✅ [PickUpPage] Estimation API response: $estimationData');

      // Extraire les données de la réponse avec conversion de type sécurisée
      final dynamic montantValue = estimationData['montant'] ?? 0;
      final double montant = montantValue is int ? montantValue.toDouble() : (montantValue as num).toDouble();

      final dynamic distanceValue = estimationData['distance_km'] ?? distanceInKm;
      final double distanceKm = distanceValue is int ? distanceValue.toDouble() : (distanceValue as num).toDouble();

      final dynamic dureeValue = estimationData['duree_estimee'] ?? durationInMinutes;
      final int dureeEstimee = dureeValue is int ? dureeValue : (dureeValue as num).toInt();

      setState(() {
        // Utiliser les valeurs de l'API
        _distance = distanceKm < 1
            ? '${(distanceKm * 1000).toStringAsFixed(0)} m'
            : '${distanceKm.toStringAsFixed(1)} km';

        if (dureeEstimee < 60) {
          _duration = '$dureeEstimee min';
        } else {
          int hours = (dureeEstimee / 60).floor();
          int minutes = dureeEstimee % 60;
          _duration = '${hours}h ${minutes}min';
        }

        _price = montant;
      });
    } catch (e) {
      debugPrint('❌ [PickUpPage] Erreur lors de l\'estimation: $e');

      // Fallback: calculer localement en cas d'erreur API
      double totalDistance = 0.0;
      if (_polylineCoordinates.length >= 2) {
        for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
          totalDistance += Geolocator.distanceBetween(
            _polylineCoordinates[i].latitude,
            _polylineCoordinates[i].longitude,
            _polylineCoordinates[i + 1].latitude,
            _polylineCoordinates[i + 1].longitude,
          );
        }
      } else {
        totalDistance = Geolocator.distanceBetween(
          departLat!,
          departLng!,
          arriveeLat!,
          arriveeLng!,
        );
      }

      double distanceInKm = totalDistance / 1000;
      double adjustedDistance = _polylineCoordinates.length == 2 ? distanceInKm * 1.3 : distanceInKm;
      double durationInMinutes = (adjustedDistance / 30) * 60;
      double baseFare = 500;
      double pricePerKm = 300;
      double calculatedPrice = baseFare + (adjustedDistance * pricePerKm);

      setState(() {
        _distance = distanceInKm < 1
            ? '${(distanceInKm * 1000).toStringAsFixed(0)} m'
            : '${distanceInKm.toStringAsFixed(1)} km';

        if (durationInMinutes < 60) {
          _duration = '${durationInMinutes.toStringAsFixed(0)} min';
        } else {
          int hours = (durationInMinutes / 60).floor();
          int minutes = (durationInMinutes % 60).toInt();
          _duration = '${hours}h ${minutes}min';
        }

        _price = calculatedPrice;
      });
    }
  }

  // 📍 Ajuster la caméra pour afficher tout l'itinéraire
  void _fitMapToRoute() {
    if (_polylineCoordinates.isEmpty || _mapController == null) return;

    double minLat = _polylineCoordinates.first.latitude;
    double maxLat = _polylineCoordinates.first.latitude;
    double minLng = _polylineCoordinates.first.longitude;
    double maxLng = _polylineCoordinates.first.longitude;

    for (var coord in _polylineCoordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  // 🚀 Create and start pickup course
  Future<void> _createAndStartPickupCourse() async {
    if (_isCreatingCourse) {
      print('⚠️ [PickUpPage] Already creating a course, skipping...');
      return;
    }

    setState(() => _isCreatingCourse = true);

    try {
      print('🚀 [PickUpPage] Creating pickup course...');

      // Create the pickup course
      final courseData = await _driverService.createPickupCourse(
        typeCourse: 'distance',
        departLat: departLat!,
        departLng: departLng!,
        arriveeLat: arriveeLat!,
        arriveeLng: arriveeLng!,
        adresseDepart: _departController.text,
        adresseArrivee: _destinationController.text,
        modePaiement: 'especes', // Cash payment
      );

      _createdCourseId = courseData['course_id'];
      print('✅ [PickUpPage] Course created - ID: $_createdCourseId');
      print('📊 [PickUpPage] Estimated amount: ${courseData['estimation_montant']} FCFA');

      // Start the pickup course immediately
      print('🏁 [PickUpPage] Starting pickup course $_createdCourseId...');
      final startResponse = await _driverService.startPickupCourse(_createdCourseId!);
      print('✅ [PickUpPage] Course started successfully');
      print('📦 [PickUpPage] Start response: $startResponse');

      if (mounted) {
        // Close the dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course démarrée avec succès! ID: $_createdCourseId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // 🔥 Set the pickup course for restoration so the bottom sheet appears
        if (startResponse != null && startResponse['course'] != null) {
          print('🚀 [PickUpPage] Setting pending restoration for pickup course');
          _restorationService.setPendingRestoration(startResponse['course']);
        }

        // Navigate to homemain view which will trigger the restoration
        _navigationService.clearStackAndShow(Routes.homemainView);
      }
    } catch (e) {
      print('❌ [PickUpPage] Error creating/starting course: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingCourse = false);
      }
    }
  }

  // 🔥 Afficher la popup avec les détails du trajet
  void _showTripDetailsDialog() {
    print('🔔 [PickUpPage] _showTripDetailsDialog() called');
    print('📊 [PickUpPage] Trip details - Distance: $_distance, Duration: $_duration, Price: $_price FCFA');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Permet la fermeture en glissant vers le bas
      enableDrag: true, // Permet le glissement
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de fermeture
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre avec bouton de fermeture
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Détails de la course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    color: Colors.grey[600],
                    tooltip: 'Fermer',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Détails du trajet
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Départ
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Départ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _departController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Ligne de séparation
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 9),
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrivée
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _destinationController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Informations distance et durée
              if (_distance != null || _duration != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.logo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.logo.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_distance != null)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.logo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.straighten,
                                color: AppColors.logo,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _distance!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Distance',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      if (_duration != null)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.logo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: AppColors.logo,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _duration!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Durée estimée',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
              
              // 💰 Prix de la course
              if (_price != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.logo.withOpacity(0.1),
                        AppColors.logo.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.logo.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: AppColors.logo,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Montant de la course',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Prix estimé',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${_price!.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.logo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Bouton démarrer la course
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreatingCourse
                      ? null
                      : () async {
                          print('🚀 [PickUpPage] Button "Démarrer la course" CLICKED');
                          print('📍 [PickUpPage] Departure: ${_departController.text}');
                          print('📍 [PickUpPage] Departure Coords: ($departLat, $departLng)');
                          print('🎯 [PickUpPage] Destination: ${_destinationController.text}');
                          print('🎯 [PickUpPage] Destination Coords: ($arriveeLat, $arriveeLng)');
                          print('💰 [PickUpPage] Price: $_price FCFA');
                          print('📏 [PickUpPage] Distance: $_distance');
                          print('⏱️ [PickUpPage] Duration: $_duration');

                          await _createAndStartPickupCourse();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCreatingCourse ? Colors.grey : AppColors.logo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCreatingCourse
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Création en cours...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Démarrer la course',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _departController.dispose();
    _destinationController.dispose();
    _departFocus.dispose();
    _destinationFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Démarrer une course',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Carte Google Maps - Compacte quand clavier est ouvert
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: isKeyboardVisible ? 180 : 280,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialPosition, zoom: 12),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                ),
              ),

              // Content area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Handle bar (Apple style)
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input fields card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Departure field
                            _buildInputField(
                              controller: _departController,
                              focusNode: _departFocus,
                              hint: 'Point de départ',
                              icon: Icons.circle_outlined,
                              iconColor: Colors.green,
                            ),

                            // Separator
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 2,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Destination field
                            _buildInputField(
                              controller: _destinationController,
                              focusNode: _destinationFocus,
                              hint: 'Destination',
                              icon: Iconsax.location,
                              iconColor: AppColors.logo,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Position actuelle button
                      if (isCurrentLocationVisible && !isKeyboardVisible)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (isLoadingAddresses || isLoadingCurrentLocation)
                                  ? null
                                  : _getCurrentLocation,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.logo.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.logo.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLoadingCurrentLocation)
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.logo,
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.my_location_rounded,
                                        color: AppColors.logo,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isLoadingCurrentLocation
                                          ? 'Localisation...'
                                          : 'Utiliser ma position actuelle',
                                      style: TextStyle(
                                        color: AppColors.logo,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // Bottom button - Fixed at bottom
              if (!isKeyboardVisible)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _showTripDetailsDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canContinue ? AppColors.logo : Colors.grey[300],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Continuer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: _canContinue ? Colors.white : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Suggestions overlay - Always above keyboard
          if ((isFocus1 || isFocus2) && (isLoadingAddresses || addressSuggestions.isNotEmpty))
            _buildSuggestionsOverlay(context, keyboardHeight),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              cursorColor: AppColors.logo,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  controller.clear();
                  if (focusNode == _departFocus) {
                    departLat = null;
                    departLng = null;
                    _markers.removeWhere((m) => m.markerId.value == 'depart');
                  } else {
                    arriveeLat = null;
                    arriveeLng = null;
                    _markers.removeWhere((m) => m.markerId.value == 'arrivee');
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.cancel,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Suggestions overlay - Apple Maps style, always above keyboard
  Widget _buildSuggestionsOverlay(BuildContext context, double keyboardHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final mapHeight = keyboardHeight > 0 ? 180.0 : 280.0;

    // Calculate available space above keyboard
    final availableHeight = screenHeight - appBarHeight - mapHeight - keyboardHeight - 100;
    final maxHeight = availableHeight.clamp(200.0, 450.0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: keyboardHeight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: maxHeight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header - Fixed height
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.logo,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isFocus1 ? "Point de départ" : "Destination",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => addressSuggestions.clear());
                          (isFocus1 ? _departFocus : _destinationFocus).unfocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content - Expanded to fill remaining space
                Expanded(
                  child: _buildSuggestionsContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsContent() {
    if (isLoadingAddresses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.logo),
            ),
            const SizedBox(height: 16),
            Text(
              'Recherche en cours...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (addressSuggestions.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: addressSuggestions.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey[200],
          ),
        ),
        itemBuilder: (context, index) =>
            _buildSuggestionItem(addressSuggestions[index]),
      );
    }

    // No results
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, String> suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onAddressSelected(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.logo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.logo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion['description']!.split(',').first,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (suggestion['description']!.contains(','))
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          suggestion['description']!.split(',').skip(1).join(',').trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}