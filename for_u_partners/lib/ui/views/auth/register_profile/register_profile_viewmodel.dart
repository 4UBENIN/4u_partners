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
    setBusy(true);
    try {
      await _authService.register(model, context);
      if (context.mounted) {
        CustomToast.showSuccess(context, message: "Inscription réussie");
      }
    } on DioException catch (e) {
      String errorMessage = "Une erreur est survenue lors de l'inscription";
      if (e.response?.data is Map) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
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
        errorMessage = e.message!;
      }
      if (context.mounted) {
        CustomToast.showError(context, message: errorMessage);
      }
      print("Erreur lors de l'inscription: $errorMessage");
      if (e.response?.data != null) {
        print("Détails de l'erreur: ${e.response!.data}");
      }
    } catch (e) {
      print("Erreur inattendue lors de l'inscription: $e");
      if (context.mounted) {
        CustomToast.showError(context,
            message: "Une erreur inattendue est survenue: ${e.toString()}");
      }
    } finally {
      setBusy(false);
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