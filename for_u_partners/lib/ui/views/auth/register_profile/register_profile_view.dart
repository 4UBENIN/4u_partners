import 'dart:io';
import 'dart:ui';

import 'package:for_u_partners/app/models/register_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
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
                        onPressed: () => _handleSubmit(viewModel, context)),
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

  void _handleSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    switch (selectedProfile) {
      case 'pressing':
        _handlePressingSubmit(viewModel, context);
        break;
      case 'conducteur':
        _handleConducteurSubmit(viewModel, context);
        break;
      case 'livreur':
        _handleLivreurSubmit(viewModel, context);
        break;
      case "agent d'entretien":
        _handleAgentEntretienSubmit(viewModel, context);
        break;
      case 'garagiste':
        _handleGaragisteSubmit(viewModel, context);
        break;
      default:
        break;
    }
  }

  void _handlePressingSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    // Validation des champs
    if (pressingNameInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nom du pressing')),
      );
      return;
    }
    
    if (pressingLocalisationInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer la localisation du pressing')),
      );
      return;
    }

    RegistrationModel model = RegistrationModel(
      type: selectedProfile,
      telephone: phoneNumber,
      dateNaissance: '',
      email: mail,
      code: "",
      motDePasse: password,
      motDePasseConfirmation: password,
      nom: pressingNameInputController.text.trim(),
      adresse: '', // Ajout du paramètre adresse manquant
    );
    viewModel.registerEnding(model, context);
  }

  void _handleConducteurSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    // Valider que l'utilisateur a répondu à la question sur le véhicule
    if (viewModel.hasVehicle == null) {
      viewModel.setShowVehicleError(true);
      // Faire défiler jusqu'au champ de sélection
      Scrollable.ensureVisible(
        context,
        alignment: 0.5, // Faites défiler pour centrer le champ
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    if (viewModel.hasVehicle == true) {
      _submitWithVehicle(viewModel, context, selectedProfile, 1);
    } else {
      _submitWithoutVehicle(viewModel, context, selectedProfile, 1);
    }
  }

  void _handleLivreurSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    // Valider que l'utilisateur a répondu à la question sur le véhicule
    if (viewModel.hasVehicle == null) {
      viewModel.setShowVehicleError(true);
      // Faire défiler jusqu'au champ de sélection
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    if (viewModel.hasVehicle == true) {
      _submitWithVehicle(viewModel, context, 'conducteur', 2);
    } else {
      _submitWithoutVehicle(viewModel, context, 'conducteur', 2);
    }
  }

  void _handleAgentEntretienSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    if (cleaningNameInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre prénom')),
      );
      return;
    }
    
    if (cleaningSurnameInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre nom')),
      );
      return;
    }
    
    if (viewModel.cleaningIdentity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez télécharger votre pièce d\'identité')),
      );
      return;
    }

    RegistrationModel model = RegistrationModel(
      type: "agent d'entretien",
      telephone: phoneNumber,
      email: mail,
      code: "1234",
      motDePasse: password,
      motDePasseConfirmation: password,
      nom: cleaningSurnameInputController.text.trim(),
      prenom: cleaningNameInputController.text.trim(),
      adresse: "",
      dateNaissance: "1990-01-15",
      documentIdentite: File(viewModel.cleaningIdentity!.path),
    );
    viewModel.registerEnding(model, context);
  }

  void _handleGaragisteSubmit(RegisterProfileViewModel viewModel, BuildContext context) {
    if (garageNameInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nom du garage')),
      );
      return;
    }
    
    if (garageLocalisationInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer la localisation du garage')),
      );
      return;
    }

    RegistrationModel model = RegistrationModel(
      type: 'garagiste',
      telephone: phoneNumber,
      email: mail,
      code: "1234",
      motDePasse: password,
      motDePasseConfirmation: password,
      nom: garageNameInputController.text.trim(),
      adresse: garageLocalisationInputController.text.trim(),
      dateNaissance: "1990-01-15",
    );
    viewModel.registerEnding(model, context);
  }

  void _validateDriverFields(RegisterProfileViewModel viewModel, BuildContext context) {
    if (driverNameInputController.text.isEmpty) {
      throw 'Veuillez entrer votre prénom';
    }
    if (driverSurnameInputController.text.isEmpty) {
      throw 'Veuillez entrer votre nom';
    }
    if (viewModel.selectedGender == null) {
      throw 'Veuillez sélectionner votre genre';
    }
    if (driverAdresseInputController.text.isEmpty) {
      throw 'Veuillez entrer votre adresse';
    }
    if (viewModel.driverIdentity == null) {
      throw 'Veuillez télécharger votre pièce d\'identité';
    }
  }

  void _validateVehicleFields(RegisterProfileViewModel viewModel) {
    if (viewModel.selectedVehicle == null) {
      throw 'Veuillez sélectionner un type de véhicule';
    }
    
    if (driverCarModelInputController.text.isEmpty) {
      throw 'Veuillez entrer le modèle du véhicule';
    }
    
    if (driverImmatriculationCarInputController.text.isEmpty) {
      throw 'Veuillez entrer l\'immatriculation du véhicule';
    }
    
    if (driverCarYearInputController.text.isEmpty) {
      throw 'Veuillez entrer l\'année du véhicule';
    }
    
    if (viewModel.selectedVehicle == 'voiture') {
      if (driverCarBrandInputController.text.isEmpty) {
        throw 'Veuillez entrer la marque du véhicule';
      }
      if (driverCarColorInputController.text.isEmpty) {
        throw 'Veuillez entrer la couleur du véhicule';
      }
      if (driverCarPlacesInputController.text.isEmpty) {
        throw 'Veuillez entrer le nombre de places';
      }
    }
  }

  void _submitWithVehicle(RegisterProfileViewModel viewModel, BuildContext context, String type, int typeConducteurId) async {
    try {
      // Validation des champs conducteur
      _validateDriverFields(viewModel, context);
      
      // Validation des champs véhicule
      _validateVehicleFields(viewModel);
      
      // Vérification des documents requis
      if (viewModel.selectedVehicle == 'voiture') {
        if (viewModel.driverCarPermis == null) {
          throw 'Veuillez télécharger votre permis de conduire';
        }
        if (viewModel.driverCarCarteGrise == null) {
          throw 'Veuillez télécharger la carte grise';
        }
        if (viewModel.driverCarAssurance == null) {
          throw 'Veuillez télécharger l\'attestation d\'assurance';
        }
      } else {
        if (viewModel.driverMotoCarteGrise == null) {
          throw 'Veuillez télécharger la carte grise';
        }
        if (viewModel.driverMotoAssurance == null) {
          throw 'Veuillez télécharger l\'attestation d\'assurance';
        }
      }
      
      print("=== $type AVEC VEHICULE ===");
      
      VehiculeModel vehiculeModel = _createVehicleModel(viewModel);
      
      RegistrationModel model = RegistrationModel(
        type: type,
        telephone: phoneNumber,
        email: mail,
        code: "1234",
        genre: viewModel.selectedGender!,
        motDePasse: password,
        motDePasseConfirmation: password,
        nom: driverSurnameInputController.text.trim(),
        prenom: driverNameInputController.text.trim(),
        adresse: driverAdresseInputController.text.trim(),
        dateNaissance: "1990-01-15",
        numeroPermis: "TEMP_PERMIS",
        dateExpirationPermis: "2030-12-31",
        documentIdentite: File(viewModel.driverIdentity!.path),
        possedeVehicule: 1,
        typeConducteurId: typeConducteurId,
        vehicule: vehiculeModel,
      );

      _printModelDebug(model);
      viewModel.registerEnding(model, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _submitWithoutVehicle(RegisterProfileViewModel viewModel, BuildContext context, String type, int typeConducteurId) {
    try {
      // Validation des champs conducteur
      _validateDriverFields(viewModel, context);
      
      print("=== $type SANS VEHICULE ===");
      
      RegistrationModel model = RegistrationModel(
        type: type,
        telephone: phoneNumber,
        email: mail,
        code: "1234",
        genre: viewModel.selectedGender!,
        motDePasse: password,
        motDePasseConfirmation: password,
        nom: driverSurnameInputController.text.trim(),
        prenom: driverNameInputController.text.trim(),
        adresse: driverAdresseInputController.text.trim(),
        dateNaissance: "1990-01-15",
        numeroPermis: "TEMP_PERMIS",
        dateExpirationPermis: "2030-12-31",
        documentIdentite: File(viewModel.driverIdentity!.path),
        possedeVehicule: 0,
        typeConducteurId: typeConducteurId,
      );
      
      _printModelDebug(model);
      viewModel.registerEnding(model, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  VehiculeModel _createVehicleModel(RegisterProfileViewModel viewModel) {
    return VehiculeModel(
      type: viewModel.selectedVehicle,
      marque: driverCarBrandInputController.text,
      modele: driverCarModelInputController.text,
      immatriculation: driverImmatriculationCarInputController.text,
      nombrePlaces: int.tryParse(driverCarPlacesInputController.text),
      couleur: driverCarColorInputController.text,
      categorie: viewModel.selectedCategory,
      annee: int.tryParse(driverCarYearInputController.text),
      cartegrise: viewModel.driverCarCarteGrise != null
          ? File(viewModel.driverCarCarteGrise!.path)
          : null,
      permis: viewModel.driverCarPermis != null
          ? File(viewModel.driverCarPermis!.path)
          : null,
      assurance: viewModel.driverCarAssurance != null
          ? File(viewModel.driverCarAssurance!.path)
          : null,
    );
  }

  void _printModelDebug(RegistrationModel model) {
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
    print("Date expiration permis: ${model.dateExpirationPermis}");
    print("Possède véhicule: ${model.possedeVehicule}");
    print("Type conducteur ID: ${model.typeConducteurId}");
    print("Document identité: ${model.documentIdentite?.path}");
    if (model.vehicule != null) {
      print("Véhicule type: ${model.vehicule!.type}");
      print("Véhicule marque: ${model.vehicule!.marque}");
      print("Véhicule modele: ${model.vehicule!.modele}");
      print("Véhicule immatriculation: ${model.vehicule!.immatriculation}");
    }
    print("=== FIN MODEL DEBUG ===");
  }

  Widget _buildSectionByProfile(String profile, RegisterProfileViewModel viewModel) {
    switch (profile) {
      //* Pressing
      case 'pressing':
        return _buildPressingSection();

      //* Livreur/Coursier
      case 'livreur':
        return _buildDriverSection(viewModel);

      //* Conducteur
      case 'conducteur':
        return _buildDriverSection(viewModel);

      //* Agent d'entretien
      case "agent d'entretien":
        return _buildCleaningSection(viewModel);

      //* Garagiste
      case 'garagiste':
        return _buildGarageSection();

      default:
        return const Center(child: Text("Profil inconnu"));
    }
  }

  Widget _buildPressingSection() {
    return Column(
      children: [
        TextInputField(
          bigLabel: "Nom du pressing",
          hintText: "Pressing Le Soleil",
          controller: pressingNameInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Localisation du pressing",
          hintText: "Saint Michel, En face de l'église",
          controller: pressingLocalisationInputController,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDriverSection(RegisterProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextInputField(
          bigLabel: "Nom",
          hintText: "DOUNOU",
          controller: driverSurnameInputController,
        ),
        const SizedBox(height: 20),
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
        TextInputField(
          bigLabel: "Adresse",
          hintText: "123 rue de la paix",
          controller: driverAdresseInputController,
        ),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
            "Pièce d'identité",
            viewModel.driverIdentity,
            (file) => viewModel.driverIdentity = file),
        const SizedBox(height: 20),
        _buildVehicleSection(viewModel),
      ],
    );
  }

  Widget _buildRadioButton<T>({
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: primaryColor,
        ),
        GestureDetector(
          onTap: () => onChanged(value),
          child: TextComponent(
            label,
            fontsize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection(RegisterProfileViewModel viewModel) {
    final bool showError = viewModel.showVehicleError ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextComponent(
          "Possédez-vous un véhicule ?",
          fontsize: 16,
          fontweight: FontWeight.w500,
        ),
        const SizedBox(height: 5),
        const TextComponent(
          "Une voiture, une moto ou un tricycle",
          fontsize: 14,
          textcolor: mediumGrey,
          fontweight: FontWeight.w400,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: showError 
              ? Border.all(color: Colors.red, width: 1.5) 
              : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Consumer<RegisterProfileViewModel>(
                builder: (context, vm, _) {
                  return Row(
                    children: [
                      _buildRadioButton(
                        value: true,
                        groupValue: vm.hasVehicle,
                        label: "Oui",
                        onChanged: (value) {
                          if (value != null) {
                            vm.setHasVehicle(value);
                            vm.setShowVehicleError(false);
                          }
                        },
                      ),
                      const SizedBox(width: 30),
                      _buildRadioButton(
                        value: false,
                        groupValue: vm.hasVehicle,
                        label: "Non",
                        onChanged: (value) {
                          if (value != null) {
                            vm.setHasVehicle(value);
                            vm.setShowVehicleError(false);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              if (showError) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Veuillez sélectionner une option',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (viewModel.hasVehicle != null) ...[
          if (viewModel.hasVehicle == true) 
            _buildHasVehicleSection(viewModel)
          else 
            _buildNoVehicleSection(viewModel),
        ],
      ],
    );
  }

  Widget _buildHasVehicleSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
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
        const SizedBox(height: 20),
        if (viewModel.selectedVehicle == "moto" ||
            viewModel.selectedVehicle == "tricycle")
          _buildMotoTricycleSection(viewModel)
        else if (viewModel.selectedVehicle == "voiture")
          _buildCarSection(viewModel),
      ],
    );
  }

  Widget _buildMotoTricycleSection(RegisterProfileViewModel viewModel) {
    // Update the controller text based on the selected vehicle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (driverCarPlacesInputController.text.isEmpty) {
        final seatNumber = viewModel.selectedVehicle == 'moto' 
            ? '1' 
            : viewModel.selectedVehicle == 'tricycle' 
                ? '3' 
                : driverCarPlacesInputController.text;
        if (driverCarPlacesInputController.text != seatNumber) {
          driverCarPlacesInputController.text = seatNumber;
        }
      }
    });

    return Column(
      children: [
        viewModel.uploadFileComponent(
            "Carte grise",
            viewModel.driverMotoCarteGrise,
            (file) => viewModel.driverMotoCarteGrise = file),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
            "Assurance",
            viewModel.driverMotoAssurance,
            (file) => viewModel.driverMotoAssurance = file),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Modèle du véhicule",
          hintText: "Ex: Honda CBR",
          controller: driverCarModelInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Immatriculation du véhicule",
          hintText: "Votre immatriculation",
          controller: driverImmatriculationCarInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          key: ValueKey('seats_${viewModel.selectedVehicle}'),
          bigLabel: "Nombre de places",
          hintText: viewModel.getSeatNumberHint(),
          controller: driverCarPlacesInputController,
          enabled: viewModel.isSeatNumberEditable(),
          readOnly: !viewModel.isSeatNumberEditable(),
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Année du véhicule",
          hintText: "Ex: 2008",
          controller: driverCarYearInputController,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCarSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
        viewModel.uploadFileComponent(
            "Permis de conduire",
            viewModel.driverCarPermis,
            (file) => viewModel.driverCarPermis = file),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
            "Carte grise",
            viewModel.driverCarCarteGrise,
            (file) => viewModel.driverCarCarteGrise = file),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
            "Assurance",
            viewModel.driverCarAssurance,
            (file) => viewModel.driverCarAssurance = file),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Couleur du véhicule",
          hintText: "Ex: Rouge",
          controller: driverCarColorInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Marque du véhicule",
          hintText: "Ex: Toyota",
          controller: driverCarBrandInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Modèle du véhicule",
          hintText: "Ex: Toyota Yaris",
          controller: driverCarModelInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Immatriculation du véhicule",
          hintText: "Votre immatriculation",
          controller: driverImmatriculationCarInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          key: ValueKey('seats_${viewModel.selectedVehicle}'),
          bigLabel: "Nombre de places",
          hintText: viewModel.getSeatNumberHint(),
          controller: driverCarPlacesInputController,
          enabled: viewModel.isSeatNumberEditable(),
          readOnly: !viewModel.isSeatNumberEditable(),
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Année du véhicule",
          hintText: "Ex: 2008",
          controller: driverCarYearInputController,
        ),
        const SizedBox(height: 20),
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
    );
  }

  Widget _buildNoVehicleSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
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
        const SizedBox(height: 20),
        if (viewModel.wantedVehicle == "Voiture") ...[
          viewModel.uploadFileComponent(
              "Permis de conduire",
              viewModel.driverNoCarPermis,
              (file) => viewModel.driverNoCarPermis = file),
          const SizedBox(height: 20),
        ] else if (viewModel.wantedVehicle == "Moto" ||
                   viewModel.wantedVehicle == "Tricycle") ...[
          const TextComponent(
            "Pas de problème, veuillez cliquer sur le bouton pour finaliser votre inscription !",
            fontsize: 16,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildCleaningSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
        TextInputField(
          bigLabel: "Nom",
          hintText: "SALANON",
          controller: cleaningSurnameInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Prénom",
          hintText: "Patrick",
          controller: cleaningNameInputController,
        ),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
            "Pièce d'identité",
            viewModel.cleaningIdentity,
            (file) => viewModel.cleaningIdentity = file),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGarageSection() {
    return Column(
      children: [
        TextInputField(
          bigLabel: "Nom du Garage",
          hintText: "Chez Le Super Garagiste",
          controller: garageNameInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Localisation du garage",
          hintText: "Saint Michel, En face de l'église",
          controller: garageLocalisationInputController,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void onViewModelReady(RegisterProfileViewModel viewModel) {
    viewModel.setControllers(
      driverCarPlacesController: driverCarPlacesInputController,
    );
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(RegisterProfileViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  RegisterProfileViewModel viewModelBuilder(BuildContext context) =>
      RegisterProfileViewModel();
}