import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class TrackingService {
  final _sharedPrefs = SharedpreferencesService();

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
            Uri.parse("https://foryou.cilassocies.com/api/conducteur/position"),
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
}
