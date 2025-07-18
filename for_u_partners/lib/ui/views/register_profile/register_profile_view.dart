import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'register_profile_viewmodel.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/app_dropdown.dart';
import 'package:for_u_partners/ui/common/app_text_Input.dart';
import 'package:for_u_partners/ui/common/app_text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

class RegisterProfileView extends StackedView<RegisterProfileViewModel> {
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
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildSectionByProfile(String profile, dynamic viewModel) {
    switch (profile) {
      //* Pressing
      case 'Pressing':
        return const Column(
          children: [
            //* Nom du pressing
            TextInputField(
              bigLabel: "Nom du pressing",
              hintText: "Pressing Le Soleil",
            ),
            SizedBox(height: 20),

            //* Localisation du pressing
            TextInputField(
              bigLabel: "Localisation du pressing",
              hintText: "Saint Michel, En face de l'église",
            ),
            SizedBox(height: 20),
          ],
        );

      //* Livreur/Coursier
      case 'Livreur/Coursier':
        return const Column(
          children: [
            //* Nom et Prénom du Livreur
            TextInputField(
              bigLabel: "Nom et Prénom",
              hintText: "Joseph DOUMI",
            ),
            SizedBox(height: 20),

            //* Adresse Mail du Livreur
            TextInputField(
              bigLabel: "Adresse Mail",
              hintText: "josephdoumi@gmail.com",
              isEmail: true,
            ),
            SizedBox(height: 20),

            //* Carte grise du Livreur
            TextInputField(
              bigLabel: "Carte grise",
              hintText: "Votre carte grise",
            ),
            SizedBox(height: 20),

            //* Assurance du Livreur
            TextInputField(
              bigLabel: "Assurance",
              hintText: "Votre assurance",
            ),
            SizedBox(height: 20),

            //* Imatriculation du Livreur
            TextInputField(
              bigLabel: "Immatriculation",
              hintText: "Votre immatriculation",
            ),
            SizedBox(height: 20),
          ],
        );

      //* Conducteur
      case 'Conducteur':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Nom et Prénom du conducteur
            const TextInputField(
              bigLabel: "Nom et Prénom",
              hintText: "Bastien DOUNOU",
            ),
            const SizedBox(height: 20),

            //* Adresse Mail du conducteur
            const TextInputField(
              bigLabel: "Adresse Mail",
              hintText: "bastiendounou@gmail.com",
              isEmail: true,
            ),
            const SizedBox(height: 20),

            //* Pièce d'identité du conducteur
            const TextInputField(
              bigLabel: "Pièce d'identité",
              hintText: "Prenez une photo",
            ),
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
            ...(viewModel.hasVehicle == true

                //* OUI POSSEDE UN VEHICULE
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
                    if (viewModel.selectedVehicle == "Moto") ...[
                      const SizedBox(height: 20),
                      //* Carte grise
                      const TextInputField(
                        bigLabel: "Carte grise",
                        hintText: "Votre carte grise",
                      ),
                      const SizedBox(height: 20),

                      //* Assurance
                      const TextInputField(
                        bigLabel: "Assurance",
                        hintText: "Votre assurance",
                      ),
                      const SizedBox(height: 20),
                    ],

                    //* OUI Voiture
                    if (viewModel.selectedVehicle == "Voiture" ||
                        viewModel.selectedVehicle == "Tricycle") ...[
                      const SizedBox(height: 20),
                      //* Permis
                      const TextInputField(
                        bigLabel: "Permis de conduire",
                        hintText: "Votre permis de conduire",
                      ),
                      const SizedBox(height: 20),

                      //* Carte grise
                      const TextInputField(
                        bigLabel: "Carte grise",
                        hintText: "Votre carte grise",
                      ),
                      const SizedBox(height: 20),

                      //* Assurance
                      const TextInputField(
                        bigLabel: "Assurance",
                        hintText: "Votre assurance",
                      ),
                      const SizedBox(height: 20),

                      //* Couleur
                      const TextInputField(
                        bigLabel: "Couleur du véhicule",
                        hintText: "Ex: Rouge",
                      ),
                      const SizedBox(height: 20),

                      //* Couleur
                      const TextInputField(
                        bigLabel: "Marque du véhicule",
                        hintText: "Ex: Toyota",
                      ),
                      const SizedBox(height: 20),

                      //* Modèle
                      const TextInputField(
                        bigLabel: "Modèle du véhicule",
                        hintText: "Ex: Toyota Yaris",
                      ),
                      const SizedBox(height: 20),

                      //* Immatriculation
                      const TextInputField(
                        bigLabel: "Immatriculation du véhicule",
                        hintText: "Votre immatriculation",
                      ),
                      const SizedBox(height: 20),

                      //* Année de sortie
                      const TextInputField(
                        bigLabel: "Année du véhicule",
                        hintText: "Ex: 2008",
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
                      const TextInputField(
                        bigLabel: "Permis de conduire",
                        hintText: "Votre permis de conduire",
                      ),
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
        return const Column(
          children: [
            //* Nom et Prénom de l'agent
            TextInputField(
              bigLabel: "Nom et Prénom",
              hintText: "Patrick SALANON",
            ),
            SizedBox(height: 20),

            //* Pièce d'identité de l'agent
            TextInputField(
              bigLabel: "Pièce d'identité",
              hintText: "Prenez une photo",
            ),
            SizedBox(height: 20),
          ],
        );

      //* Garagiste
      case 'Garagiste':
        return const Column(
          children: [
            //* Nom du Garage
            TextInputField(
              bigLabel: "Nom du Garage",
              hintText: "Chez Le Super Garagiste",
            ),
            SizedBox(height: 20),

            //* Localisation du garage
            TextInputField(
              bigLabel: "Localisation du garage",
              hintText: "Saint Michel, En face de l'église",
            ),
            SizedBox(height: 20),
          ],
        );

      default:
        return const Center(child: Text("Profil inconnu"));
    }
  }

  @override
  RegisterProfileViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterProfileViewModel();
}
