import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/profil_validation_page.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';

class AuthService {
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Dio _dio = Dio();
  
  //* Mettre à jour la photo de profil
  Future<Map<String, dynamic>> updateProfilePicture(
      File imageFile, String token) async {
    try {
      String fileName = path.basename(imageFile.path);
      String? mimeType = lookupMimeType(imageFile.path);
      String type = mimeType?.split('/')[0] ?? '';
      String subtype = mimeType?.split('/')[1] ?? '';

      FormData formData = FormData.fromMap({
        'photo_profil': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType(type, subtype),
        ),
      });

      final response = await _dio.post(
        '${baseUrl}/user/photo-profil',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la mise à jour de la photo de profil'
        };
      }
    } catch (e) {
      print('Erreur lors de l\'upload de la photo: $e');
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  //* LOGIN FUNCTION
  Future<void> login(LoginModel loginModel, BuildContext context) async {
    print("🟡 [AuthService] Début de la méthode login()");
    final url = Uri.parse("$loginUrl");

    print("🟡 [AuthService] URL: $url");
    print("🟡 [AuthService] Payload: ${jsonEncode(loginModel.toJson())}");

    try {
      print("🟡 [AuthService] Envoi de la requête HTTP POST...");
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(loginModel.toJson()),
      );

      print("🟡 [AuthService] Réponse reçue");
      print("=== RESPONSE STATUS: ${response.statusCode} ===");
      print("=== RESPONSE BODY: ${response.body} ===");

      print("🟡 [AuthService] Parsing du JSON...");
      final responseJson = jsonDecode(response.body);
      print("🟡 [AuthService] JSON parsé avec succès");

      if (response.statusCode == 200) {
        print("🟢 [AuthService] Status 200 - Connexion réussie ✅");

        String role = responseJson['type'];
        print("🟡 [AuthService] Type initial: $role");

        if (role == "conducteur") {
          role = responseJson['conducteur_type'];
          print("🟡 [AuthService] Type conducteur_type: $role");
        }

        String name = responseJson['data']['nom'];
        String userId = responseJson['data']['id'].toString();
        String token = responseJson['token'];
        String message = responseJson['message'] ?? "Connexion réussie";
        String? vehiculeType = responseJson['vehicule_type'];

        print("🟡 [AuthService] Données extraites:");
        print("   - Nom: $name");
        print("   - UserId: $userId");
        print("   - Role: $role");
        print("   - Token: ${token.substring(0, 20)}...");
        print("   - Vehicule Type: $vehiculeType");

        print("🟡 [AuthService] Sauvegarde dans SharedPreferences...");
        await _sharedPreferencesServices.saveToken(token);
        await _sharedPreferencesServices.saveUserName(name);
        await _sharedPreferencesServices.saveUserType(role);
        await _sharedPreferencesServices.saveUserId(userId);

        // Save vehicle type if available
        if (vehiculeType != null && vehiculeType.isNotEmpty) {
          await _sharedPreferencesServices.saveActiveVehicleType(vehiculeType);
          print("🚗 [AuthService] Vehicle type saved: $vehiculeType");
        }

        String firestoreUserId;
        if (responseJson['data']['conducteur'] != null) {
          final conducteurId =
              responseJson['data']['conducteur']['id'].toString();
          await _sharedPreferencesServices.saveUserTypeId(conducteurId);
          firestoreUserId = conducteurId;
          print("🟡 [AuthService] ConducteurId: $conducteurId");
        } else {
          firestoreUserId = userId;
        }

        print("🟡 [AuthService] Synchronisation avec Firestore...");
        await _syncUserToFirestore(responseJson['data'], role, firestoreUserId);
        print("🟢 [AuthService] Firestore synchronisé");

        print("🟡 [AuthService] Envoi du token FCM au backend...");
        await _sendFcmTokenToBackend(role);

        print("🟡 [AuthService] Affichage du toast de succès...");
        CustomToast.showSuccess(context, message: message);

        print("🟡 [AuthService] Navigation vers l'écran approprié (role: $role)...");
        switch (role) {
          case 'livreur':
            print("🟡 [AuthService] Navigation vers DeliveryNavBarView");
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'chauffeur':
            print("🟡 [AuthService] Navigation vers HomemainView");
            _navigationService.replaceWithHomemainView();
            break;
          case 'ramasseur':
            print("🟡 [AuthService] Navigation vers DeliveryNavBarView (ramasseur)");
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'pressing':
            print("🟡 [AuthService] Navigation vers NavBarPressingView");
            _navigationService.replaceWithNavBarPressingView();
            break;
          default:
            print("⚠️ [AuthService] Role non reconnu: $role - Pas de navigation");
            break;
        }
        print("🟢 [AuthService] Navigation effectuée avec succès");
      } else {
        print("🔴 [AuthService] Status ${response.statusCode} - Échec de la connexion");
        String errorMessage = "Erreur de connexion. Veuillez réessayer.";

        if (responseJson['error'] != null && responseJson['error'] is String) {
          errorMessage = responseJson['error'];
        } else if (responseJson['errors'] != null &&
            responseJson['errors'] is Map) {
          final errors = responseJson['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        } else if (responseJson['message'] != null) {
          errorMessage = responseJson['message'].toString();
        }

        print("🔴 [AuthService] Message d'erreur: $errorMessage");
        throw errorMessage;
      }
    } catch (e) {
      print("❌ [AuthService] Exception capturée dans login(): $e");
      print("❌ [AuthService] Type d'exception: ${e.runtimeType}");
      print("❌ [AuthService] Stack trace: ${StackTrace.current}");

      if (e.toString().contains('SocketException')) {
        print("🔴 [AuthService] Erreur de connexion réseau détectée");
        throw "Problème de connexion Internet. Vérifiez votre réseau.";
      } else {
        print("🔴 [AuthService] Propagation de l'erreur: ${e.toString()}");
        throw e.toString();
      }
    }
  }

  //* Synchroniser l'utilisateur avec Firestore
  Future<void> _syncUserToFirestore(Map<String, dynamic> userData, String type,
      String firestoreUserId) async {
    try {
      print('🔥 [AUTH_SERVICE] _syncUserToFirestore called');
      print('🔥 [AUTH_SERVICE] firestoreUserId (document ID): $firestoreUserId');
      print('🔥 [AUTH_SERVICE] userData[id]: ${userData['id']}');
      print('🔥 [AUTH_SERVICE] type: $type');

      final userDoc = _firestore.collection('users').doc(firestoreUserId);
      final docSnapshot = await userDoc.get();

      // IMPORTANT: The 'id' field must match the document ID (firestoreUserId)
      Map<String, dynamic> baseUserData = {
        'id': firestoreUserId, // Changed from userData['id'] to firestoreUserId
        'nom': userData['nom'] ?? '',
        'prenom': userData['prenom'] ?? '',
        'email': userData['email'] ?? '',
        'telephone': userData['telephone'] ?? '',
        'role': type,
        'status': 'active',
        'lastSeen': FieldValue.serverTimestamp(),
      };

      // Keep track of the original user ID if different
      if (userData['id'].toString() != firestoreUserId) {
        baseUserData['originalUserId'] = userData['id'];
      }

      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      if (!docSnapshot.exists) {
        baseUserData['createdAt'] = FieldValue.serverTimestamp();
        await userDoc.set(baseUserData);
        print('✅ Nouvel utilisateur créé dans Firestore: $firestoreUserId');
        print('✅ Document ID: $firestoreUserId, id field: $firestoreUserId');
      } else {
        await userDoc.update({
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'active',
        });
        print('🔄 Utilisateur mis à jour dans Firestore: $firestoreUserId');
      }
    } catch (e) {
      print('❌ Erreur lors de la synchronisation Firestore: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  //* GET TOKEN HEADERS
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await _sharedPreferencesServices.getToken();
    final authenticatedHeaders = Map<String, String>.from(headers);

    if (token != null && token.isNotEmpty) {
      final cleanToken = token.replaceAll('"', '').trim();
      authenticatedHeaders['Authorization'] = 'Bearer $cleanToken';
    }
    return authenticatedHeaders;
  }

  //* VÉRIFICATION DU NUMÉRO DE TÉLÉPHONE
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final url = Uri.parse("$baseUrl/partenaire/check-phone");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'telephone': phoneNumber}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['exists'] ?? false;
      } else {
        print('Erreur lors de la vérification du numéro: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la vérification du numéro: $e');
      return false;
    }
  }

  //* ENVOI DU CODE OTP
  Future<Map<String, dynamic>> sendOtpCode(String phoneNumber) async {
    print("🔵 [AuthService] Début sendOtpCode()");
    print("🔵 [AuthService] Numéro de téléphone: $phoneNumber");

    try {
      // Ajouter le préfixe +229 si le numéro commence par 01
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('01')) {
        formattedPhone = '+229$phoneNumber';
        print("🔵 [AuthService] Numéro formaté: $formattedPhone");
      }

      final url = Uri.parse(sendOtpUrl);
      print("🔵 [AuthService] URL: $url");

      final body = jsonEncode({'telephone': formattedPhone});
      print("🔵 [AuthService] Body: $body");

      print("🔵 [AuthService] Envoi de la requête...");
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("🔵 [AuthService] Réponse reçue");
      print("🔵 [AuthService] Status code: ${response.statusCode}");
      print("🔵 [AuthService] Response body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [AuthService] Code OTP envoyé avec succès");
        return {
          'success': true,
          'message': responseData['message'] ?? 'Code envoyé avec succès',
          'data': responseData
        };
      } else {
        print("🔴 [AuthService] Erreur lors de l'envoi du code OTP");
        String errorMessage = 'Erreur lors de l\'envoi du code';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['error'] != null) {
          errorMessage = responseData['error'];
        }

        print("🔴 [AuthService] Message d'erreur: $errorMessage");
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print("❌ [AuthService] Exception dans sendOtpCode(): $e");
      return {
        'success': false,
        'message': 'Erreur de connexion. Veuillez réessayer.',
      };
    }
  }

  //* VÉRIFICATION DU CODE OTP
  Future<Map<String, dynamic>> verifyOtpCode(String phoneNumber, String code) async {
    print("🟣 [AuthService] Début verifyOtpCode()");
    print("🟣 [AuthService] Numéro: $phoneNumber");
    print("🟣 [AuthService] Code: $code");

    try {
      // Ajouter le préfixe +229 si le numéro commence par 01
      String formattedPhone = phoneNumber;
      if (phoneNumber.startsWith('01')) {
        formattedPhone = '+229$phoneNumber';
        print("🟣 [AuthService] Numéro formaté: $formattedPhone");
      }

      final url = Uri.parse(verifyOtpUrl);
      print("🟣 [AuthService] URL: $url");

      final body = jsonEncode({
        'telephone': formattedPhone,
        'code': code,
      });
      print("🟣 [AuthService] Body: $body");

      print("🟣 [AuthService] Envoi de la requête...");
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("🟣 [AuthService] Réponse reçue");
      print("🟣 [AuthService] Status code: ${response.statusCode}");
      print("🟣 [AuthService] Response body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ [AuthService] Code OTP vérifié avec succès");
        return {
          'success': true,
          'message': responseData['message'] ?? 'Code vérifié avec succès',
          'data': responseData
        };
      } else {
        print("🔴 [AuthService] Code OTP invalide");
        String errorMessage = 'Code invalide. Veuillez réessayer.';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['error'] != null) {
          errorMessage = responseData['error'];
        }

        print("🔴 [AuthService] Message d'erreur: $errorMessage");
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print("❌ [AuthService] Exception dans verifyOtpCode(): $e");
      return {
        'success': false,
        'message': 'Erreur de connexion. Veuillez réessayer.',
      };
    }
  }

  //* REGISTER FUNCTION
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
    print("🔍 [registrationModelToFormData] Début de la conversion");
    print("🔍 [registrationModelToFormData] model.type: ${model.type}");
    print("🔍 [registrationModelToFormData] model.telephone: ${model.telephone}");
    print("🔍 [registrationModelToFormData] model.email: ${model.email}");
    print("🔍 [registrationModelToFormData] model.code: ${model.code}");
    print("🔍 [registrationModelToFormData] model.motDePasse: ${model.motDePasse.isNotEmpty ? '***' : 'EMPTY'}");
    print("🔍 [registrationModelToFormData] model.motDePasseConfirmation: ${model.motDePasseConfirmation.isNotEmpty ? '***' : 'EMPTY'}");
    print("🔍 [registrationModelToFormData] model.nom: ${model.nom}");
    print("🔍 [registrationModelToFormData] model.adresse: ${model.adresse}");

    final formData = FormData();
    formData.fields.addAll([
      MapEntry('type', model.type),
      MapEntry('telephone', model.telephone),
      MapEntry('email', model.email),
      MapEntry('code', model.code),
      MapEntry('mot_de_passe', model.motDePasse),
      MapEntry('mot_de_passe_confirmation', model.motDePasseConfirmation),
      MapEntry('nom', model.nom),
      MapEntry('adresse', model.adresse),
    ]);
    print("🔍 [registrationModelToFormData] Champs de base ajoutés ✓");

    print("🔍 [registrationModelToFormData] model.prenom: ${model.prenom}");
    if (model.prenom != null)
      formData.fields.add(MapEntry('prenom', model.prenom!));

    print("🔍 [registrationModelToFormData] model.genre: ${model.genre}");
    if (model.genre != null)
      formData.fields.add(MapEntry('genre', model.genre!));

    print("🔍 [registrationModelToFormData] model.dateNaissance: ${model.dateNaissance}");
    if (model.dateNaissance != null && model.dateNaissance!.isNotEmpty) {
      formData.fields.add(MapEntry('date_naissance', model.dateNaissance!));
    }

    print("🔍 [registrationModelToFormData] model.numeroPermis: ${model.numeroPermis}");
    if (model.numeroPermis != null) {
      formData.fields
          .add(MapEntry('numero_permis', model.numeroPermis ?? 'TEMP_PERMIS'));
    }

    print("🔍 [registrationModelToFormData] model.dateExpirationPermis: ${model.dateExpirationPermis}");
    if (model.dateExpirationPermis != null) {
      formData.fields.add(MapEntry('date_expiration_permis',
          model.dateExpirationPermis ?? '2030-12-31'));
    }

    print("🔍 [registrationModelToFormData] model.possedeVehicule: ${model.possedeVehicule}");
    if (model.possedeVehicule != null) {
      formData.fields
          .add(MapEntry('possedevehicule', model.possedeVehicule.toString()));
    }

    print("🔍 [registrationModelToFormData] model.typeConducteurId: ${model.typeConducteurId}");
    if (model.typeConducteurId != null) {
      formData.fields.add(
          MapEntry('type_conducteur_id', model.typeConducteurId.toString()));
    }

    print("🔍 [registrationModelToFormData] model.documentIdentite: ${model.documentIdentite?.path}");
    if (model.documentIdentite != null) {
      final file = await MultipartFile.fromFile(
        model.documentIdentite!.path,
        filename: path.basename(model.documentIdentite!.path),
        contentType: getMediaTypeFromFileName(model.documentIdentite!.path),
      );
      formData.files.add(MapEntry('document_identite', file));
      print("🔍 [registrationModelToFormData] Document identité ajouté ✓");
    }

    print("🔍 [registrationModelToFormData] model.vehicule: ${model.vehicule != null ? 'NON NULL' : 'NULL'}");
    if (model.vehicule != null) {
      final v = model.vehicule!;
      print("🔍 [registrationModelToFormData] vehicule.type: ${v.type}");
      print("🔍 [registrationModelToFormData] vehicule.marque: ${v.marque}");
      print("🔍 [registrationModelToFormData] vehicule.modele: ${v.modele}");
      print("🔍 [registrationModelToFormData] vehicule.immatriculation: ${v.immatriculation}");
      print("🔍 [registrationModelToFormData] vehicule.nombrePlaces: ${v.nombrePlaces}");
      print("🔍 [registrationModelToFormData] vehicule.couleur: ${v.couleur}");
      print("🔍 [registrationModelToFormData] vehicule.categorie: ${v.categorie}");
      print("🔍 [registrationModelToFormData] vehicule.annee: ${v.annee}");

      // Vérifier chaque champ avant de l'ajouter
      if (v.type == null || v.type!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.type est NULL ou vide!");
        throw Exception("Le type du véhicule est requis");
      }
      if (v.marque == null || v.marque!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.marque est NULL ou vide!");
        throw Exception("La marque du véhicule est requise");
      }
      if (v.modele == null || v.modele!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.modele est NULL ou vide!");
        throw Exception("Le modèle du véhicule est requis");
      }
      if (v.immatriculation == null || v.immatriculation!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.immatriculation est NULL ou vide!");
        throw Exception("L'immatriculation du véhicule est requise");
      }
      if (v.nombrePlaces == null) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.nombrePlaces est NULL!");
        throw Exception("Le nombre de places du véhicule est requis");
      }
      if (v.couleur == null || v.couleur!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.couleur est NULL ou vide!");
        throw Exception("La couleur du véhicule est requise");
      }
      if (v.categorie == null || v.categorie!.isEmpty) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.categorie est NULL ou vide!");
        throw Exception("La catégorie du véhicule est requise");
      }
      if (v.annee == null) {
        print("❌ [registrationModelToFormData] ERREUR: vehicule.annee est NULL!");
        throw Exception("L'année du véhicule est requise");
      }

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
      print("🔍 [registrationModelToFormData] Champs véhicule ajoutés ✓");

      print("🔍 [registrationModelToFormData] vehicule.cartegrise: ${v.cartegrise?.path}");
      if (v.cartegrise != null) {
        final file = await MultipartFile.fromFile(
          v.cartegrise!.path,
          filename: path.basename(v.cartegrise!.path),
          contentType: getMediaTypeFromFileName(v.cartegrise!.path),
        );
        formData.files.add(MapEntry('vehicule[carte_grise]', file));
        print("🔍 [registrationModelToFormData] Carte grise ajoutée ✓");
      }

      print("🔍 [registrationModelToFormData] vehicule.assurance: ${v.assurance?.path}");
      if (v.assurance != null) {
        final file = await MultipartFile.fromFile(
          v.assurance!.path,
          filename: path.basename(v.assurance!.path),
          contentType: getMediaTypeFromFileName(v.assurance!.path),
        );
        formData.files.add(MapEntry('vehicule[assurance]', file));
        print("🔍 [registrationModelToFormData] Assurance ajoutée ✓");
      }

      print("🔍 [registrationModelToFormData] vehicule.permis: ${v.permis?.path}");
      if (v.permis != null) {
        final file = await MultipartFile.fromFile(
          v.permis!.path,
          filename: path.basename(v.permis!.path),
          contentType: getMediaTypeFromFileName(v.permis!.path),
        );
        formData.files.add(MapEntry('permis_conduire', file));
        print("🔍 [registrationModelToFormData] Permis ajouté ✓");
      }
    }

    print("✅ [registrationModelToFormData] Conversion terminée avec succès");
    return formData;
  }

  Future<void> register(
      RegistrationModel registrationModel, BuildContext context) async {
    print("🚀 [register] ========== DEBUT DE L'INSCRIPTION ==========");
    print("🚀 [register] Type d'inscription: ${registrationModel.type}");
    print("🚀 [register] Téléphone: ${registrationModel.telephone}");
    print("🚀 [register] Email: ${registrationModel.email}");
    print("🚀 [register] Nom: ${registrationModel.nom}");
    print("🚀 [register] Prénom: ${registrationModel.prenom}");
    print("🚀 [register] Adresse: ${registrationModel.adresse}");
    print("🚀 [register] Genre: ${registrationModel.genre}");
    print("🚀 [register] Date de naissance: ${registrationModel.dateNaissance}");
    print("🚀 [register] Code OTP: ${registrationModel.code}");
    print("🚀 [register] Possède véhicule: ${registrationModel.possedeVehicule}");
    print("🚀 [register] Type conducteur ID: ${registrationModel.typeConducteurId}");
    print("🚀 [register] Véhicule: ${registrationModel.vehicule != null ? 'OUI' : 'NON'}");

    final dio = Dio();
    final url = registerUrl;

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

    try {
      print("=== DEBUT DE L'INSCRIPTION ===");

      // ✅ Vérifier si le numéro existe déjà
      print("🔍 [register] Vérification si le numéro existe déjà...");
      final phoneExists =
          await checkPhoneNumberExists(registrationModel.telephone);
      print("🔍 [register] Numéro existe déjà: $phoneExists");
      if (phoneExists) {
        print("⚠️ [register] Le numéro existe déjà, redirection vers login");
        CustomToast.showError(
          context,
          message:
              "Ce numéro de téléphone est déjà associé à un compte. Veuillez vous connecter.",
        );

        // Redirection automatique vers la page de connexion
        Future.delayed(const Duration(seconds: 2), () {
          _navigationService.clearStackAndShow(Routes.loginView);
        });
        return;
      }

      print("=== CREATION DU FORMDATA ===");
      final formData = await registrationModelToFormData(registrationModel);
      print("✅ [register] FormData créé avec succès");

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data'
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print("🔍 [register] Status code reçu: ${response.statusCode}");
      final responseJson = response.data;
      print("🔍 [register] Response data: $responseJson");

      if (response.statusCode == 201) {
        print("✅ [register] Inscription réussie (status 201)");
        String token = responseJson['token'];
        String registerType = responseJson['type'];
        final String? profilStatuts = responseJson['data']['statut_validation'];

        if (registerType == "conducteur") {
          final String? conducteurType = responseJson['conducteur_type'];
          if (conducteurType != null) registerType = conducteurType;
        }

        await _sharedPreferencesServices.saveUserId(responseJson['data']['id']);
        await _sharedPreferencesServices.saveUserType(registerType);
        await _sharedPreferencesServices
            .saveUserName(responseJson['data']['nom']);

        String firestoreUserId;
        if (responseJson['data']['conducteur'] != null) {
          final conducteurId =
              responseJson['data']['conducteur']['id'].toString();
          await _sharedPreferencesServices.saveUserTypeId(conducteurId);
          firestoreUserId = conducteurId;
        } else {
          firestoreUserId = responseJson['data']['id'].toString();
        }

        await _syncRegisteredUserToFirestore(
          responseJson['data'],
          registerType,
          registrationModel,
          firestoreUserId,
        );

        await _sharedPreferencesServices.saveToken(token);

        print("🟡 [AuthService] Envoi du token FCM au backend après inscription...");
        await _sendFcmTokenToBackend(registerType);

        switch (registerType) {
          case 'livreur':
            if (profilStatuts != null) {
              await _sharedPreferencesServices.saveProfilStatuts(profilStatuts);
            }
            // Afficher un message de succès
            if (context.mounted) {
              CustomToast.showSuccess(context,
                message: "Inscription réussie! Bienvenue");
            }
            // Naviguer vers l'écran de livraison
            _navigationService.replaceWithDeliveryNavBarView();
            break;

          case 'chauffeur':
            if (profilStatuts != null) {
              await _sharedPreferencesServices.saveProfilStatuts(profilStatuts);
            }
            // Afficher un message de succès
            if (context.mounted) {
              CustomToast.showSuccess(context,
                message: "Inscription réussie! Bienvenue");
            }
            // Naviguer vers l'écran conducteur
            _navigationService.replaceWithHomemainView();
            break;

          case 'ramasseur':
            if (profilStatuts != null) {
              await _sharedPreferencesServices.saveProfilStatuts(profilStatuts);
            }
            // Afficher un message de succès
            if (context.mounted) {
              CustomToast.showSuccess(context,
                message: "Inscription réussie! Bienvenue");
            }
            // Naviguer vers l'écran pressing ramasseur
            _navigationService.replaceWithNavBarPressingView();
            break;

          case 'pressing':
            if (context.mounted) {
              CustomToast.showSuccess(context,
                message: "Inscription réussie! Bienvenue");
            }
            _navigationService.replaceWithNavBarPressingView();
            break;
        }
      } else {
        print("❌ [register] Échec de l'inscription (status ${response.statusCode})");
        String errorMessage = "Erreur lors de l'inscription";
        if (response.data is Map) {
          print("🔍 [register] Response data est un Map");
          if (response.data['error'] != null) {
            errorMessage = response.data['error'].toString();
            print("🔍 [register] Erreur trouvée dans 'error': $errorMessage");
          } else if (response.data['message'] != null) {
            errorMessage = response.data['message'].toString();
            print("🔍 [register] Erreur trouvée dans 'message': $errorMessage");
          } else if (response.data['errors'] != null) {
            final errors = response.data['errors'] as Map<String, dynamic>;
            print("🔍 [register] Erreurs multiples trouvées: $errors");
            if (errors.isNotEmpty) {
              final allErrors = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  allErrors.addAll(value.map((e) => e.toString()));
                } else if (value != null) allErrors.add(value.toString());
              });
              if (allErrors.isNotEmpty) errorMessage = allErrors.join('\n');
            }
          }
        }
        print("❌ [register] Message d'erreur final: $errorMessage");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Erreur pendant la requête : $e');
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: url),
        message: e.toString(),
      );
    }
  }

  Future<void> _syncRegisteredUserToFirestore(
    Map<String, dynamic> userData,
    String type,
    RegistrationModel registrationModel,
    String firestoreUserId,
  ) async {
    try {
      print('🔥 [AUTH_SERVICE] _syncRegisteredUserToFirestore called');
      print('🔥 [AUTH_SERVICE] firestoreUserId (document ID): $firestoreUserId');
      print('🔥 [AUTH_SERVICE] userData[id]: ${userData['id']}');

      final userDoc = _firestore.collection('users').doc(firestoreUserId);

      // IMPORTANT: The 'id' field must match the document ID (firestoreUserId)
      Map<String, dynamic> baseUserData = {
        'id': firestoreUserId, // Changed from userData['id'] to firestoreUserId
        'nom': registrationModel.nom,
        'prenom': registrationModel.prenom ?? '',
        'email': registrationModel.email,
        'telephone': registrationModel.telephone,
        'role': type,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'adresse': registrationModel.adresse,
        'genre': registrationModel.genre,
        'dateNaissance': registrationModel.dateNaissance,
      };

      // Keep track of the original user ID if different
      if (userData['id'].toString() != firestoreUserId) {
        baseUserData['originalUserId'] = userData['id'];
      }

      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      await userDoc.set(baseUserData);
      print('✅ Nouvel utilisateur inscrit dans Firestore: $firestoreUserId');
      print('✅ Document ID: $firestoreUserId, id field: $firestoreUserId');
    } catch (e) {
      print('❌ Erreur lors de la synchro Firestore: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _sendFcmTokenToBackend(String role) async {
    try {
      print('🔔 [AuthService] Début envoi token FCM pour role: $role');

      final fcmService = FirebaseMessagingService();
      String? endpoint;

      switch (role) {
        case 'chauffeur':
        case 'livreur':
        case 'ramasseur':
          endpoint = ApiConstant.saveFcmTokenDriver;
          print('🔔 [AuthService] Type conducteur - endpoint: $endpoint');
          break;
        case 'pressing':
          endpoint = ApiConstant.saveFcmTokenPressing;
          print('🔔 [AuthService] Type pressing - endpoint: $endpoint');
          break;
        default:
          print('⚠️ [AuthService] Role non reconnu pour FCM: $role');
          return;
      }

      print('🔔 [AuthService] Envoi du token FCM vers: $endpoint');
      bool success = await fcmService.sendCurrentTokenToBackend(
        endpoint,
        maxRetries: 3,
      );

      if (success) {
        print('✅ [AuthService] Token FCM envoyé avec succès après login/signup');
      } else {
        print('⚠️ [AuthService] Échec envoi token FCM (tentative de rafraîchissement)');
        final refreshed = await fcmService.refreshToken();

        if (refreshed) {
          print('🔄 [AuthService] Token rafraîchi, nouvelle tentative...');
          success = await fcmService.sendCurrentTokenToBackend(
            endpoint,
            maxRetries: 2,
          );

          if (success) {
            print('✅ [AuthService] Token FCM envoyé après rafraîchissement');
          } else {
            print('❌ [AuthService] Échec définitif envoi token FCM');
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ [AuthService] Exception lors envoi token FCM: $e');
      print('❌ [AuthService] Stack trace: $stackTrace');
    }
  }

  Future<void> logOut() async {
    await _sharedPreferencesServices.removeToken();
    await _sharedPreferencesServices.removeUserId();
    await _sharedPreferencesServices.removeUserType();
    await _sharedPreferencesServices.removeUserTypeId();
    await _sharedPreferencesServices.removeActiveVehicleType();

    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
