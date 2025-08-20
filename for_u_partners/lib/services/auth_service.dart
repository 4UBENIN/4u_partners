import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class AuthService {
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //* LOGIN FUNCTION avec synchronisation Firestore - CORRIGÉE
  Future<void> login(LoginModel loginModel, String type) async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/partenaire/login");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(loginModel.toJson()),
    );

    print("=== RESPONSE: ${response.body} ===");
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      print("VALEURS");
      print("role : ${responseJson['data']['role']}");
      print("name : ${responseJson['data']['nom']}");
      print("userId : ${responseJson['data']['id']}");
      if (responseJson['data']['conducteur'] != null) {
        print("conducteurId : ${responseJson['data']['conducteur']['id']}");
      }
      print("TOKEN : ${responseJson['token']}");

      // ✅ CORRECTION : Récupérer le rôle depuis data.role au lieu de type
      String role = responseJson['data']['role'];
      String name = responseJson['data']['nom'];
      String userId = responseJson['data']['id'].toString();
      String token = responseJson['token'];

      // Sauvegarde dans SharedPreferences
      await _sharedPreferencesServices.saveToken(token);
      await _sharedPreferencesServices.saveUserName(name);
      await _sharedPreferencesServices.saveUserType(role);
      await _sharedPreferencesServices.saveUserId(userId);

      // ✅ LOGIQUE CORRIGÉE : Déterminer l'ID à utiliser pour Firestore
      String firestoreUserId;
      if (responseJson['data']['conducteur'] != null) {
        // Si c'est un conducteur/livreur, utiliser l'ID du conducteur
        final conducteurId =
            responseJson['data']['conducteur']['id'].toString();
        await _sharedPreferencesServices.saveUserTypeId(conducteurId);
        firestoreUserId = conducteurId;
        print(
            "Utilisateur partenaire détecté - ID Firestore: $firestoreUserId");
      } else {
        // Si c'est un client, utiliser l'ID utilisateur normal
        firestoreUserId = userId;
        print("Client détecté - ID Firestore: $firestoreUserId");
      }

      // Synchroniser avec Firestore en passant le bon ID
      await _syncUserToFirestore(responseJson['data'], role, firestoreUserId);

      // Navigation selon le rôle
      print("Navigation pour le rôle: $role");
      switch (role) {
        case 'livreur':
          print("Navigation vers DeliveryNavBarView");
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'conducteur':
          print("Navigation vers HomemainView");
          _navigationService.replaceWithHomemainView();
          break;
        case 'coursier':
          print("Navigation vers DeliveryNavBarView (coursier)");
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'pressing':
          print("Navigation vers NavBarPressingView");
          _navigationService.replaceWithNavBarPressingView();
          break;
        default:
          print("Navigation par défaut vers NavBarPressingView");
          _navigationService.replaceWithNavBarPressingView();
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //* Synchroniser l'utilisateur avec Firestore - CORRIGÉE
  Future<void> _syncUserToFirestore(Map<String, dynamic> userData, String type,
      String firestoreUserId) async {
    try {
      // ✅ UTILISER L'ID PASSÉ EN PARAMÈTRE
      final userDoc = _firestore.collection('users').doc(firestoreUserId);

      // Vérifier si le document existe déjà
      final docSnapshot = await userDoc.get();

      // Mapper les types de partenaires vers les rôles unifiés
      String unifiedRole = _mapPartnerTypeToRole(type);

      // Données de base communes à tous les utilisateurs
      Map<String, dynamic> baseUserData = {
        'id': userData['id'], // ✅ GARDER L'ID ORIGINAL POUR RÉFÉRENCE
        'nom': userData['nom'] ?? '',
        'prenom': userData['prenom'] ?? '',
        'email': userData['email'] ?? '',
        'telephone': userData['telephone'] ?? '',
        'role': unifiedRole,
        'status': 'active',
        'lastSeen': FieldValue.serverTimestamp(),
      };

      // ✅ AJOUTER L'ID CONDUCTEUR SI DISPONIBLE
      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      if (!docSnapshot.exists) {
        // Créer un nouveau document avec les données complètes
        baseUserData['createdAt'] = FieldValue.serverTimestamp();

        // Ajouter les informations spécifiques selon le rôle
        if (unifiedRole == 'driver') {
          baseUserData['driverInfo'] = _createDriverInfo(userData);
        }

        await userDoc.set(baseUserData);
        print(
            '✅ Nouvel utilisateur créé dans Firestore: $firestoreUserId ($unifiedRole)');
      } else {
        // Mettre à jour les données existantes
        Map<String, dynamic> updateData = {
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'active',
        };

        // Mettre à jour les infos spécifiques si nécessaire
        if (unifiedRole == 'driver') {
          updateData['driverInfo'] = _createDriverInfo(userData);
        } else if (unifiedRole == 'delivery') {
          updateData['deliveryInfo'] = _createDeliveryInfo(userData, type);
        }

        await userDoc.update(updateData);
        print(
            '🔄 Utilisateur mis à jour dans Firestore: $firestoreUserId ($unifiedRole)');
      }
    } catch (e) {
      print('❌ Erreur lors de la synchronisation Firestore: $e');
      // Ne pas bloquer la connexion si Firestore échoue
    }
  }

  //* REGISTER FUNCTION avec synchronisation Firestore - CORRIGÉE
  Future<void> register(RegistrationModel registrationModel) async {
    final dio = Dio();
    const url = 'https://foryou.cilassocies.com/api/partenaire/register';

    // Activer les logs de Dio pour voir les requêtes
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

    print("=== DEBUT DE L'INSCRIPTION ===");
    print("URL: $url");
    print("Type: ${registrationModel.type}");
    print("Telephone: ${registrationModel.telephone}");
    print("Email: ${registrationModel.email}");
    print("Nom: ${registrationModel.nom}");
    print("Vehicule présent: ${registrationModel.vehicule != null}");

    if (registrationModel.vehicule != null) {
      print("Vehicule type: ${registrationModel.vehicule!.type}");
      print("Vehicule marque: ${registrationModel.vehicule!.marque}");
      print(
          "Fichier carte grise: ${registrationModel.vehicule!.cartegrise?.path}");
      print(
          "Fichier assurance: ${registrationModel.vehicule!.assurance?.path}");
      print("Fichier permis: ${registrationModel.vehicule!.permis?.path}");
    }

    print("Document identité: ${registrationModel.documentIdentite?.path}");

    try {
      print("=== CREATION DU FORMDATA ===");
      final formData = await registrationModelToFormData(registrationModel);

      // Afficher le contenu du FormData
      print("=== CONTENU DU FORMDATA ===");
      print("Fields:");
      for (var field in formData.fields) {
        print("  ${field.key}: ${field.value}");
      }
      print("Files:");
      for (var file in formData.files) {
        print(
            "  ${file.key}: ${file.value.filename} (${file.value.length} bytes)");
      }

      print("=== ENVOI DE LA REQUETE ===");
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // Accepter tous les status codes pour pouvoir les traiter
            return status != null && status < 500;
          },
        ),
      );

      print("=== REPONSE RECUE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 201) {
        final responseJson = response.data;

        // ✅ CORRECTION : Utiliser 'data.role' au lieu de 'type'
        final registerType = responseJson['data']['role'];

        await _sharedPreferencesServices.saveToken(responseJson['token']);
        await _sharedPreferencesServices
            .saveUserId(responseJson['data']['id'].toString());
        await _sharedPreferencesServices.saveUserType(registerType);
        await _sharedPreferencesServices
            .saveUserName(responseJson['data']['nom']);

        // ✅ LOGIQUE CORRIGÉE : Même logique que pour login
        String firestoreUserId;
        if (responseJson['data']['conducteur'] != null) {
          // Si c'est un conducteur/livreur, utiliser l'ID du conducteur
          final conducteurId =
              responseJson['data']['conducteur']['id'].toString();
          await _sharedPreferencesServices.saveUserTypeId(conducteurId);
          firestoreUserId = conducteurId;
          print("Partenaire inscrit - ID Firestore: $firestoreUserId");
        } else {
          // Si c'est un client, utiliser l'ID utilisateur normal
          firestoreUserId = responseJson['data']['id'].toString();
          print("Client inscrit - ID Firestore: $firestoreUserId");
        }

        // Synchroniser avec Firestore après inscription réussie
        await _syncRegisteredUserToFirestore(responseJson['data'], registerType,
            registrationModel, firestoreUserId);

        print('Inscription réussie pour le type: $registerType');

        switch (registerType) {
          case 'livreur':
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'conducteur':
            _navigationService.replaceWithHomemainView();
            break;
          case 'coursier':
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'pressing':
            _navigationService.replaceWithNavBarPressingView();
            break;
          default:
            _navigationService.replaceWithNavBarPressingView();
        }
      } else {
        // LANCER UNE EXCEPTION AU LIEU DE JUSTE IMPRIMER
        print('=== ERREUR SERVEUR ===');
        print('Status Code: ${response.statusCode}');
        print('Response: ${response.data}');

        String errorMessage = "Erreur lors de l'inscription";

        // Extraire le message d'erreur du serveur
        if (response.data is Map) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          } else if (response.data.containsKey('errors')) {
            // Si c'est des erreurs de validation
            final errors = response.data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        }

        // Lancer l'exception avec le message d'erreur
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('=== EXCEPTION ===');
      print('Erreur pendant l\'envoi de la requête : $e');

      // Si c'est déjà une DioException, la relancer
      if (e is DioException) {
        print('DioException details:');
        print('  Type: ${e.type}');
        print('  Message: ${e.message}');
        print('  Response: ${e.response?.data}');
        print('  Status Code: ${e.response?.statusCode}');

        rethrow; // Relancer l'exception pour qu'elle soit captée dans registerEnding
      } else {
        // Pour toute autre exception, la wrapper dans une DioException
        print('Stack trace : ${StackTrace.current}');
        throw DioException(
          requestOptions: RequestOptions(path: url),
          message: e.toString(),
        );
      }
    }
  }

  //* Synchroniser l'utilisateur inscrit avec Firestore - CORRIGÉE
  Future<void> _syncRegisteredUserToFirestore(
    Map<String, dynamic> userData,
    String type,
    RegistrationModel registrationModel,
    String firestoreUserId, // ✅ NOUVEAU PARAMÈTRE
  ) async {
    try {
      // ✅ UTILISER L'ID PASSÉ EN PARAMÈTRE
      final userDoc = _firestore.collection('users').doc(firestoreUserId);

      String unifiedRole = _mapPartnerTypeToRole(type);

      // Données de base communes à tous les utilisateurs
      Map<String, dynamic> baseUserData = {
        'id': userData['id'], // ✅ GARDER L'ID ORIGINAL POUR RÉFÉRENCE
        'nom': registrationModel.nom,
        'prenom': registrationModel.prenom ?? '',
        'email': registrationModel.email,
        'telephone': registrationModel.telephone,
        'role': unifiedRole,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'adresse': registrationModel.adresse,
        'genre': registrationModel.genre,
        'dateNaissance': registrationModel.dateNaissance,
      };

      // ✅ AJOUTER L'ID CONDUCTEUR SI DISPONIBLE
      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      // Ajouter les informations spécifiques selon le rôle
      if (unifiedRole == 'driver') {
        baseUserData['driverInfo'] =
            _createDetailedDriverInfo(registrationModel);
      } else if (unifiedRole == 'delivery') {
        baseUserData['deliveryInfo'] =
            _createDetailedDeliveryInfo(registrationModel, type);
      }

      await userDoc.set(baseUserData);
      print(
          '✅ Nouvel utilisateur inscrit créé dans Firestore: $firestoreUserId ($unifiedRole)');
    } catch (e) {
      print('❌ Erreur lors de la synchronisation Firestore (inscription): $e');
      // Ne pas bloquer l'inscription si Firestore échoue
    }
  }

  //* LOGOUT FUNCTION - CORRIGÉE
  Future<void> logOut() async {
    // ✅ CORRECTION : Récupérer le bon ID pour Firestore
    String? firestoreUserId = await _sharedPreferencesServices.getUserTypeId();
    firestoreUserId ??= await _sharedPreferencesServices.getUserId();

    // Supprimer toutes les données locales
    await _sharedPreferencesServices.removeToken();
    await _sharedPreferencesServices.removeUserId();
    await _sharedPreferencesServices.removeUserTypeId();
    await _sharedPreferencesServices.removeUserType();

    // ✅ CORRECTION : Mettre à jour le statut dans Firestore avec le bon ID
    if (firestoreUserId != null) {
      try {
        await _firestore.collection('users').doc(firestoreUserId).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'offline',
          'driverInfo.isOnline': false,
          'deliveryInfo.isOnline': false,
        });
        print(
            '✅ Statut utilisateur mis à jour lors du logout: $firestoreUserId');
      } catch (e) {
        print("❌ Erreur mise à jour statut lors du logout: $e");
      }
    }

    // Rediriger vers l'écran de connexion
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  //* Mapper les types de partenaires vers les rôles unifiés
  String _mapPartnerTypeToRole(String partnerType) {
    switch (partnerType.toLowerCase()) {
      case 'conducteur':
        return 'driver';
      case 'livreur':
        return 'delivery';
      case 'pressing':
        return 'pressing'; // Ou 'service' selon votre structure
      default:
        return 'driver'; // Rôle générique pour les partenaires
    }
  }

  //* Créer les informations spécifiques au conducteur
  Map<String, dynamic> _createDriverInfo(Map<String, dynamic> userData) {
    return {
      'vehicleType': 'car', // Par défaut, à adapter selon vos données
      'vehicleModel': '', // À compléter avec les données du véhicule
      'licensePlate': '',
      'licenseNumber': userData['numero_permis'] ?? '',
      'rating': 5.0,
      'totalRides': 0,
      'isOnline': false,
      'currentLocation': null,
      'lastLocationUpdate': null,
      'dateExpirationPermis': userData['date_expiration_permis'],
      'possedeVehicule': userData['possedevehicule'] ?? false,
    };
  }

  //* Créer les informations spécifiques au livreur
  Map<String, dynamic> _createDeliveryInfo(
      Map<String, dynamic> userData, String type) {
    String vehicleType = 'motorcycle'; // Par défaut
    if (type == 'coursier') vehicleType = 'bicycle';

    return {
      'vehicleType': vehicleType,
      'rating': 5.0,
      'totalDeliveries': 0,
      'isOnline': false,
      'currentLocation': null,
      'lastLocationUpdate': null,
      'deliveryZones': <String>[],
    };
  }

  //* Créer les informations détaillées du conducteur lors de l'inscription
  Map<String, dynamic> _createDetailedDriverInfo(
      RegistrationModel registrationModel) {
    Map<String, dynamic> driverInfo = {
      'licenseNumber': registrationModel.numeroPermis ?? '',
      'dateExpirationPermis': registrationModel.dateExpirationPermis,
      'possedeVehicule': registrationModel.possedeVehicule ?? false,
      'typeConducteurId': registrationModel.typeConducteurId,
      'rating': 5.0,
      'totalRides': 0,
      'isOnline': false,
      'currentLocation': null,
      'lastLocationUpdate': null,
    };

    // Ajouter les informations du véhicule si disponibles
    if (registrationModel.vehicule != null) {
      final v = registrationModel.vehicule!;
      driverInfo.addAll({
        'vehicleType': _mapVehicleTypeToStandard(v.type ?? 'car'),
        'vehicleModel': '${v.marque ?? ''} ${v.modele ?? ''}'.trim(),
        'licensePlate': v.immatriculation ?? '',
        'vehicleColor': v.couleur ?? '',
        'vehicleCategory': v.categorie ?? '',
        'vehicleYear': v.annee,
        'vehicleSeats': v.nombrePlaces,
        // Informations des documents (les fichiers sont déjà uploadés via l'API)
        'hasCarteGrise': v.cartegrise != null,
        'hasAssurance': v.assurance != null,
        'hasPermis': v.permis != null,
      });
    } else {
      // Valeurs par défaut si pas de véhicule
      driverInfo.addAll({
        'vehicleType': 'car',
        'vehicleModel': '',
        'licensePlate': '',
        'vehicleColor': '',
        'vehicleCategory': '',
        'vehicleYear': DateTime.now().year,
        'vehicleSeats': 4,
      });
    }

    return driverInfo;
  }

  //* Créer les informations détaillées du livreur lors de l'inscription
  Map<String, dynamic> _createDetailedDeliveryInfo(
      RegistrationModel registrationModel, String type) {
    String vehicleType = 'motorcycle';
    if (type == 'coursier') vehicleType = 'bicycle';

    return {
      'vehicleType': vehicleType,
      'rating': 5.0,
      'totalDeliveries': 0,
      'isOnline': false,
      'currentLocation': null,
      'lastLocationUpdate': null,
      'deliveryZones': <String>[],
      'licenseNumber': registrationModel.numeroPermis ?? '',
      'dateExpirationPermis': registrationModel.dateExpirationPermis,
    };
  }

  //* Mapper les types de véhicules vers des standards
  String _mapVehicleTypeToStandard(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'voiture':
      case 'car':
        return 'car';
      case 'moto':
      case 'motorcycle':
        return 'motorcycle';
      case 'tricycle':
        return 'tricycle';
      case 'vélo':
      case 'bicycle':
        return 'bicycle';
      default:
        return vehicleType.toLowerCase();
    }
  }

  //* GET TOKEN HEADERS (inchangé)
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await _sharedPreferencesServices.getToken();

    // Créer une copie des headers de base et ajouter le token
    final authenticatedHeaders = Map<String, String>.from(headers);

    if (token != null && token.isNotEmpty) {
      // Remove any existing quotes from the token
      final cleanToken = token.replaceAll('"', '').trim();
      authenticatedHeaders['Authorization'] = 'Bearer $cleanToken';
    }
    print("AUTH HEADERS : ");
    print(authenticatedHeaders);

    return authenticatedHeaders;
  }

  MediaType getMediaTypeFromFileName(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.pdf':
        return MediaType('application', 'pdf');
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<FormData> registrationModelToFormData(RegistrationModel model) async {
    // Votre implémentation existante...
    final formData = FormData();

    print("=== CONSTRUCTION FORMDATA SELON API ===");

    // Champs obligatoires de base
    formData.fields.addAll([
      MapEntry('type', model.type),
      MapEntry('telephone', model.telephone),
      MapEntry('email', model.email),
      MapEntry('code', model.code), // L'API l'attend (voir curl)
      MapEntry('mot_de_passe', model.motDePasse),
      MapEntry('mot_de_passe_confirmation', model.motDePasseConfirmation),
      MapEntry('nom', model.nom),
      MapEntry('adresse', model.adresse),
    ]);

    // Champs optionnels mais présents dans le curl
    if (model.prenom != null) {
      formData.fields.add(MapEntry('prenom', model.prenom!));
    }
    if (model.genre != null) {
      formData.fields.add(MapEntry('genre', model.genre!));
    }

    // IMPORTANT: date_naissance est dans le curl, il faut une vraie date ou null
    if (model.dateNaissance != null && model.dateNaissance!.isNotEmpty) {
      formData.fields.add(MapEntry('date_naissance', model.dateNaissance!));
    }

    if (model.numeroPermis != null) {
      formData.fields
          .add(MapEntry('numero_permis', model.numeroPermis ?? 'TEMP_PERMIS'));
    }
    if (model.dateExpirationPermis != null) {
      formData.fields.add(MapEntry('date_expiration_permis',
          model.dateExpirationPermis ?? '2030-12-31'));
    }
    if (model.possedeVehicule != null) {
      formData.fields
          .add(MapEntry('possedevehicule', model.possedeVehicule.toString()));
    }
    if (model.typeConducteurId != null) {
      formData.fields.add(
          MapEntry('type_conducteur_id', model.typeConducteurId.toString()));
    }

    // Document d'identité
    if (model.documentIdentite != null) {
      try {
        final file = await MultipartFile.fromFile(
          model.documentIdentite!.path,
          filename: path.basename(model.documentIdentite!.path),
          contentType: getMediaTypeFromFileName(model.documentIdentite!.path),
        );
        formData.files.add(MapEntry('document_identite', file));
        print("Document d'identité ajouté: ${model.documentIdentite!.path}");
      } catch (e) {
        print("Erreur avec document d'identité: $e");
      }
    }

    // VEHICULE - Utiliser la syntaxe vehicule[champ] comme dans le curl
    if (model.vehicule != null) {
      final v = model.vehicule!;
      print("=== AJOUT DU VEHICULE (syntaxe API) ===");

      // Champs du véhicule avec syntaxe vehicule[champ]
      formData.fields.addAll([
        MapEntry('vehicule[type]', v.type!),
        MapEntry('vehicule[marque]', v.marque!),
        MapEntry('vehicule[modele]', v.modele!),
        MapEntry('vehicule[immatriculation]', v.immatriculation!),
        MapEntry('vehicule[nombre_places]', v.nombrePlaces.toString()),
        MapEntry('vehicule[couleur]', v.couleur!),
        MapEntry('vehicule[categorie]', v.categorie!),
        MapEntry('vehicule[annee]', v.annee.toString()),
      ]);

      print("Champs véhicule ajoutés");

      // FICHIERS DU VEHICULE avec syntaxe vehicule[champ]
      if (v.cartegrise != null) {
        try {
          final file = await MultipartFile.fromFile(
            v.cartegrise!.path,
            filename: path.basename(v.cartegrise!.path),
            contentType: getMediaTypeFromFileName(v.cartegrise!.path),
          );
          formData.files.add(MapEntry('vehicule[carte_grise]', file));
          print("Carte grise ajoutée: ${v.cartegrise!.path}");
        } catch (e) {
          print("Erreur avec carte grise: $e");
        }
      }

      if (v.assurance != null) {
        try {
          final file = await MultipartFile.fromFile(
            v.assurance!.path,
            filename: path.basename(v.assurance!.path),
            contentType: getMediaTypeFromFileName(v.assurance!.path),
          );
          formData.files.add(MapEntry('vehicule[assurance]', file));
          print("Assurance ajoutée: ${v.assurance!.path}");
        } catch (e) {
          print("Erreur avec assurance: $e");
        }
      }

      if (v.permis != null) {
        try {
          final file = await MultipartFile.fromFile(
            v.permis!.path,
            filename: path.basename(v.permis!.path),
            contentType: getMediaTypeFromFileName(v.permis!.path),
          );
          // CORRECTION: Envoyer à la racine, pas dans vehicule[]
          formData.files.add(MapEntry('permis_conduire', file));
          print("Permis ajouté: ${v.permis!.path}");
        } catch (e) {
          print("Erreur avec permis: $e");
        }
      }
    }

    print("=== FIN CONSTRUCTION FORMDATA ===");
    return formData;
  }
}
