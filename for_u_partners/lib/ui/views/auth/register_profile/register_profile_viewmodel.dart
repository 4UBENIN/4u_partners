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
  // GESTION DES ÉTAPES
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Le nombre d'étapes dépend de si l'utilisateur a un véhicule
  int get totalSteps => hasVehicle == true ? 3 : 2;

  bool? hasVehicle;
  bool _showVehicleError = false;
  bool? get showVehicleError => _showVehicleError;

  void setShowVehicleError(bool value) {
    _showVehicleError = value;
    notifyListeners();
  }

  // Navigation entre étapes
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  //* Files
  XFile? driverIdentity;
  XFile? driverCarCarteGrise;
  XFile? driverCarAssurance;
  XFile? driverCarPermis;
  XFile? driverNoCarPermis;
  XFile? driverMotoCarteGrise;
  XFile? driverMotoAssurance;

  //* Dropdown values
  final vehicles = ["moto", "voiture", "tricycle"];
  final categories = ["standard", "premium", "vip"];
  final wantedVehicles = ["moto", "voiture", "tricycle"];

  String _selectedVehicle = "moto";
  String get selectedVehicle => _selectedVehicle;

  String _wantedVehicle = "moto";
  String get wantedVehicle => _wantedVehicle;

  String _selectedCategory = "standard";
  String get selectedCategory => _selectedCategory;

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedVehicle == 'moto') {
          _driverCarPlacesController.text = '1';
        } else if (_selectedVehicle == 'tricycle') {
          _driverCarPlacesController.text = '3';
        } else if (_driverCarPlacesController.text == '1' ||
            _driverCarPlacesController.text == '3') {
          _driverCarPlacesController.clear();
        }
        notifyListeners();
      });
    }
  }

  void setHasVehicle(bool value) {
    if (hasVehicle != value) {
      hasVehicle = value;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (value == false) {
          _selectedVehicle = "moto";
          _wantedVehicle = "moto";
          if (_isInitialized) {
            _driverCarPlacesController.text = '1';
          }
        }
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

  // Validation de l'étape actuelle
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Étape pièce d'identité
        if (driverIdentity == null) {
          return false;
        }
        return true;

      case 1: // Étape véhicule (question)
        if (hasVehicle == null) {
          setShowVehicleError(true);
          return false;
        }

        // Si pas de véhicule, vérifier le type souhaité et le permis si voiture
        if (hasVehicle == false) {
          if (wantedVehicle == "voiture" && driverNoCarPermis == null) {
            return false;
          }
        }
        return true;

      case 2: // Étape informations véhicule (si a un véhicule)
        if (hasVehicle == true) {
          return _validateVehicleInfo();
        }
        return true;

      default:
        return false;
    }
  }

  bool _validateVehicleInfo() {
    // Validation commune
    if (_driverCarPlacesController.text.isEmpty) return false;

    if (_selectedVehicle == 'voiture') {
      if (driverCarPermis == null) return false;
      if (driverCarCarteGrise == null) return false;
      if (driverCarAssurance == null) return false;
    } else {
      if (driverMotoCarteGrise == null) return false;
      if (driverMotoAssurance == null) return false;
    }

    return true;
  }

  Future<void> registerEnding(
    RegistrationModel model, BuildContext context) async {
  setBusy(true);
  try {
    print("🚀 Début de l'inscription via AuthService...");
    await _authService.register(model, context);
    print("✅ AuthService.register() terminé avec succès");
    
    if (context.mounted) {
      CustomToast.showSuccess(context, message: "Inscription réussie");
      print("✅ Toast de succès affiché");
    }
  } on DioException catch (e) {
    print("❌ DioException attrapée: ${e.message}");
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
  } catch (e, stackTrace) {  // ← Ajoutez stackTrace ici aussi !
    print("❌ ERREUR INATTENDUE dans registerEnding:");
    print("Type: ${e.runtimeType}");
    print("Message: $e");
    print("StackTrace: $stackTrace");
    
    if (context.mounted) {
      CustomToast.showError(context,
          message: "Une erreur inattendue est survenue: ${e.toString()}");
    }
  } finally {
    print("🔄 setBusy(false)");
    setBusy(false);
  }
}

  Future<void> _pickImage(void Function(XFile file) onImagePicked) async {
    try {
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.request();
        final photosPermission = await Permission.photos.request();
        if (!storagePermission.isGranted && !photosPermission.isGranted) {
          return;
        }
      }

      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        onImagePicked(image);
        rebuildUi();
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image: $e");
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    const Color mainColor = Color(0xFF184E9C);

    return showModalBottomSheet<ImageSource>(
      context: StackedService.navigatorKey!.currentContext!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 15),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const TextComponent(
                "Choisissez une source d'image",
                fontsize: 20,
                fontweight: FontWeight.bold,
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: mainColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: mainColor,
                            size: 24,
                          ),
                        ),
                        title: const TextComponent(
                          'Galerie',
                          fontsize: 16,
                        ),
                        subtitle: TextComponent(
                          'Choisir depuis vos photos',
                          fontsize: 13,
                          textcolor: Colors.grey[600]!,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        onTap: () =>
                            Navigator.of(context).pop(ImageSource.gallery),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: mainColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: mainColor,
                            size: 24,
                          ),
                        ),
                        title: const TextComponent(
                          'Appareil photo',
                          fontsize: 16,
                        ),
                        subtitle: TextComponent(
                          'Prendre une nouvelle photo',
                          fontsize: 13,
                          textcolor: Colors.grey[600]!,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        onTap: () =>
                            Navigator.of(context).pop(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[50],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: TextComponent(
                      'Annuler',
                      fontsize: 16,
                      textcolor: Colors.grey[600]!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        );
      },
    );
  }

  Widget uploadFileComponent(
  String label,
  XFile? pickedFile,
  void Function(XFile file) onFilePicked,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextComponent(label, fontsize: 16),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () async {
          print("🖼️ Tentative d'upload pour: $label");
          await _pickImage((file) {
            print("✅ Fichier sélectionné: ${file.path}");
            onFilePicked(file);
          });
        },
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
                        File(pickedFile.path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            color: textinputcolor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          TextComponent(
                            "Choisissez une image",
                            textcolor: textinputcolor.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
            ),
            if (pickedFile != null) ...[
              const SizedBox(height: 10),
              const TextComponent(
                "Cliquez sur l'image pour la remplacer, si besoin",
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
