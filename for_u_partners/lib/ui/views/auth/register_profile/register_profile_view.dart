import 'dart:io';
import 'dart:ui';

import 'package:for_u_partners/app/models/register_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'register_profile_view.form.dart';
import 'register_profile_viewmodel.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/app_dropdown.dart';
import 'package:for_u_partners/ui/common/app_textInput.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

@FormView(fields: [
  //* General
  FormTextField(name: 'phoneNumberInput'),
  FormTextField(name: 'passwordInput'),
  //* Pressing
  FormTextField(name: 'pressingNameInput'),
  FormTextField(name: 'pressingLocalisationInput'),
  //* Livreur/Coursier
  FormTextField(name: 'deliverNameInput'),
  FormTextField(name: 'deliverSurnameInput'),
  FormTextField(name: 'deliverMailInput'),
  FormTextField(name: 'deliverImmatriculationInput'),
  //* Conducteur
  FormTextField(name: 'driverNameInput'),
  FormTextField(name: 'driverSurnameInput'),
  FormTextField(name: 'driverGenderInput'),
  FormTextField(name: 'driverMailInput'),
  FormTextField(name: 'driverAdresseInput'),
  //* has a Moto, Tricycle
  FormTextField(name: 'driverImmatriculationBikeInput'),
  //* has a Car
  FormTextField(name: 'driverCarColorInput'),
  FormTextField(name: 'driverCarBrandInput'),
  FormTextField(name: 'driverCarModelInput'),
  FormTextField(name: 'driverCarYearInput'),
  FormTextField(name: 'driverImmatriculationCarInput'),
  FormTextField(name: 'driverCarPlacesInput'),

  //* Entretien
  FormTextField(name: 'cleaningNameInput'),
  FormTextField(name: 'cleaningSurnameInput'),
  //* Garage
  FormTextField(name: 'garageNameInput'),
  FormTextField(name: 'garageLocalisationInput'),
])
class RegisterProfileView extends StackedView<RegisterProfileViewModel>
    with $RegisterProfileView {
  final String selectedProfile;
  final String phoneNumber;
  final String mail;
  final String password;

  const RegisterProfileView(
      this.selectedProfile, this.phoneNumber, this.mail, this.password,
      {Key? key})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterProfileViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Move4u'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Profile
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: RichText(
                    text: TextSpan(
                      text: 'Je suis un ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "$selectedProfile, ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),

                //* Welcome message
                const TextComponent(
                  "Bienvenue à Move4u, veuillez remplir le formulaire ci-dessous pour finaliser la création de votre compte.",
                  fontsize: 15,
                ),
                const SizedBox(height: 20),

                //* Section by Profile
                _buildSectionByProfile(selectedProfile, viewModel),

                Padding(
                  padding: const EdgeInsets.only(bottom: 34),
                  child: SizedBox(
                    height: 70,
                    child: PrimaryButton(
                        text: "Soumettre",
                        onPressed: () {
                          switch (selectedProfile) {
                            case 'pressing':
                              RegistrationModel model = RegistrationModel(
                                  type: selectedProfile,
                                  telephone: phoneNumber,
                                  dateNaissance: '',
                                  email: mail,
                                  code: "",
                                  motDePasse: password,
                                  motDePasseConfirmation: password,
                                  nom: pressingNameInputController.text,
                                  adresse:
                                      pressingLocalisationInputController.text);
                              viewModel.registerEnding(model, context);
                              break;
                            case 'conducteur':
                              if (viewModel.hasVehicle == true) {
                                print("=== CONDUCTEUR AVEC VEHICULE ===");
                                VehiculeModel vehiculemodel = VehiculeModel(
                                  type: viewModel.selectedVehicle,
                                  marque: driverCarBrandInputController.text,
                                  modele: driverCarModelInputController.text,
                                  immatriculation:
                                      driverImmatriculationCarInputController
                                          .text,
                                  nombrePlaces: int.tryParse(
                                      driverCarPlacesInputController.text),
                                  couleur: driverCarColorInputController.text,
                                  categorie: viewModel.selectedCategory,
                                  annee: int.tryParse(
                                      driverCarYearInputController.text),
                                  cartegrise: viewModel.driverCarCarteGrise !=
                                          null
                                      ? File(
                                          viewModel.driverCarCarteGrise!.path)
                                      : null,
                                  permis: viewModel.driverCarPermis != null
                                      ? File(viewModel.driverCarPermis!.path)
                                      : null,
                                  assurance: viewModel.driverCarAssurance !=
                                          null
                                      ? File(viewModel.driverCarAssurance!.path)
                                      : null,
                                );

                                RegistrationModel model = RegistrationModel(
                                  type: selectedProfile,
                                  telephone: phoneNumber,
                                  email: mail,
                                  code: "1234",
                                  genre: viewModel.selectedGender,
                                  motDePasse: password,
                                  motDePasseConfirmation: password,
                                  nom: driverNameInputController.text,
                                  prenom: driverSurnameInputController.text,
                                  adresse: driverAdresseInputController.text,
                                  dateNaissance: "1990-01-15",
                                  numeroPermis: "TEMP_PERMIS",
                                  dateExpirationPermis: "2030-12-31",
                                  documentIdentite:
                                      viewModel.driverIdentity != null
                                          ? File(viewModel.driverIdentity!.path)
                                          : null,
                                  possedeVehicule: 1,
                                  typeConducteurId:
                                      1, // Dans le curl c'est 2, pas 1
                                  vehicule: vehiculemodel,
                                );

                                print("=== MODEL AVANT ENVOI ===");
                                print("Type: ${model.type}");
                                print("Email: ${model.email}");
                                print("Telephone: ${model.telephone}");
                                print("Code: ${model.code}");
                                print("Nom: ${model.nom}");
                                print("Prenom: ${model.prenom}");
                                print("Genre: ${model.genre}");
                                print("Date naissance: ${model.dateNaissance}");
                                print("Adresse: ${model.adresse}");
                                print("Numero permis: ${model.numeroPermis}");
                                print(
                                    "Date expiration permis: ${model.dateExpirationPermis}");
                                print(
                                    "Possède véhicule: ${model.possedeVehicule}");
                                print(
                                    "Type conducteur ID: ${model.typeConducteurId}");
                                print(
                                    "Document identité: ${model.documentIdentite?.path}");
                                if (model.vehicule != null) {
                                  print(
                                      "Véhicule type: ${model.vehicule!.type}");
                                  print(
                                      "Véhicule marque: ${model.vehicule!.marque}");
                                  print(
                                      "Véhicule modele: ${model.vehicule!.modele}");
                                  print(
                                      "Véhicule immatriculation: ${model.vehicule!.immatriculation}");
                                }
                                print("=== FIN MODEL DEBUG ===");

                                viewModel.registerEnding(model, context);
                              } else {
                                print("=== CONDUCTEUR SANS VEHICULE ===");
                                RegistrationModel model = RegistrationModel(
                                  type: selectedProfile,
                                  telephone: phoneNumber,
                                  email: mail,
                                  code: "1234", // Même remarque pour le code
                                  genre: viewModel.selectedGender,
                                  motDePasse: password,
                                  motDePasseConfirmation: password,
                                  nom: driverNameInputController.text,
                                  prenom: driverSurnameInputController.text,
                                  adresse: driverAdresseInputController.text,
                                  dateNaissance: "1990-01-15", // À adapter
                                  numeroPermis: "TEMP_PERMIS",
                                  dateExpirationPermis: "2030-12-31",
                                  documentIdentite:
                                      viewModel.driverIdentity != null
                                          ? File(viewModel.driverIdentity!.path)
                                          : null,
                                  possedeVehicule: 0,
                                  typeConducteurId: 1, // Dans le curl c'est 2
                                );
                                print("=== MODEL AVANT ENVOI ===");
                                print("Type: ${model.type}");
                                print("Email: ${model.email}");
                                print("Telephone: ${model.telephone}");
                                print("Code: ${model.code}");
                                print("Nom: ${model.nom}");
                                print("Prenom: ${model.prenom}");
                                print("Genre: ${model.genre}");
                                print("Date naissance: ${model.dateNaissance}");
                                print("Adresse: ${model.adresse}");
                                print("Numero permis: ${model.numeroPermis}");
                                print(
                                    "Date expiration permis: ${model.dateExpirationPermis}");
                                print(
                                    "Possède véhicule: ${model.possedeVehicule}");
                                print(
                                    "Type conducteur ID: ${model.typeConducteurId}");
                                print(
                                    "Document identité: ${model.documentIdentite?.path}");
                                if (model.vehicule != null) {
                                  print(
                                      "Véhicule type: ${model.vehicule!.type}");
                                  print(
                                      "Véhicule marque: ${model.vehicule!.marque}");
                                  print(
                                      "Véhicule modele: ${model.vehicule!.modele}");
                                  print(
                                      "Véhicule immatriculation: ${model.vehicule!.immatriculation}");
                                }
                                print("=== FIN MODEL DEBUG ===");
                                viewModel.registerEnding(model, context);
                              }
                              break;
                            //* LIVREUR
                            case 'livreur':
                              if (viewModel.hasVehicle == true) {
                                print("=== LIVREUR AVEC VEHICULE ===");
                                VehiculeModel vehiculemodel = VehiculeModel(
                                  type: viewModel.selectedVehicle,
                                  marque: driverCarBrandInputController.text,
                                  modele: driverCarModelInputController.text,
                                  immatriculation:
                                      driverImmatriculationCarInputController
                                          .text,
                                  nombrePlaces: int.tryParse(
                                      driverCarPlacesInputController.text),
                                  couleur: driverCarColorInputController.text,
                                  categorie: viewModel.selectedCategory,
                                  annee: int.tryParse(
                                      driverCarYearInputController.text),
                                  cartegrise: viewModel.driverCarCarteGrise !=
                                          null
                                      ? File(
                                          viewModel.driverCarCarteGrise!.path)
                                      : null,
                                  permis: viewModel.driverCarPermis != null
                                      ? File(viewModel.driverCarPermis!.path)
                                      : null,
                                  assurance: viewModel.driverCarAssurance !=
                                          null
                                      ? File(viewModel.driverCarAssurance!.path)
                                      : null,
                                );

                                RegistrationModel model = RegistrationModel(
                                  type: 'conducteur',
                                  telephone: phoneNumber,
                                  email: mail,
                                  code: "1234",
                                  genre: viewModel.selectedGender,
                                  motDePasse: password,
                                  motDePasseConfirmation: password,
                                  nom: driverNameInputController.text,
                                  prenom: driverSurnameInputController.text,
                                  adresse: driverAdresseInputController.text,
                                  dateNaissance: "1990-01-15",
                                  numeroPermis: "TEMP_PERMIS",
                                  dateExpirationPermis: "2030-12-31",
                                  documentIdentite:
                                      viewModel.driverIdentity != null
                                          ? File(viewModel.driverIdentity!.path)
                                          : null,
                                  possedeVehicule: 1,
                                  typeConducteurId: 2,
                                  vehicule: vehiculemodel,
                                );

                                print("=== MODEL AVANT ENVOI ===");
                                print("Type: ${model.type}");
                                print("Email: ${model.email}");
                                print("Telephone: ${model.telephone}");
                                print("Code: ${model.code}");
                                print("Nom: ${model.nom}");
                                print("Prenom: ${model.prenom}");
                                print("Genre: ${model.genre}");
                                print("Date naissance: ${model.dateNaissance}");
                                print("Adresse: ${model.adresse}");
                                print("Numero permis: ${model.numeroPermis}");
                                print(
                                    "Date expiration permis: ${model.dateExpirationPermis}");
                                print(
                                    "Possède véhicule: ${model.possedeVehicule}");
                                print(
                                    "Type conducteur ID: ${model.typeConducteurId}");
                                print(
                                    "Document identité: ${model.documentIdentite?.path}");
                                if (model.vehicule != null) {
                                  print(
                                      "Véhicule type: ${model.vehicule!.type}");
                                  print(
                                      "Véhicule marque: ${model.vehicule!.marque}");
                                  print(
                                      "Véhicule modele: ${model.vehicule!.modele}");
                                  print(
                                      "Véhicule immatriculation: ${model.vehicule!.immatriculation}");
                                }
                                print("=== FIN MODEL DEBUG ===");

                                viewModel.registerEnding(model, context);
                              } else {
                                print("=== LIVREUR SANS VEHICULE ===");
                                RegistrationModel model = RegistrationModel(
                                  type: 'conducteur',
                                  telephone: phoneNumber,
                                  email: mail,
                                  code: "1234", // Même remarque pour le code
                                  genre: viewModel.selectedGender,
                                  motDePasse: password,
                                  motDePasseConfirmation: password,
                                  nom: driverNameInputController.text,
                                  prenom: driverSurnameInputController.text,
                                  adresse: driverAdresseInputController.text,
                                  dateNaissance: "1990-01-15", // À adapter
                                  numeroPermis: "TEMP_PERMIS",
                                  dateExpirationPermis: "2030-12-31",
                                  documentIdentite:
                                      viewModel.driverIdentity != null
                                          ? File(viewModel.driverIdentity!.path)
                                          : null,
                                  possedeVehicule: 0,
                                  typeConducteurId: 2,
                                );
                                print("=== MODEL AVANT ENVOI ===");
                                print("Type: ${model.type}");
                                print("Email: ${model.email}");
                                print("Telephone: ${model.telephone}");
                                print("Code: ${model.code}");
                                print("Nom: ${model.nom}");
                                print("Prenom: ${model.prenom}");
                                print("Genre: ${model.genre}");
                                print("Date naissance: ${model.dateNaissance}");
                                print("Adresse: ${model.adresse}");
                                print("Numero permis: ${model.numeroPermis}");
                                print(
                                    "Date expiration permis: ${model.dateExpirationPermis}");
                                print(
                                    "Possède véhicule: ${model.possedeVehicule}");
                                print(
                                    "Type conducteur ID: ${model.typeConducteurId}");
                                print(
                                    "Document identité: ${model.documentIdentite?.path}");
                                if (model.vehicule != null) {
                                  print(
                                      "Véhicule type: ${model.vehicule!.type}");
                                  print(
                                      "Véhicule marque: ${model.vehicule!.marque}");
                                  print(
                                      "Véhicule modele: ${model.vehicule!.modele}");
                                  print(
                                      "Véhicule immatriculation: ${model.vehicule!.immatriculation}");
                                }
                                print("=== FIN MODEL DEBUG ===");
                                viewModel.registerEnding(model, context);
                              }
                              break;
                            default:
                              break;
                          }
                        }),
                  ),
                ),
              ],
            ),
            if (viewModel.isBusy)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.black.withOpacity(0.0),
                    child: Center(
                      child: LoadingAnimationWidget.inkDrop(
                        color: kcPrimaryColor,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _buildSectionByProfile(String profile, dynamic viewModel) {
    switch (profile) {
      //* Pressing
      case 'pressing':
        return Column(
          children: [
            //* Nom du pressing
            TextInputField(
              bigLabel: "Nom du pressing",
              hintText: "Pressing Le Soleil",
              controller: pressingNameInputController,
            ),
            const SizedBox(height: 20),

            //* Localisation du pressing
            TextInputField(
              bigLabel: "Localisation du pressing",
              hintText: "Saint Michel, En face de l'église",
              controller: pressingLocalisationInputController,
            ),
            const SizedBox(height: 20),
          ],
        );

      //* Livreur/Coursier
      case 'livreur':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Nom du conducteur
            TextInputField(
              bigLabel: "Nom",
              hintText: "DOUNOU",
              controller: driverSurnameInputController,
            ),
            const SizedBox(height: 20),

            //* Prénom du conducteur
            TextInputField(
              bigLabel: "Prénom",
              hintText: "Bastien",
              controller: driverNameInputController,
            ),
            const SizedBox(height: 20),

            CustomDropdown(
              title: "Genre",
              items: viewModel.genders,
              value: viewModel.selectedGender,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setSelectedGender(value);
                }
              },
            ),
            const SizedBox(height: 20),
            //* Adresse du conducteur
            TextInputField(
              bigLabel: "Adresse",
              hintText: "123 rue de la paix",
              controller: driverAdresseInputController,
            ),
            const SizedBox(height: 20),

            //* Pièce d'identité du conducteur
            viewModel.uploadFileComponent(
                "Pièce d'identité",
                viewModel.driverIdentity,
                (file) => viewModel.driverIdentity = file),
            const SizedBox(height: 20),

            //* Possesion d'un vehicule
            const TextComponent(
              "Possedez vous un véhicule ?",
              fontsize: 16,
            ),
            const SizedBox(height: 5),
            const TextComponent(
              "Une voiture, une moto ou un tricycle",
              fontsize: 14,
              textcolor: mediumGrey,
            ),
            const SizedBox(height: 10),
            //* Radio
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: viewModel.hasVehicle,
                  onChanged: (value) {
                    if (value != null) viewModel.setHasVehicle(value);
                  },
                ),
                const TextComponent(
                  "Oui",
                  fontsize: 15,
                ),
                const SizedBox(width: 50),
                Radio<bool>(
                  value: false,
                  groupValue: viewModel.hasVehicle,
                  onChanged: (value) {
                    if (value != null) viewModel.setHasVehicle(value);
                  },
                ),
                const TextComponent(
                  "Non",
                  fontsize: 15,
                ),
              ],
            ),

            //* Type de véhicule
            const SizedBox(height: 20),
            ...(viewModel.hasVehicle == null
                ? []

                //* OUI POSSEDE UN VEHICULE
                : viewModel.hasVehicle == true
                    ? [
                        CustomDropdown(
                          title: "Quel type de véhicule avez vous ?",
                          items: viewModel.vehicles,
                          value: viewModel.selectedVehicle,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setSelectedVehicle(value);
                            }
                          },
                        ),

                        //* OUI Moto, Tricycle
                        if (viewModel.selectedVehicle == "moto" ||
                            viewModel.selectedVehicle == "tricycle") ...[
                          const SizedBox(height: 20),
                          //* Carte grise
                          viewModel.uploadFileComponent(
                              "Carte grise",
                              viewModel.driverMotoCarteGrise,
                              (file) => viewModel.driverMotoCarteGrise = file),
                          const SizedBox(height: 20),

                          //* Assurance
                          viewModel.uploadFileComponent(
                              "Assurance",
                              viewModel.driverMotoAssurance,
                              (file) => viewModel.driverMotoAssurance = file),
                          const SizedBox(height: 20),

                          TextInputField(
                            bigLabel: "Modèle du véhicule",
                            hintText: "Ex: Toyota Yaris",
                            controller: driverCarModelInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Immatriculation
                          TextInputField(
                            bigLabel: "Immatriculation du véhicule",
                            hintText: "Votre immatriculation",
                            controller: driverImmatriculationCarInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Nombre de places
                          Builder(
                            builder: (context) {
                              // Set the seat number based on vehicle type
                              if (viewModel.selectedVehicle == 'moto') {
                                driverCarPlacesInputController.text = '1';
                              } else if (viewModel.selectedVehicle == 'tricycle') {
                                driverCarPlacesInputController.text = '3';
                              }
                              
                              return TextInputField(
                                bigLabel: "Nombre de places",
                                hintText: viewModel.getSeatNumberHint(),
                                controller: driverCarPlacesInputController,
                                enabled: viewModel.isSeatNumberEditable(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          //* Année de sortie
                          TextInputField(
                            bigLabel: "Année du véhicule",
                            hintText: "Ex: 2008",
                            controller: driverCarYearInputController,
                          ),
                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                        ],

                        //* OUI Voiture
                        if (viewModel.selectedVehicle == "voiture") ...[
                          const SizedBox(height: 20),
                          //* Permis
                          viewModel.uploadFileComponent(
                              "Permis de conduire",
                              viewModel.driverCarPermis,
                              (file) => viewModel.driverCarPermis = file),
                          const SizedBox(height: 20),

                          //* Carte grise
                          viewModel.uploadFileComponent(
                              "Carte grise",
                              viewModel.driverCarCarteGrise,
                              (file) => viewModel.driverCarCarteGrise = file),
                          const SizedBox(height: 20),

                          //* Assurance
                          viewModel.uploadFileComponent(
                              "Assurance",
                              viewModel.driverCarAssurance,
                              (file) => viewModel.driverCarAssurance = file),
                          const SizedBox(height: 20),

                          //* Couleur
                          TextInputField(
                            bigLabel: "Couleur du véhicule",
                            hintText: "Ex: Rouge",
                            controller: driverCarColorInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Marque
                          TextInputField(
                            bigLabel: "Marque du véhicule",
                            hintText: "Ex: Toyota",
                            controller: driverCarBrandInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Modèle
                          TextInputField(
                            bigLabel: "Modèle du véhicule",
                            hintText: "Ex: Toyota Yaris",
                            controller: driverCarModelInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Immatriculation
                          TextInputField(
                            bigLabel: "Immatriculation du véhicule",
                            hintText: "Votre immatriculation",
                            controller: driverImmatriculationCarInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Nombre de places
                          Builder(
                            builder: (context) {
                              // Set the seat number based on vehicle type
                              if (viewModel.selectedVehicle == 'moto') {
                                driverCarPlacesInputController.text = '1';
                              } else if (viewModel.selectedVehicle == 'tricycle') {
                                driverCarPlacesInputController.text = '3';
                              }
                              
                              return TextInputField(
                                bigLabel: "Nombre de places",
                                hintText: viewModel.getSeatNumberHint(),
                                controller: driverCarPlacesInputController,
                                enabled: viewModel.isSeatNumberEditable(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          //* Année de sortie
                          TextInputField(
                            bigLabel: "Année du véhicule",
                            hintText: "Ex: 2008",
                            controller: driverCarYearInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Catégorie
                          CustomDropdown(
                            title: "Catégorie du véhicule",
                            items: viewModel.categories,
                            value: viewModel.selectedCategory,
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.setSelectedCategory(value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ]

                    //* NON PAS DE VEHICULE
                    : [
                        CustomDropdown(
                          title: "Quel type de véhicule pouvez-vous utiliser ?",
                          items: viewModel.wantedVehicles,
                          value: viewModel.wantedVehicle,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setWantedVehicle(value);
                            }
                          },
                        ),

                        //* SI NON Voiture
                        if (viewModel.wantedVehicle == "Voiture") ...[
                          const SizedBox(height: 20),
                          //* Permis
                          viewModel.uploadFileComponent(
                              "Permis de conduire",
                              viewModel.driverNoCarPermis,
                              (file) => viewModel.driverNoCarPermis = file),
                          const SizedBox(height: 20),
                        ],

                        //* SI NON Moto ou Tricycle
                        if (viewModel.wantedVehicle == "Moto" ||
                            viewModel.wantedVehicle == "Tricycle") ...[
                          const SizedBox(height: 20),
                          //* Rien
                          const TextComponent(
                            "Pas de problème, veuillez cliquer sur le bouton pour finaliser votre inscription !",
                            fontsize: 16,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ]),
          ],
        );

      //* Conducteur
      case 'conducteur':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Nom du conducteur
            TextInputField(
              bigLabel: "Nom",
              hintText: "DOUNOU",
              controller: driverSurnameInputController,
            ),
            const SizedBox(height: 20),

            //* Prénom du conducteur
            TextInputField(
              bigLabel: "Prénom",
              hintText: "Bastien",
              controller: driverNameInputController,
            ),
            const SizedBox(height: 20),

            CustomDropdown(
              title: "Genre",
              items: viewModel.genders,
              value: viewModel.selectedGender,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setSelectedGender(value);
                }
              },
            ),
            const SizedBox(height: 20),
            //* Adresse du conducteur
            TextInputField(
              bigLabel: "Adresse",
              hintText: "123 rue de la paix",
              controller: driverAdresseInputController,
            ),
            const SizedBox(height: 20),

            //* Pièce d'identité du conducteur
            viewModel.uploadFileComponent(
                "Pièce d'identité",
                viewModel.driverIdentity,
                (file) => viewModel.driverIdentity = file),
            const SizedBox(height: 20),

            //* Possesion d'un vehicule
            const TextComponent(
              "Possedez vous un véhicule ?",
              fontsize: 16,
            ),
            const SizedBox(height: 5),
            const TextComponent(
              "Une voiture, une moto ou un tricycle",
              fontsize: 14,
              textcolor: mediumGrey,
            ),
            const SizedBox(height: 10),
            //* Radio
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: viewModel.hasVehicle,
                  onChanged: (value) {
                    if (value != null) viewModel.setHasVehicle(value);
                  },
                ),
                const TextComponent(
                  "Oui",
                  fontsize: 15,
                ),
                const SizedBox(width: 50),
                Radio<bool>(
                  value: false,
                  groupValue: viewModel.hasVehicle,
                  onChanged: (value) {
                    if (value != null) viewModel.setHasVehicle(value);
                  },
                ),
                const TextComponent(
                  "Non",
                  fontsize: 15,
                ),
              ],
            ),

            //* Type de véhicule
            const SizedBox(height: 20),
            ...(viewModel.hasVehicle == null
                ? []

                //* OUI POSSEDE UN VEHICULE
                : viewModel.hasVehicle == true
                    ? [
                        CustomDropdown(
                          title: "Quel type de véhicule avez vous ?",
                          items: viewModel.vehicles,
                          value: viewModel.selectedVehicle,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setSelectedVehicle(value);
                            }
                          },
                        ),

                        //* OUI Moto, Tricycle
                        if (viewModel.selectedVehicle == "moto" ||
                            viewModel.selectedVehicle == "tricycle") ...[
                          const SizedBox(height: 20),
                          //* Carte grise
                          viewModel.uploadFileComponent(
                              "Carte grise",
                              viewModel.driverMotoCarteGrise,
                              (file) => viewModel.driverMotoCarteGrise = file),
                          const SizedBox(height: 20),

                          //* Assurance
                          viewModel.uploadFileComponent(
                              "Assurance",
                              viewModel.driverMotoAssurance,
                              (file) => viewModel.driverMotoAssurance = file),
                          const SizedBox(height: 20),

                          TextInputField(
                            bigLabel: "Modèle du véhicule",
                            hintText: "Ex: Toyota Yaris",
                            controller: driverCarModelInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Immatriculation
                          TextInputField(
                            bigLabel: "Immatriculation du véhicule",
                            hintText: "Votre immatriculation",
                            controller: driverImmatriculationCarInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Nombre de places
                          Builder(
                            builder: (context) {
                              // Set the seat number based on vehicle type
                              if (viewModel.selectedVehicle == 'moto') {
                                driverCarPlacesInputController.text = '1';
                              } else if (viewModel.selectedVehicle == 'tricycle') {
                                driverCarPlacesInputController.text = '3';
                              }
                              
                              return TextInputField(
                                bigLabel: "Nombre de places",
                                hintText: viewModel.getSeatNumberHint(),
                                controller: driverCarPlacesInputController,
                                enabled: viewModel.isSeatNumberEditable(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          //* Année de sortie
                          TextInputField(
                            bigLabel: "Année du véhicule",
                            hintText: "Ex: 2008",
                            controller: driverCarYearInputController,
                          ),
                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                        ],

                        //* OUI Voiture
                        if (viewModel.selectedVehicle == "voiture") ...[
                          const SizedBox(height: 20),
                          //* Permis
                          viewModel.uploadFileComponent(
                              "Permis de conduire",
                              viewModel.driverCarPermis,
                              (file) => viewModel.driverCarPermis = file),
                          const SizedBox(height: 20),

                          //* Carte grise
                          viewModel.uploadFileComponent(
                              "Carte grise",
                              viewModel.driverCarCarteGrise,
                              (file) => viewModel.driverCarCarteGrise = file),
                          const SizedBox(height: 20),

                          //* Assurance
                          viewModel.uploadFileComponent(
                              "Assurance",
                              viewModel.driverCarAssurance,
                              (file) => viewModel.driverCarAssurance = file),
                          const SizedBox(height: 20),

                          //* Couleur
                          TextInputField(
                            bigLabel: "Couleur du véhicule",
                            hintText: "Ex: Rouge",
                            controller: driverCarColorInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Marque
                          TextInputField(
                            bigLabel: "Marque du véhicule",
                            hintText: "Ex: Toyota",
                            controller: driverCarBrandInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Modèle
                          TextInputField(
                            bigLabel: "Modèle du véhicule",
                            hintText: "Ex: Toyota Yaris",
                            controller: driverCarModelInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Immatriculation
                          TextInputField(
                            bigLabel: "Immatriculation du véhicule",
                            hintText: "Votre immatriculation",
                            controller: driverImmatriculationCarInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Nombre de places
                          Builder(
                            builder: (context) {
                              // Set the seat number based on vehicle type
                              if (viewModel.selectedVehicle == 'moto') {
                                driverCarPlacesInputController.text = '1';
                              } else if (viewModel.selectedVehicle == 'tricycle') {
                                driverCarPlacesInputController.text = '3';
                              }
                              
                              return TextInputField(
                                bigLabel: "Nombre de places",
                                hintText: viewModel.getSeatNumberHint(),
                                controller: driverCarPlacesInputController,
                                enabled: viewModel.isSeatNumberEditable(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          //* Année de sortie
                          TextInputField(
                            bigLabel: "Année du véhicule",
                            hintText: "Ex: 2008",
                            controller: driverCarYearInputController,
                          ),
                          const SizedBox(height: 20),

                          //* Catégorie
                          CustomDropdown(
                            title: "Catégorie du véhicule",
                            items: viewModel.categories,
                            value: viewModel.selectedCategory,
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.setSelectedCategory(value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ]

                    //* NON PAS DE VEHICULE
                    : [
                        CustomDropdown(
                          title: "Quel type de véhicule pouvez-vous utiliser ?",
                          items: viewModel.wantedVehicles,
                          value: viewModel.wantedVehicle,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setWantedVehicle(value);
                            }
                          },
                        ),

                        //* SI NON Voiture
                        if (viewModel.wantedVehicle == "Voiture") ...[
                          const SizedBox(height: 20),
                          //* Permis
                          viewModel.uploadFileComponent(
                              "Permis de conduire",
                              viewModel.driverNoCarPermis,
                              (file) => viewModel.driverNoCarPermis = file),
                          const SizedBox(height: 20),
                        ],

                        //* SI NON Moto ou Tricycle
                        if (viewModel.wantedVehicle == "Moto" ||
                            viewModel.wantedVehicle == "Tricycle") ...[
                          const SizedBox(height: 20),
                          //* Rien
                          const TextComponent(
                            "Pas de problème, veuillez cliquer sur le bouton pour finaliser votre inscription !",
                            fontsize: 16,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ]),
          ],
        );

      //* Agent d'entretien
      case "agent d'entretien":
        return Column(
          children: [
            //* Nom de l'agent
            TextInputField(
              bigLabel: "Nom",
              hintText: "SALANON",
              controller: cleaningSurnameInputController,
            ),
            const SizedBox(height: 20),

            //* Prénom de l'agent
            TextInputField(
              bigLabel: "Prénom",
              hintText: "Patrick",
              controller: cleaningNameInputController,
            ),
            const SizedBox(height: 20),

            //* Pièce d'identité de l'agent
            viewModel.uploadFileComponent(
                "Pièce d'identité",
                viewModel.cleaningIdentity,
                (file) => viewModel.cleaningIdentity = file),
            const SizedBox(height: 20),
          ],
        );

      //* Garagiste
      case 'garagiste':
        return Column(
          children: [
            //* Nom du Garage
            TextInputField(
              bigLabel: "Nom du Garage",
              hintText: "Chez Le Super Garagiste",
              controller: garageNameInputController,
            ),
            const SizedBox(height: 20),

            //* Localisation du garage
            TextInputField(
              bigLabel: "Localisation du garage",
              hintText: "Saint Michel, En face de l'église",
              controller: garageLocalisationInputController,
            ),
            const SizedBox(height: 20),
          ],
        );

      default:
        return const Center(child: Text("Profil inconnu"));
    }
  }

  @override
  void onViewModelReady(RegisterProfileViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(RegisterProfileViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  RegisterProfileViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterProfileViewModel();
}
