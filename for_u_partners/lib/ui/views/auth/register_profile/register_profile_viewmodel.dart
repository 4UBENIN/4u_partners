import 'dart:io';
import 'package:dio/dio.dart';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class RegisterProfileViewModel extends FormViewModel {
  bool? hasVehicle;
  bool _showVehicleError = false;

  //* Données de l'étape 1
  Map<String, dynamic> step1Data = {};

  bool? get showVehicleError => _showVehicleError;

  void setShowVehicleError(bool value) {
    _showVehicleError = value;
    notifyListeners();
  }

  //* Sauvegarder les données de l'étape 1
  void saveStep1Data({
    required String nom,
    required String prenom,
    required String adresse,
    String? genre,
  }) {
    step1Data = {
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'genre': genre,
    };
    notifyListeners();
  }

  //* Files
  File? deliverCarteGrise;
  File? deliverAssurance;
  File? driverIdentity;
  File? driverCarCarteGrise;
  File? driverCarAssurance;
  File? driverCarPermis;
  File? driverNoCarPermis;
  File? driverMotoCarteGrise;
  File? driverMotoAssurance;
  File? cleaningIdentity;

  //* Dropdown values
  final vehicles = ["moto", "voiture", "tricycle"];
  final categories = ["standard", "premium", "vip"];
  final wantedVehicles = ["moto", "voiture", "tricycle"];
  final genders = ["masculin", "feminin"];

  String _selectedVehicle = "moto";
  String get selectedVehicle => _selectedVehicle;

  String _wantedVehicle = "moto";
  String get wantedVehicle => _wantedVehicle;

  String _selectedCategory = "standard";
  String get selectedCategory => _selectedCategory;

  String _selectedGender = "masculin";
  String get selectedGender => _selectedGender;

  //* Services
  final _authService = locator<AuthService>();
  final ImagePicker _picker = ImagePicker();

  //* Controllers
  late final TextEditingController _driverCarPlacesController;
  bool _isInitialized = false;

  void setControllers({
    required TextEditingController driverCarPlacesController,
  }) {
    _driverCarPlacesController = driverCarPlacesController;
    _isInitialized = true;
  }

  //* Functions
  void setSelectedVehicle(String value) {
    if (_selectedVehicle != value) {
      _selectedVehicle = value;

      if (!_isInitialized) return;

      // Schedule the controller update for after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedVehicle == 'moto') {
          _driverCarPlacesController.text = '1';
        } else if (_selectedVehicle == 'tricycle') {
          _driverCarPlacesController.text = '3';
        } else if (_driverCarPlacesController.text == '1' ||
            _driverCarPlacesController.text == '3') {
          _driverCarPlacesController.clear();
        }
        // Notify listeners after updating the controller
        notifyListeners();
      });
    }
  }

  void setHasVehicle(bool value) {
    if (hasVehicle != value) {
      hasVehicle = value;

      // Mettre à jour les valeurs après la fin du frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (value == false) {
          _selectedVehicle = "moto";
          _wantedVehicle = "moto";
          // Mettre à jour le contrôleur pour la moto
          if (_isInitialized) {
            _driverCarPlacesController.text = '1';
          }
        }
        // Notifier les écouteurs après les mises à jour
        if (_isInitialized) {
          notifyListeners();
        }
      });
    }
  }

  String getSeatNumberHint() {
    switch (_selectedVehicle) {
      case 'moto':
        return '1 (fixé pour une moto)';
      case 'tricycle':
        return '3 (fixé pour un tricycle)';
      default:
        return 'Ex: 5';
    }
  }

  bool isSeatNumberEditable() {
    return _selectedVehicle != 'moto' && _selectedVehicle != 'tricycle';
  }

  void setWantedVehicle(String value) {
    _wantedVehicle = value;
    rebuildUi();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    rebuildUi();
  }

  void setSelectedGender(String value) {
    _selectedGender = value;
    rebuildUi();
  }

  Future<void> registerEnding(
      RegistrationModel model, BuildContext context) async {
    print("📝 [registerEnding] ========== DÉBUT registerEnding ==========");
    print("📝 [registerEnding] Type: ${model.type}");
    print("📝 [registerEnding] Téléphone: ${model.telephone}");
    print("📝 [registerEnding] Email: ${model.email}");
    print("📝 [registerEnding] Code OTP: ${model.code}");
    print("📝 [registerEnding] Nom: ${model.nom}");
    print("📝 [registerEnding] Prénom: ${model.prenom}");
    print("📝 [registerEnding] Adresse: ${model.adresse}");
    print("📝 [registerEnding] Genre: ${model.genre}");
    print("📝 [registerEnding] Date naissance: ${model.dateNaissance}");
    print("📝 [registerEnding] Numéro permis: ${model.numeroPermis}");
    print("📝 [registerEnding] Date expiration permis: ${model.dateExpirationPermis}");
    print("📝 [registerEnding] Document identité: ${model.documentIdentite?.path}");
    print("📝 [registerEnding] Possède véhicule: ${model.possedeVehicule}");
    print("📝 [registerEnding] Type conducteur ID: ${model.typeConducteurId}");

    if (model.vehicule != null) {
      print("📝 [registerEnding] === VÉHICULE ===");
      print("📝 [registerEnding] Véhicule.type: ${model.vehicule!.type}");
      print("📝 [registerEnding] Véhicule.marque: ${model.vehicule!.marque}");
      print("📝 [registerEnding] Véhicule.modele: ${model.vehicule!.modele}");
      print("📝 [registerEnding] Véhicule.immatriculation: ${model.vehicule!.immatriculation}");
      print("📝 [registerEnding] Véhicule.nombrePlaces: ${model.vehicule!.nombrePlaces}");
      print("📝 [registerEnding] Véhicule.couleur: ${model.vehicule!.couleur}");
      print("📝 [registerEnding] Véhicule.categorie: ${model.vehicule!.categorie}");
      print("📝 [registerEnding] Véhicule.annee: ${model.vehicule!.annee}");
      print("📝 [registerEnding] Véhicule.cartegrise: ${model.vehicule!.cartegrise?.path}");
      print("📝 [registerEnding] Véhicule.assurance: ${model.vehicule!.assurance?.path}");
      print("📝 [registerEnding] Véhicule.permis: ${model.vehicule!.permis?.path}");
    } else {
      print("📝 [registerEnding] Véhicule: NULL");
    }

    setBusy(true);
    try {
      print("📝 [registerEnding] Appel de authService.register()...");
      await _authService.register(model, context);
      print("✅ [registerEnding] Inscription réussie");
      if (context.mounted) {
        CustomToast.showSuccess(context, message: "Inscription réussie");
      }
    } on DioException catch (e) {
      print("❌ [registerEnding] DioException attrapée");
      print("❌ [registerEnding] StatusCode: ${e.response?.statusCode}");
      print("❌ [registerEnding] Response data: ${e.response?.data}");
      print("❌ [registerEnding] Message: ${e.message}");
      print("❌ [registerEnding] Type: ${e.type}");

      String errorMessage = "Une erreur est survenue lors de l'inscription";
      if (e.response?.data is Map) {
        final responseData = e.response!.data as Map<String, dynamic>;
        print("📋 [registerEnding] Response data (Map): $responseData");

        // Vérifier le champ 'error' en premier (comme dans la réponse du serveur)
        if (responseData['error'] != null) {
          errorMessage = responseData['error'].toString();
          print("📋 [registerEnding] Error trouvé: $errorMessage");
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          print("📋 [registerEnding] Errors: $errors");
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            print("📋 [registerEnding] Error key: $key, value: $value (${value.runtimeType})");
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else if (value is String) {
              errorMessages.add(value);
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        }
      } else if (e.message != null) {
        // Nettoyer le message d'erreur pour enlever "Exception: "
        String cleanMessage = e.message!;
        if (cleanMessage.contains('Exception:')) {
          cleanMessage = cleanMessage.split('Exception:').last.trim();
        }
        errorMessage = cleanMessage;
      }
      if (context.mounted) {
        CustomToast.showError(context, message: errorMessage);
      }
      print("❌ [registerEnding] Erreur finale: $errorMessage");
      if (e.response?.data != null) {
        print("❌ [registerEnding] Détails complets de l'erreur: ${e.response!.data}");
      }
    } catch (e, stackTrace) {
      print("❌ [registerEnding] Exception générale attrapée");
      print("❌ [registerEnding] Type d'exception: ${e.runtimeType}");
      print("❌ [registerEnding] Message: $e");
      print("❌ [registerEnding] Stack trace: $stackTrace");

      String errorMessage = "Une erreur inattendue est survenue";

      // Extraire le message d'erreur de l'exception
      if (e is Exception) {
        final exceptionString = e.toString();
        if (exceptionString.contains('Exception:')) {
          errorMessage = exceptionString.split('Exception:').last.trim();
        } else {
          errorMessage = exceptionString;
        }
      } else {
        errorMessage = e.toString();
      }

      if (context.mounted) {
        CustomToast.showError(context, message: errorMessage);
      }
    } finally {
      setBusy(false);
      print("📝 [registerEnding] ========== FIN registerEnding ==========");
    }
  }

  Future<void> _pickImage(void Function(File file) onImagePicked) async {
    try {
      // Demander la permission CAMERA
      if (Platform.isAndroid) {
        final cameraPermission = await Permission.camera.request();
        if (!cameraPermission.isGranted) {
          print("Permission caméra refusée");
          return;
        }
      }

      // Prendre une photo avec la caméra arrière
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final file = File(photo.path);
        onImagePicked(file);
        rebuildUi();
      }
    } catch (e) {
      print("Erreur lors de la prise de photo: $e");
    }
  }

  Widget uploadFileComponent(
    String label,
    File? pickedFile,
    void Function(File file) onFilePicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(label, fontsize: 16),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _pickImage(onFilePicked),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: pickedFile != null ? 200 : 45,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: greybutton),
                ),
                child: pickedFile != null
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: Image.file(
                          pickedFile,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: textinputcolor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                            TextComponent(
                              "Prendre une photo",
                              textcolor: textinputcolor.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
              ),
              if (pickedFile != null) ...[
                const SizedBox(height: 10),
                const TextComponent(
                  "Cliquez sur l'image pour reprendre une photo",
                  textcolor: primaryColor,
                )
              ]
            ],
          ),
        ),
      ],
    );
  }
}