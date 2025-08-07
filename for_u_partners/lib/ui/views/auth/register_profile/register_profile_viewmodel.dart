import 'dart:io';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/services/auth_service.dart';
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

  //* Deliver
  XFile? deliverCarteGrise;
  XFile? deliverAssurance;

  //* Car
  XFile? driverIdentity;
  XFile? driverCarCarteGrise;
  XFile? driverCarAssurance;
  XFile? driverCarPermis;
  XFile? driverNoCarPermis;

  //* Moto
  XFile? driverMotoCarteGrise;
  XFile? driverMotoAssurance;

  //* Cleaning
  XFile? cleaningIdentity;

  final vehicles = [
    "Moto",
    "Voiture",
    "Tricycle",
  ];

  final wantedVehicles = [
    "Moto",
    "Voiture",
    "Tricycle",
  ];

  String _selectedVehicle = "Moto";
  String get selectedVehicle => _selectedVehicle;

  String _wantedVehicle = "Moto";
  String get wantedVehicle => _wantedVehicle;

  final _authService = locator<AuthService>();
  final ImagePicker _picker = ImagePicker();

  //* Functions

  void setSelectedVehicle(String value) {
    _selectedVehicle = value;
    rebuildUi();
  }

  void setWantedVehicle(String value) {
    _wantedVehicle = value;
    rebuildUi();
  }

  void setHasVehicle(bool value) {
    hasVehicle = value;
    rebuildUi();
  }

  Future<void> registerEnding(RegistrationModel model) async {
    setBusy(true);
    // print("Register Ending");
    try {
      // print("Register");
      await _authService.register(model);
    } catch (e) {
      setBusy(false);
    }
  }

  Future<void> _pickImage(void Function(XFile file) onImagePicked) async {
    try {
      // Demander les permissions nécessaires
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.request();
        final photosPermission = await Permission.photos.request();

        if (!storagePermission.isGranted && !photosPermission.isGranted) {
          print("Permission refusée");
          return;
        }
      }

      // Afficher un dialog pour choisir la source
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
              // Handle bar élégant
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

              // ListTiles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Galerie
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

                    // Appareil photo
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

              // Bouton Annuler stylisé
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
              pickedFile != null
                  ? const SizedBox(height: 10)
                  : const SizedBox(height: 0),
              pickedFile != null
                  ? const TextComponent(
                      "Cliquez sur l'image pour la remplacer, si besoin",
                      textcolor: primaryColor,
                    )
                  : const TextComponent("")
            ],
          ),
        ),
      ],
    );
  }
}
