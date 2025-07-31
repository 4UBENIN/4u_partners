import 'dart:io';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:for_u_partners/ui/common/text_component.dart';

class RegisterProfileViewModel extends FormViewModel {
  bool? hasVehicle;
  //* Deliver
  PlatformFile? deliverCarteGrise;
  PlatformFile? deliverAssurance;
  //* Car
  PlatformFile? driverIdentity;
  PlatformFile? driverCarCarteGrise;
  PlatformFile? driverCarAssurance;
  PlatformFile? driverCarPermis;
  PlatformFile? driverNoCarPermis;
  //* Moto
  PlatformFile? driverMotoCarteGrise;
  PlatformFile? driverMotoAssurance;
  //* Cleaning
  PlatformFile? cleaningIdenty;

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

  final _navigationService = locator<NavigationService>();

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

  void registerEnding(String selectedProfile) {
    if (selectedProfile == "Pressing") {
      _navigationService.replaceWithNavBarPressingView();
    } else if (selectedProfile == "Conducteur") {
      _navigationService.replaceWithHomemainView();
    } else if (selectedProfile == "Livreur/Coursier") {
      _navigationService.replaceWithDeliveryNavBarView();
    } else if (selectedProfile == "Garagiste") {
    } else if (selectedProfile == "Agent d'entretien") {}
  }

  Future uploadFileFromMobile(PlatformFile? pickedFile) async {
    final file = await FilePicker.platform.pickFiles();

    if (file == null) return;

    pickedFile = file.files.first;
    rebuildUi();
  }

  Widget uploadFileComponent(
    String label,
    PlatformFile? pickedFile,
    void Function(PlatformFile file) onFilePicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(label, fontsize: 16),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final permission = await Permission.photos.request();
            if (!permission.isGranted) {
              print("Permission refusée");
              return;
            }

            final file = await FilePicker.platform.pickFiles();
            if (file != null) {
              onFilePicked(file.files.first);
              rebuildUi();
            }
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
                          File(pickedFile.path!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: TextComponent(
                          "Choisissez un fichier",
                          textcolor: textinputcolor.withOpacity(0.5),
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
