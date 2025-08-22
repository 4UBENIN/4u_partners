import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/profil_validation_page.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
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

  //* LOGIN FUNCTION

  Future<void> login(LoginModel loginModel) async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/partenaire/login");

    final response = await http.post(url,
        headers: headers, body: jsonEncode(loginModel.toJson()));

    print("=== RESPONSE: ${response.body} ===");
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      print("VALEURS");
      print("role : ${responseJson['data']['role']}");
      print("name : ${responseJson['data']['nom']}");
      print("userId : ${responseJson['data']['id']}");
      print("TOKEN : ${responseJson['token']}");

// Récupération directe des valeurs
      String role = responseJson['type'];
      if (role == "conducteur") {
        role = responseJson['conducteur_type'];
      }
      String name = responseJson['data']['nom'];
      String userId = responseJson['data']['id']
          .toString(); // Si tu veux le garder en String
      String token = responseJson['token'];

// Sauvegarde dans SharedPreferences
      await _sharedPreferencesServices.saveToken(token);
      await _sharedPreferencesServices.saveUserName(name);
      await _sharedPreferencesServices.saveUserType(role);
      await _sharedPreferencesServices.saveUserId(userId);
      switch (role) {
        case 'livreur':
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'chauffeur':
          _navigationService.replaceWithHomemainView();
          break;
        case 'ramasseur':
          _navigationService.replaceWithPickerNavBarView();
          break;
        case 'pressing':
          _navigationService.replaceWithNavBarPressingView();
          break;
        default:
          null;
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //* GET TOKEN HEADERS

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

    print("=== CONSTRUCTION FORMDATA SELON API ===");
    print("Type d'utilisateur: ${model.type}");
    print("Téléphone: ${model.telephone}");
    print("Email: ${model.email}");
    print("Véhicule présent: ${model.vehicule != null}");

    // Champs obligatoires de base
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

  Future<void> register(
      RegistrationModel registrationModel, BuildContext context) async {
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
        String registerType = responseJson['type'];
        String profilStatuts = responseJson['data']['statut_validation'];
        if (registerType == "conducteur") {
          registerType = responseJson['conducteur_type'];
        }

        await _sharedPreferencesServices.saveToken(responseJson['token']);
        await _sharedPreferencesServices.saveUserId(responseJson['data']['id']);
        await _sharedPreferencesServices.saveUserType(registerType);
        await _sharedPreferencesServices
            .saveUserName(responseJson['data']['nom']);
        await _sharedPreferencesServices.saveProfilStatuts(profilStatuts);

        print('Inscription réussie pour le type: $registerType');

        switch (registerType) {
          case 'livreur':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileValidationPage()));
            break;
          case 'chauffeur':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileValidationPage()));
            break;
          case 'ramasseur':
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileValidationPage()));
            break;
          case 'pressing':
            _navigationService.replaceWithNavBarPressingView();
            break;
          default:
            null;
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

  Future<void> logOut() async {
    // try {
    // Optionnel: appeler l'API de déconnexion
    //   final url =
    //       Uri.parse("https://foryou.cilassocies.com/api/partenaire/logout");

    //   await http.post(
    //     url,
    //     headers: await getAuthenticatedHeaders(),
    //   );
    // } catch (e) {
    //   print("Erreur lors du logout API: $e");
    // } finally {

    // Supprimer toutes les données locales
    await _sharedPreferencesServices.removeToken();
    await _sharedPreferencesServices.removeUserId();
    await _sharedPreferencesServices.removeUserType();

    // Rediriger vers l'écran de connexion
    _navigationService.clearStackAndShow(Routes.loginView);
    // }
  }
}
