// vehicle_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:for_u_partners/models/vehicle_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';

class VehicleService {
  final Dio _dio = Dio();
  static String get _baseUrl => baseUrl.replaceAll('/api', '');
  
  // 🔥 UTILISER LE MÊME SERVICE QUE AUTH_SERVICE
  final _sharedPreferencesServices = locator<SharedpreferencesService>();

  VehicleService() {
    // Ajouter un interceptor pour logger
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('===== REQUEST =====');
          print('URL: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('===== RESPONSE =====');
          print('Status: ${response.statusCode}');
          print('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('===== ERROR =====');
          print('Status: ${error.response?.statusCode}');
          print('Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  // 🆕 Méthode de debug pour vérifier le token
  Future<void> debugCheckToken() async {
    try {
      final token = await _sharedPreferencesServices.getToken();
      
      print('═══════════════════════════════════');
      print('🔍 DEBUG TOKEN VERIFICATION');
      print('═══════════════════════════════════');
      print('Token présent: ${token != null}');
      print('Token non vide: ${token?.isNotEmpty ?? false}');
      if (token != null) {
        // Nettoyer le token des guillemets si présents
        final cleanToken = token.replaceAll('"', '').trim();
        print('Token (premiers 20 char): ${cleanToken.length > 20 ? cleanToken.substring(0, 20) : cleanToken}...');
        print('Token length: ${cleanToken.length}');
      }
      print('═══════════════════════════════════');
    } catch (e) {
      print('❌ Erreur lors du debug du token: $e');
    }
  }

  // 🔥 Récupération du token d'authentification (CORRIGÉ)
  Future<String?> _getAuthToken() async {
    try {
      final token = await _sharedPreferencesServices.getToken();

      if (token == null || token.isEmpty) {
        print('❌ Aucun token trouvé');
        return null;
      }

      // Nettoyer le token des guillemets si présents
      final cleanToken = token.replaceAll('"', '').trim();
      
      if (cleanToken.isEmpty) {
        print('❌ Token vide après nettoyage');
        return null;
      }

      print('🔑 Token récupéré avec succès (${cleanToken.length} caractères)');
      return cleanToken;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Vérifie la présence du token avant d'appeler une API
  Future<bool> _isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Ajouter un nouveau véhicule avec documents
  Future<Vehicle?> addVehicleWithDocuments({
    required String marque,
    required String modele,
    required String immatriculation,
    required String couleur,
    required String annee,
    required String type, 
    required int nombrePlaces, 
    String categorie = 'standard',
    File? carteGrise,
    File? assurance,
    File? permis,
  }) async {
    try {
      // 🆕 Debug du token avant l'appel API
      await debugCheckToken();
      
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      }

      // Créer FormData pour upload avec fichiers
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('type', type), 
        MapEntry('marque', marque),
        MapEntry('modele', modele),
        MapEntry('immatriculation', immatriculation),
        MapEntry('couleur', couleur),
        MapEntry('categorie', categorie),
        MapEntry('nombre_places', nombrePlaces.toString()), 
        const MapEntry('statut', 'en_attente'),
        MapEntry('annee', annee),
      ]);

      if (carteGrise != null) {
        formData.files.add(MapEntry(
          'carte_grise',
          await MultipartFile.fromFile(carteGrise.path),
        ));
      }

      if (assurance != null) {
        formData.files.add(MapEntry(
          'assurance',
          await MultipartFile.fromFile(assurance.path),
        ));
      }

      if (permis != null) {
        formData.files.add(MapEntry(
          'permis_conduire',
          await MultipartFile.fromFile(permis.path),
        ));
      }

      print('📤 Envoi de la requête pour ajouter le véhicule...');
      
      final response = await _dio
          .post(
            '$_baseUrl/api/conducteur/vehicule',
            data: formData,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Véhicule ajouté avec succès');
        
        final vehicleData = response.data['vehicule'] ??
            response.data['data'] ??
            response.data;

        return Vehicle(
          id: vehicleData['id']?.toString() ?? '',
          model: vehicleData['modele']?.toString() ?? modele,
          marque: vehicleData['marque']?.toString() ?? marque,
          immatriculation:
              vehicleData['immatriculation']?.toString() ?? immatriculation,
          statut: vehicleData['statut']?.toString() ?? 'en_attente',
          categorie: vehicleData['categorie']?.toString() ?? categorie,
          couleur: vehicleData['couleur']?.toString() ?? couleur,
          courseHeure:
              vehicleData['course_heure'] == true || vehicleData['course_heure'] == 1,
          clim: vehicleData['clim'] == true || vehicleData['clim'] == 1,
          basic: vehicleData['basic'] == true || vehicleData['basic'] == 1,
          premium: vehicleData['premium'] == true || vehicleData['premium'] == 1,
        );
      }

      throw Exception('Erreur ${response.statusCode}');
    } catch (e, stack) {
      print('❌ Erreur lors de l\'ajout du véhicule: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      rethrow;
    }
  }

  // Ajouter un nouveau véhicule (sans documents)
  Future<Vehicle?> addVehicle({
    required String marque,
    required String modele,
    required String immatriculation,
    required String type, 
    required int nombrePlaces, 
    String categorie = 'standard',
    String? couleur,
    bool courseHeure = false,
    bool clim = false,
    bool basic = false,
    bool premium = false,
  }) async {
    try {
      // 🆕 Debug du token avant l'appel API
      await debugCheckToken();
      
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      }

      print('📤 Envoi de la requête pour ajouter le véhicule...');

      final response = await _dio.post(
        '$_baseUrl/api/conducteur/vehicule',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {
          'type': type, 
          'marque': marque,
          'modele': modele,
          'immatriculation': immatriculation,
          'categorie': categorie,
          'nombre_places': nombrePlaces, 
          'couleur': couleur ?? 'Noire',
          'course_heure': courseHeure,
          'clim': clim,
          'basic': basic,
          'premium': premium,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Véhicule ajouté avec succès');
        
        final vehicleData = response.data['vehicule'] ??
            response.data['data'] ??
            response.data;

        return Vehicle(
          id: vehicleData['id']?.toString() ?? '',
          model: vehicleData['modele']?.toString() ?? modele,
          marque: vehicleData['marque']?.toString() ?? marque,
          immatriculation:
              vehicleData['immatriculation']?.toString() ?? immatriculation,
          statut: vehicleData['statut']?.toString() ?? 'en_attente',
          categorie: vehicleData['categorie']?.toString() ?? categorie,
          couleur: vehicleData['couleur']?.toString() ?? couleur ?? 'Noire',
          courseHeure:
              vehicleData['course_heure'] == true || vehicleData['course_heure'] == 1,
          clim: vehicleData['clim'] == true || vehicleData['clim'] == 1,
          basic: vehicleData['basic'] == true || vehicleData['basic'] == 1,
          premium: vehicleData['premium'] == true || vehicleData['premium'] == 1,
        );
      }

      throw Exception('Erreur ${response.statusCode}');
    } catch (e, stack) {
      print('❌ Erreur lors de l\'ajout du véhicule: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      rethrow;
    }
  }
// 🆕 Changer la catégorie d'un véhicule
Future<bool> changerCategorie({
  required String vehiculeId,
  required String nouvelleCategorie,
}) async {
  try {
    final token = await _getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Utilisateur non authentifié.');
    }

    print('📤 Changement de catégorie du véhicule $vehiculeId vers $nouvelleCategorie...');

    final response = await _dio.post(
      '$_baseUrl/api/conducteur/changer-categorie',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
      data: {
        'vehicule_id': vehiculeId,
        'nouvelle_categorie': nouvelleCategorie,
      },
    );

    if (response.statusCode == 200) {
      print('✅ Catégorie changée avec succès vers $nouvelleCategorie');
      return true;
    }
    
    print('⚠️ Réponse inattendue: ${response.statusCode}');
    return false;
  } catch (e, stack) {
    print('❌ Erreur lors du changement de catégorie: $e');
    if (e is DioException) {
      print('Détails de l\'erreur Dio: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
    }
    print(stack);
    return false;
  }
}

  // Récupérer tous les véhicules
  Future<List<Vehicle>> getVehicles() async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Impossible de récupérer les véhicules : utilisateur non authentifié.');
        return [];
      }

      print('📤 Récupération des véhicules...');

      final response = await _dio.get(
        '$_baseUrl/api/conducteur/vehicule',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Véhicules récupérés avec succès');
        
        List<dynamic> vehiclesData = response.data['data'] ?? response.data ?? [];

        return vehiclesData.map((data) {
          return Vehicle(
            id: data['id']?.toString() ?? '',
            model: data['modele']?.toString() ?? '',
            marque: data['marque']?.toString() ?? '',
            immatriculation: data['immatriculation']?.toString() ?? '',
            statut: data['statut']?.toString(),
            categorie: data['categorie']?.toString() ?? 'standard',
            couleur: data['couleur']?.toString() ?? 'Noire',
            courseHeure: data['course_heure'] == true || data['course_heure'] == 1,
            clim: data['clim'] == true || data['clim'] == 1,
            basic: data['basic'] == true || data['basic'] == 1,
            premium: data['premium'] == true || data['premium'] == 1,
          );
        }).toList();
      }

      return [];
    } catch (e, stack) {
      print('❌ Erreur lors de la récupération des véhicules: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return [];
    }
  }

  // Mettre à jour un véhicule
  Future<bool> updateVehicle({
    required String vehicleId,
    String? marque,
    String? modele,
    String? immatriculation,
    String? categorie,
    String? couleur,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }

      print('📤 Mise à jour du véhicule $vehicleId...');

      final response = await _dio.put(
        '$_baseUrl/api/conducteur/vehicule/$vehicleId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          if (marque != null) 'marque': marque,
          if (modele != null) 'modele': modele,
          if (immatriculation != null) 'immatriculation': immatriculation,
          if (categorie != null) 'categorie': categorie,
          if (couleur != null) 'couleur': couleur,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Véhicule mis à jour avec succès');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      print('❌ Erreur lors de la mise à jour du véhicule: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return false;
    }
  }

  // Supprimer un véhicule
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }

      print('📤 Suppression du véhicule $vehicleId...');

      final response = await _dio.delete(
        '$_baseUrl/api/conducteur/vehicule/$vehicleId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Véhicule supprimé avec succès');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      print('❌ Erreur lors de la suppression du véhicule: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return false;
    }
  }
}