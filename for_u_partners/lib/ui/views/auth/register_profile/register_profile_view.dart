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
  FormTextField(name: 'driverMailInput'),
  //* has a Moto, Tricycle
  FormTextField(name: 'driverImmatriculationBikeInput'),
  //* has a Car
  FormTextField(name: 'driverCarColorInput'),
  FormTextField(name: 'driverCarBrandInput'),
  FormTextField(name: 'driverCarModelInput'),
  FormTextField(name: 'driverCarYearInput'),
  FormTextField(name: 'driverImmatriculationCarInput'),
  //* Entretien
  FormTextField(name: 'cleaningNameInput'),
  FormTextField(name: 'cleaningSurnameInput'),
  //* Pressing
  FormTextField(name: 'garageNameInput'),
  FormTextField(name: 'garageLocalisationInput'),
])
class RegisterProfileView extends StackedView<RegisterProfileViewModel>
    with $RegisterProfileView {
  final String selectedProfile;

  const RegisterProfileView(this.selectedProfile, {Key? key}) : super(key: key);

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
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 34),
        child: SizedBox(
          height: 70,
          child: PrimaryButton(
            text: "Finaliser l'inscription",
            onPressed: () => viewModel.registerEnding(selectedProfile),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionByProfile(String profile, dynamic viewModel) {
    switch (profile) {
      //* Pressing
      case 'Pressing':
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
      case 'Livreur/Coursier':
        return Column(
          children: [
            //* Nom du Livreur
            TextInputField(
              bigLabel: "Nom",
              hintText: "DOUMI",
              controller: deliverSurnameInputController,
            ),
            const SizedBox(height: 20),

            //* Prénom du Livreur
            TextInputField(
              bigLabel: "Prénom",
              hintText: "Joseph",
              controller: deliverNameInputController,
            ),
            const SizedBox(height: 20),

            //* Adresse Mail du Livreur
            TextInputField(
              bigLabel: "Adresse Mail",
              hintText: "josephdoumi@gmail.com",
              controller: deliverMailInputController,
              isEmail: true,
            ),
            const SizedBox(height: 20),

            //* Carte grise du Livreur
            viewModel.uploadFileComponent(
                "Carte grise",
                viewModel.deliverCarteGrise,
                (file) => viewModel.deliverCarteGrise = file),
            const SizedBox(height: 20),

            //* Assurance du Livreur
            viewModel.uploadFileComponent(
                "Assurance",
                viewModel.deliverAssurance,
                (file) => viewModel.deliverAssurance = file),
            const SizedBox(height: 20),

            //* Imatriculation du Livreur
            const TextInputField(
              bigLabel: "Immatriculation",
              hintText: "Votre immatriculation",
            ),
            const SizedBox(height: 20),
          ],
        );

      //* Conducteur
      case 'Conducteur':
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

            //* Adresse Mail du conducteur
            TextInputField(
              bigLabel: "Adresse Mail",
              hintText: "bastiendounou@gmail.com",
              controller: driverMailInputController,
              isEmail: true,
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
                        if (viewModel.selectedVehicle == "Moto" ||
                            viewModel.selectedVehicle == "Tricycle") ...[
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

                          //* Immatriculation
                          TextInputField(
                            bigLabel: "Immatriculation",
                            hintText: "Votre immatriculation",
                            controller:
                                driverImmatriculationBikeInputController,
                          ),
                          const SizedBox(height: 20),
                        ],

                        //* OUI Voiture
                        if (viewModel.selectedVehicle == "Voiture") ...[
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

                          //* Année de sortie
                          TextInputField(
                            bigLabel: "Année du véhicule",
                            hintText: "Ex: 2008",
                            controller: driverCarYearInputController,
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
      case "Agent d'entretien":
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
      case 'Garagiste':
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
