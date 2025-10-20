import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/profil_validation_page.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class AuthService {
  final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _navigationService = locator<NavigationService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //* LOGIN FUNCTION
  Future<void> login(LoginModel loginModel, BuildContext context) async {
    final url = Uri.parse("https://foryou.cilassocies.com/api/partenaire/login");

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(loginModel.toJson()),
      );

      print("=== RESPONSE STATUS: ${response.statusCode} ===");
      print("=== RESPONSE BODY: ${response.body} ===");

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Connexion réussie ✅");

        String role = responseJson['type'];
        if (role == "conducteur") {
          role = responseJson['conducteur_type'];
        }

        String name = responseJson['data']['nom'];
        String userId = responseJson['data']['id'].toString();
        String token = responseJson['token'];
        String message = responseJson['message'] ?? "Connexion réussie";

        await _sharedPreferencesServices.saveToken(token);
        await _sharedPreferencesServices.saveUserName(name);
        await _sharedPreferencesServices.saveUserType(role);
        await _sharedPreferencesServices.saveUserId(userId);

        String firestoreUserId;
        if (responseJson['data']['conducteur'] != null) {
          final conducteurId =
              responseJson['data']['conducteur']['id'].toString();
          await _sharedPreferencesServices.saveUserTypeId(conducteurId);
          firestoreUserId = conducteurId;
        } else {
          firestoreUserId = userId;
        }

        await _syncUserToFirestore(responseJson['data'], role, firestoreUserId);

        CustomToast.showSuccess(context, message: message);

        switch (role) {
          case 'livreur':
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'chauffeur':
            _navigationService.replaceWithHomemainView();
            break;
          case 'ramasseur':
            _navigationService.replaceWithDeliveryNavBarView();
            break;
          case 'pressing':
            _navigationService.replaceWithNavBarPressingView();
            break;
          default:
            break;
        }
      } else {
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

        throw errorMessage;
      }
    } catch (e) {
      print("❌ Exception dans login(): $e");

      if (e.toString().contains('SocketException')) {
        throw "Problème de connexion Internet. Vérifiez votre réseau.";
      } else {
        throw e.toString();
      }
    }
  }

  //* Synchroniser l'utilisateur avec Firestore
  Future<void> _syncUserToFirestore(
      Map<String, dynamic> userData, String type, String firestoreUserId) async {
    try {
      final userDoc = _firestore.collection('users').doc(firestoreUserId);
      final docSnapshot = await userDoc.get();

      Map<String, dynamic> baseUserData = {
        'id': userData['id'],
        'nom': userData['nom'] ?? '',
        'prenom': userData['prenom'] ?? '',
        'email': userData['email'] ?? '',
        'telephone': userData['telephone'] ?? '',
        'role': type,
        'status': 'active',
        'lastSeen': FieldValue.serverTimestamp(),
      };

      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      if (!docSnapshot.exists) {
        baseUserData['createdAt'] = FieldValue.serverTimestamp();
        await userDoc.set(baseUserData);
        print('✅ Nouvel utilisateur créé dans Firestore: $firestoreUserId');
      } else {
        await userDoc.update({
          'lastSeen': FieldValue.serverTimestamp(),
          'status': 'active',
        });
        print('🔄 Utilisateur mis à jour dans Firestore: $firestoreUserId');
      }
    } catch (e) {
      print('❌ Erreur lors de la synchronisation Firestore: $e');
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
    print("AUTH HEADERS : ");
    print(authenticatedHeaders);
    return authenticatedHeaders;
  }

  //* VÉRIFICATION DU NUMÉRO DE TÉLÉPHONE
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      final url =
          Uri.parse("https://foryou.cilassocies.com/api/partenaire/check-phone");

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

    if (model.prenom != null) formData.fields.add(MapEntry('prenom', model.prenom!));
    if (model.genre != null) formData.fields.add(MapEntry('genre', model.genre!));
    if (model.dateNaissance != null && model.dateNaissance!.isNotEmpty) {
      formData.fields.add(MapEntry('date_naissance', model.dateNaissance!));
    }

    if (model.numeroPermis != null) {
      formData.fields.add(MapEntry('numero_permis', model.numeroPermis ?? 'TEMP_PERMIS'));
    }
    if (model.dateExpirationPermis != null) {
      formData.fields.add(MapEntry('date_expiration_permis', model.dateExpirationPermis ?? '2030-12-31'));
    }
    if (model.possedeVehicule != null) {
      formData.fields.add(MapEntry('possedevehicule', model.possedeVehicule.toString()));
    }
    if (model.typeConducteurId != null) {
      formData.fields.add(MapEntry('type_conducteur_id', model.typeConducteurId.toString()));
    }

    if (model.documentIdentite != null) {
      final file = await MultipartFile.fromFile(
        model.documentIdentite!.path,
        filename: path.basename(model.documentIdentite!.path),
        contentType: getMediaTypeFromFileName(model.documentIdentite!.path),
      );
      formData.files.add(MapEntry('document_identite', file));
    }

    if (model.vehicule != null) {
      final v = model.vehicule!;
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

      if (v.cartegrise != null) {
        final file = await MultipartFile.fromFile(
          v.cartegrise!.path,
          filename: path.basename(v.cartegrise!.path),
          contentType: getMediaTypeFromFileName(v.cartegrise!.path),
        );
        formData.files.add(MapEntry('vehicule[carte_grise]', file));
      }

      if (v.assurance != null) {
        final file = await MultipartFile.fromFile(
          v.assurance!.path,
          filename: path.basename(v.assurance!.path),
          contentType: getMediaTypeFromFileName(v.assurance!.path),
        );
        formData.files.add(MapEntry('vehicule[assurance]', file));
      }

      if (v.permis != null) {
        final file = await MultipartFile.fromFile(
          v.permis!.path,
          filename: path.basename(v.permis!.path),
          contentType: getMediaTypeFromFileName(v.permis!.path),
        );
        formData.files.add(MapEntry('permis_conduire', file));
      }
    }

    return formData;
  }

  Future<void> register(RegistrationModel registrationModel, BuildContext context) async {
    final dio = Dio();
    const url = 'https://foryou.cilassocies.com/api/partenaire/register';

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
      final phoneExists = await checkPhoneNumberExists(registrationModel.telephone);
      if (phoneExists) {
        CustomToast.showError(
          context,
          message: "Ce numéro de téléphone est déjà associé à un compte. Veuillez vous connecter.",
        );

        // Redirection automatique vers la page de connexion
        Future.delayed(const Duration(seconds: 2), () {
          _navigationService.clearStackAndShow(Routes.loginView);
        });
        return;
      }

      print("=== CREATION DU FORMDATA ===");
      final formData = await registrationModelToFormData(registrationModel);

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'accept': 'application/json', 'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final responseJson = response.data;
      String token = responseJson['token'];

      if (response.statusCode == 201) {
        String registerType = responseJson['type'];
        final String? profilStatuts = responseJson['data']['statut_validation'];

        if (registerType == "conducteur") {
          final String? conducteurType = responseJson['conducteur_type'];
          if (conducteurType != null) registerType = conducteurType;
        }

        await _sharedPreferencesServices.saveUserId(responseJson['data']['id']);
        await _sharedPreferencesServices.saveUserType(registerType);
        await _sharedPreferencesServices.saveUserName(responseJson['data']['nom']);

        String firestoreUserId;
        if (responseJson['data']['conducteur'] != null) {
          final conducteurId = responseJson['data']['conducteur']['id'].toString();
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

        switch (registerType) {
          case 'livreur':
          case 'chauffeur':
          case 'ramasseur':
            if (profilStatuts != null) {
              await _sharedPreferencesServices.saveProfilStatuts(profilStatuts);
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileValidationPage()),
            );
            break;

          case 'pressing':
            await _sharedPreferencesServices.saveToken(token);
            _navigationService.replaceWithNavBarPressingView();
            break;
        }
      } else {
        String errorMessage = "Erreur lors de l'inscription";
        if (response.data is Map) {
          if (response.data['message'] != null) {
            errorMessage = response.data['message'].toString();
          } else if (response.data['errors'] != null) {
            final errors = response.data['errors'] as Map<String, dynamic>;
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
      final userDoc = _firestore.collection('users').doc(firestoreUserId);
      Map<String, dynamic> baseUserData = {
        'id': userData['id'],
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

      if (userData['conducteur'] != null) {
        baseUserData['conducteurId'] = userData['conducteur']['id'];
      }

      await userDoc.set(baseUserData);
      print('✅ Nouvel utilisateur inscrit dans Firestore: $firestoreUserId');
    } catch (e) {
      print('❌ Erreur lors de la synchro Firestore: $e');
    }
  }

  Future<void> logOut() async {
    await _sharedPreferencesServices.removeToken();
    await _sharedPreferencesServices.removeUserId();
    await _sharedPreferencesServices.removeUserType();
    await _sharedPreferencesServices.removeUserTypeId();

    _navigationService.clearStackAndShow(Routes.loginView);
  }
}
