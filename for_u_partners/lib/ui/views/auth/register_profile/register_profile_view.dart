import 'dart:io';
import 'dart:ui';
import 'package:for_u_partners/app/models/register_model.dart';
import 'package:for_u_partners/ui/common/toast.dart';
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
  FormTextField(name: 'driverCarColorInput'),
  FormTextField(name: 'driverCarBrandInput'),
  FormTextField(name: 'driverCarModelInput'),
  FormTextField(name: 'driverCarYearInput'),
  FormTextField(name: 'driverImmatriculationCarInput'),
  FormTextField(name: 'driverCarPlacesInput'),
])
class RegisterProfileView extends StackedView<RegisterProfileViewModel>
    with $RegisterProfileView {
  final String selectedProfile;
  final String phoneNumber;
  final String mail;
  final String password;
  final String firstName;
  final String lastName;
  final String address;

  const RegisterProfileView(
    this.selectedProfile,
    this.phoneNumber,
    this.mail,
    this.password,
    this.firstName,
    this.lastName,
    this.address, {
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterProfileViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PROGRESS INDICATOR
            _buildProgressIndicator(viewModel),

            // CONTENU PRINCIPAL
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Logo
                        Center(
                            child: Image.asset("assets/logo.png", height: 60)),
                        const SizedBox(height: 30),

                        // Titre de l'étape
                        _buildStepTitle(viewModel),
                        const SizedBox(height: 20),

                        // Contenu de l'étape
                        _buildStepContent(context, viewModel),

                        const SizedBox(height: 20),

                        // Boutons de navigation
                        _buildNavigationButtons(viewModel, context),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Loading overlay
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INDICATEUR DE PROGRESSION
  Widget _buildProgressIndicator(RegisterProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(viewModel.totalSteps, (index) {
          final isCompleted = index < viewModel.currentStep;
          final isCurrent = index == viewModel.currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? primaryColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < viewModel.totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // TITRE DE L'ÉTAPE
  Widget _buildStepTitle(RegisterProfileViewModel viewModel) {
    String title = "";
    String subtitle = "";

    switch (viewModel.currentStep) {
      case 0:
        title = "Pièce d'identité 📄";
        subtitle = "Téléchargez votre pièce d'identité";
        break;
      case 1:
        title = "Véhicule 🚗";
        subtitle = "Possédez-vous un véhicule ?";
        break;
      case 2:
        if (viewModel.hasVehicle == true) {
          title = "Informations véhicule 📋";
          subtitle = "Renseignez les détails de votre véhicule";
        }
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextComponent(
          title,
          fontsize: 24,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // CONTENU DE L'ÉTAPE
  Widget _buildStepContent(
      BuildContext context, RegisterProfileViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildStep1Identity(viewModel);
      case 1:
        return _buildStep2VehicleQuestion(viewModel);
      case 2:
        if (viewModel.hasVehicle == true) {
          return _buildStep3VehicleInfo(viewModel);
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  // ÉTAPE 1: PIÈCE D'IDENTITÉ
  Widget _buildStep1Identity(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
        viewModel.uploadFileComponent(
          "Pièce d'identité",
          viewModel.driverIdentity,
          (file) => viewModel.driverIdentity = file,
        ),
        if (viewModel.driverIdentity == null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Carte d'identité, passeport ou tout autre document officiel",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ÉTAPE 2: QUESTION SUR LE VÉHICULE
  Widget _buildStep2VehicleQuestion(RegisterProfileViewModel viewModel) {
    final bool showError = viewModel.showVehicleError ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextComponent(
          "Possédez-vous un véhicule ?",
          fontsize: 18,
          fontweight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        const TextComponent(
          "Une voiture, une moto ou un tricycle",
          fontsize: 14,
          textcolor: mediumGrey,
        ),
        const SizedBox(height: 20),

        // Options Oui/Non
        Container(
          decoration: BoxDecoration(
            border:
                showError ? Border.all(color: Colors.red, width: 1.5) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildRadioCard(
                      value: true,
                      groupValue: viewModel.hasVehicle,
                      label: "Oui",
                      icon: Icons.check_circle,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setHasVehicle(value);
                          viewModel.setShowVehicleError(false);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRadioCard(
                      value: false,
                      groupValue: viewModel.hasVehicle,
                      label: "Non",
                      icon: Icons.cancel,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setHasVehicle(value);
                          viewModel.setShowVehicleError(false);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (showError) ...[
                const SizedBox(height: 12),
                const Row(
                  children: const [
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

        // Section selon le choix
        if (viewModel.hasVehicle == false) _buildNoVehicleSection(viewModel),
      ],
    );
  }

  // Card radio button stylisée
  Widget _buildRadioCard<T>({
    required T value,
    required T? groupValue,
    required String label,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            TextComponent(
              label,
              fontsize: 16,
              fontweight: FontWeight.w600,
              textcolor: isSelected ? primaryColor : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  // Section sans véhicule
  Widget _buildNoVehicleSection(RegisterProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (viewModel.wantedVehicle == "voiture") ...[
          viewModel.uploadFileComponent(
            "Permis de conduire",
            viewModel.driverNoCarPermis,
            (file) => viewModel.driverNoCarPermis = file,
          ),
          const SizedBox(height: 20),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Parfait ! Cliquez sur 'Continuer' pour finaliser",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ÉTAPE 3: INFORMATIONS VÉHICULE
  Widget _buildStep3VehicleInfo(RegisterProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          title: "Type de véhicule",
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

  // Section Moto/Tricycle
  Widget _buildMotoTricycleSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
        viewModel.uploadFileComponent(
          "Carte grise",
          viewModel.driverMotoCarteGrise,
          (file) => viewModel.driverMotoCarteGrise = file,
        ),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
          "Assurance",
          viewModel.driverMotoAssurance,
          (file) => viewModel.driverMotoAssurance = file,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Modèle du véhicule",
          hintText: "Ex: Honda CBR",
          controller: driverCarModelInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Immatriculation",
          hintText: "Ex: AB-1234-CD",
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
          bigLabel: "Année",
          hintText: "Ex: 2020",
          controller: driverCarYearInputController,
        ),
      ],
    );
  }

  // Section Voiture
  Widget _buildCarSection(RegisterProfileViewModel viewModel) {
    return Column(
      children: [
        viewModel.uploadFileComponent(
          "Permis de conduire",
          viewModel.driverCarPermis,
          (file) => viewModel.driverCarPermis = file,
        ),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
          "Carte grise",
          viewModel.driverCarCarteGrise,
          (file) => viewModel.driverCarCarteGrise = file,
        ),
        const SizedBox(height: 20),
        viewModel.uploadFileComponent(
          "Assurance",
          viewModel.driverCarAssurance,
          (file) => viewModel.driverCarAssurance = file,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Couleur",
          hintText: "Ex: Blanc",
          controller: driverCarColorInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Marque",
          hintText: "Ex: Toyota",
          controller: driverCarBrandInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Modèle",
          hintText: "Ex: Corolla",
          controller: driverCarModelInputController,
        ),
        const SizedBox(height: 20),
        TextInputField(
          bigLabel: "Immatriculation",
          hintText: "Ex: AB-1234-CD",
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
          bigLabel: "Année",
          hintText: "Ex: 2020",
          controller: driverCarYearInputController,
        ),
        const SizedBox(height: 20),
        CustomDropdown(
          title: "Catégorie",
          items: viewModel.categories,
          value: viewModel.selectedCategory,
          onChanged: (value) {
            if (value != null) {
              viewModel.setSelectedCategory(value);
            }
          },
        ),
      ],
    );
  }

  // BOUTONS DE NAVIGATION
  Widget _buildNavigationButtons(
      RegisterProfileViewModel viewModel, BuildContext context) {
    final isLastStep = viewModel.currentStep == viewModel.totalSteps - 1;

    return Column(
      children: [
        // Bouton principal
        PrimaryButton(
          text: viewModel.isBusy
              ? "Traitement..."
              : isLastStep
                  ? "Finaliser"
                  : "Continuer",
          isActive: !viewModel.isBusy,
          onPressed: viewModel.isBusy
              ? null
              : () {
                  if (isLastStep) {
                    // Dernière étape: Soumettre
                    _handleSubmit(viewModel, context);
                  } else {
                    // Valider et passer à l'étape suivante
                    if (viewModel.validateCurrentStep()) {
                      viewModel.nextStep();
                    }
                  }
                },
        ),

        // Bouton Précédent
        if (viewModel.currentStep > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: viewModel.isBusy
                  ? null
                  : () {
                      viewModel.previousStep();
                    },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 4),
                  Text("Retour"),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleSubmit(
      RegisterProfileViewModel viewModel, BuildContext context) async {
    if (!viewModel.validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    if (viewModel.hasVehicle == true) {
      await _submitWithVehicle(viewModel, context);
    } else {
      await _submitWithoutVehicle(viewModel, context);
    }
  }

  Future<void> _submitWithVehicle(
    RegisterProfileViewModel viewModel, BuildContext context) async {
  try {
    // 🔍 DEBUG : Logs pour identifier le problème
    print("=== DEBUG SUBMIT WITH VEHICLE ===");
    print("selectedVehicle: ${viewModel.selectedVehicle}");
    print("selectedCategory: ${viewModel.selectedCategory}");
    print("driverIdentity: ${viewModel.driverIdentity}");
    print("driverIdentity path: ${viewModel.driverIdentity?.path}");
    print("hasVehicle: ${viewModel.hasVehicle}");
    print("currentStep: ${viewModel.currentStep}");
    
    // Logs spécifiques au type de véhicule
    if (viewModel.selectedVehicle == 'voiture') {
      print("--- Documents Voiture ---");
      print("driverCarPermis: ${viewModel.driverCarPermis}");
      print("driverCarCarteGrise: ${viewModel.driverCarCarteGrise}");
      print("driverCarAssurance: ${viewModel.driverCarAssurance}");
      print("driverCarColor: ${driverCarColorInputController.text}");
      print("driverCarBrand: ${driverCarBrandInputController.text}");
      print("driverCarModel: ${driverCarModelInputController.text}");
      print("driverCarImmatriculation: ${driverImmatriculationCarInputController.text}");
      print("driverCarPlaces: ${driverCarPlacesInputController.text}");
      print("driverCarYear: ${driverCarYearInputController.text}");
    } else {
      print("--- Documents Moto/Tricycle ---");
      print("driverMotoCarteGrise: ${viewModel.driverMotoCarteGrise}");
      print("driverMotoAssurance: ${viewModel.driverMotoAssurance}");
      print("driverCarModel: ${driverCarModelInputController.text}");
      print("driverCarImmatriculation: ${driverImmatriculationCarInputController.text}");
      print("driverCarPlaces: ${driverCarPlacesInputController.text}");
      print("driverCarYear: ${driverCarYearInputController.text}");
    }
    print("=================================");

    // Vérification de la pièce d'identité
    if (viewModel.driverIdentity == null) {
      print("❌ Pièce d'identité manquante");
      if (context.mounted) {
        CustomToast.showError(context, 
            message: "Veuillez télécharger votre pièce d'identité");
      }
      return;
    }

    print("✅ Création du modèle véhicule...");

    // Création du modèle véhicule
    VehiculeModel vehiculeModel = VehiculeModel(
      type: viewModel.selectedVehicle,
      marque: driverCarBrandInputController.text,
      modele: driverCarModelInputController.text,
      immatriculation: driverImmatriculationCarInputController.text,
      nombrePlaces: int.tryParse(driverCarPlacesInputController.text),
      couleur: driverCarColorInputController.text,
      categorie: viewModel.selectedCategory,
      annee: int.tryParse(driverCarYearInputController.text),
      cartegrise: viewModel.selectedVehicle == 'voiture'
          ? (viewModel.driverCarCarteGrise != null
              ? File(viewModel.driverCarCarteGrise!.path)
              : null)
          : (viewModel.driverMotoCarteGrise != null
              ? File(viewModel.driverMotoCarteGrise!.path)
              : null),
      permis: viewModel.driverCarPermis != null
          ? File(viewModel.driverCarPermis!.path)
          : null,
      assurance: viewModel.selectedVehicle == 'voiture'
          ? (viewModel.driverCarAssurance != null
              ? File(viewModel.driverCarAssurance!.path)
              : null)
          : (viewModel.driverMotoAssurance != null
              ? File(viewModel.driverMotoAssurance!.path)
              : null),
    );

    print("✅ Modèle véhicule créé");
    print("📋 Détails véhicule:");
    print("  - Type: ${vehiculeModel.type}");
    print("  - Marque: ${vehiculeModel.marque}");
    print("  - Modèle: ${vehiculeModel.modele}");
    print("  - Immatriculation: ${vehiculeModel.immatriculation}");
    print("  - Places: ${vehiculeModel.nombrePlaces}");
    print("  - Couleur: ${vehiculeModel.couleur}");
    print("  - Catégorie: ${vehiculeModel.categorie}");
    print("  - Année: ${vehiculeModel.annee}");
    print("  - Carte grise: ${vehiculeModel.cartegrise?.path}");
    print("  - Permis: ${vehiculeModel.permis?.path}");
    print("  - Assurance: ${vehiculeModel.assurance?.path}");

    print("✅ Création du modèle d'inscription...");

    // Création du modèle d'inscription
    RegistrationModel model = RegistrationModel(
      type: "conducteur",
      telephone: phoneNumber,
      email: mail,
      code: "1234",
      motDePasse: password,
      motDePasseConfirmation: password,
      nom: lastName,
      prenom: firstName,
      adresse: address,
      dateNaissance: "1990-01-15",
      numeroPermis: "TEMP_PERMIS",
      dateExpirationPermis: "2030-12-31",
      documentIdentite: File(viewModel.driverIdentity!.path),
      possedeVehicule: 1,
      typeConducteurId: 1,
      vehicule: vehiculeModel,
    );

    print("✅ Modèle d'inscription créé");
    print("📤 Envoi de l'inscription avec véhicule...");

    await viewModel.registerEnding(model, context);
    
    print("✅ Inscription avec véhicule terminée");

  } catch (e, stackTrace) {
    print("❌ ERREUR DÉTAILLÉE SUBMIT WITH VEHICLE:");
    print("Message: $e");
    print("StackTrace: $stackTrace");
    
    if (context.mounted) {
      CustomToast.showError(context, 
          message: "Erreur lors de l'inscription: ${e.toString()}");
    }
  }
}
  Future<void> _submitWithoutVehicle(
    RegisterProfileViewModel viewModel, BuildContext context) async {
  try {
    // 🔍 DEBUG : Logs pour identifier le problème
    print("=== DEBUG SUBMIT WITHOUT VEHICLE ===");
    print("driverIdentity: ${viewModel.driverIdentity}");
    print("driverIdentity path: ${viewModel.driverIdentity?.path}");
    print("wantedVehicle: ${viewModel.wantedVehicle}");
    print("driverNoCarPermis: ${viewModel.driverNoCarPermis}");
    print("hasVehicle: ${viewModel.hasVehicle}");
    print("currentStep: ${viewModel.currentStep}");
    print("===================================");

    // Vérification stricte de la pièce d'identité
    if (viewModel.driverIdentity == null) {
      if (context.mounted) {
        CustomToast.showError(context, 
            message: "Veuillez télécharger votre pièce d'identité");
      }
      return;
    }

    // Vérification du permis si véhicule souhaité = voiture
    if (viewModel.wantedVehicle == "voiture" && 
        viewModel.driverNoCarPermis == null) {
      if (context.mounted) {
        CustomToast.showError(context, 
            message: "Veuillez télécharger votre permis de conduire");
      }
      return;
    }

    // Création du modèle avec vérification supplémentaire
    final identityFile = viewModel.driverIdentity;
    if (identityFile == null) {
      if (context.mounted) {
        CustomToast.showError(context, 
            message: "Document d'identité manquant");
      }
      return;
    }

    print("✅ Toutes les vérifications passées, création du modèle...");

    // Création du modèle d'inscription
    RegistrationModel model = RegistrationModel(
      type: "conducteur",
      telephone: phoneNumber,
      email: mail,
      code: "1234",
      motDePasse: password,
      motDePasseConfirmation: password,
      nom: lastName,
      prenom: firstName,
      adresse: address,
      dateNaissance: "1990-01-15",
      numeroPermis: "TEMP_PERMIS",
      dateExpirationPermis: "2030-12-31",
      documentIdentite: File(identityFile.path),
      possedeVehicule: 0,
      typeConducteurId: viewModel.wantedVehicle == "voiture" ? 2 : 1,
    );

    print("📤 Envoi de l'inscription...");
    await viewModel.registerEnding(model, context);
    print("✅ Inscription terminée");

  } catch (e, stackTrace) {
    print("❌ ERREUR DÉTAILLÉE:");
    print("Message: $e");
    print("StackTrace: $stackTrace");
    
    if (context.mounted) {
      CustomToast.showError(context, 
          message: "Erreur lors de l'inscription: ${e.toString()}");
    }
  }
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
