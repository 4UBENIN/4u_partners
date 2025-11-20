import 'package:for_u_partners/app/app.router.dart';
import 'register_view.form.dart';
import 'register_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/app_dropdown.dart';
import 'package:for_u_partners/ui/common/app_textInput.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

@FormView(fields: [
  FormTextField(name: 'phoneNumber'),
  FormTextField(name: 'firstName'),
  FormTextField(name: 'lastName'),
  FormTextField(name: 'email'),
  FormTextField(name: 'address'),
  FormTextField(name: 'password'),
  FormTextField(name: 'confirmPassword'),
])
class RegisterView extends StackedView<RegisterViewModel> with $RegisterView {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(viewModel),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Image.asset("assets/logo.png")),
                            const SizedBox(height: 40),
                            _buildStepTitle(viewModel),
                            const SizedBox(height: 24),
                            _buildStepContent(context, viewModel),
                            const SizedBox(height: 20),
                            if (viewModel.registrationError != null)
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        viewModel.registrationError!,
                                        style: TextStyle(
                                          color: Colors.red.shade900,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildNavigationButtons(viewModel),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const TextComponent(
                                  "Vous avez déjà un compte ?",
                                  fontsize: 14,
                                ),
                                TextButton(
                                  onPressed: viewModel.login,
                                  child: const Text(
                                    "Connectez-vous !",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(RegisterViewModel viewModel) {
    String title;
    String subtitle;

    switch (viewModel.currentStep) {
      case 0:
        title = "Informations de base";
        subtitle = "Prénom, nom et téléphone";
        break;
      case 1:
        title = "Contact et adresse";
        subtitle = "Email et adresse complète";
        break;
      case 2:
        title = "Sécurité";
        subtitle = "Créez votre mot de passe";
        break;
      case 3:
        title = "Profil professionnel";
        subtitle = "Sélectionnez votre activité";
        break;
      default:
        title = "";
        subtitle = "";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(RegisterViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
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
                    if (index < viewModel.totalSteps - 1)
                      const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Étape ${viewModel.currentStep + 1} sur ${viewModel.totalSteps}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, RegisterViewModel viewModel) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildStep1BasicInfo(viewModel);
      case 1:
        return _buildStep2ContactAddress(viewModel);
      case 2:
        return _buildStep3Password(context, viewModel);
      case 3:
        return _buildStep4Profile(viewModel);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1BasicInfo(RegisterViewModel viewModel) {
    return Column(
      children: [
        TextInputField(
          controller: firstNameController,
          bigLabel: "Prénom",
          hintText: "John",
          errorText: viewModel.firstNameErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onFirstNameChanged(value);
            }
          },
        ),
        const SizedBox(height: 20),
        TextInputField(
          controller: lastNameController,
          bigLabel: "Nom",
          hintText: "Doe",
          errorText: viewModel.lastNameErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onLastNameChanged(value);
            }
          },
        ),
        const SizedBox(height: 20),
        CountryPhoneSelector(
          controller: phoneNumberController,
          errorText: viewModel.phoneNumberErrorText,
          onChanged: (value) {
            viewModel.onPhoneNumberChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildStep2ContactAddress(RegisterViewModel viewModel) {
    return Column(
      children: [
        TextInputField(
          controller: emailController,
          bigLabel: "Email",
          hintText: "votremail@gmail.com",
          isEmail: true,
          errorText: viewModel.emailErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onEmailChanged(value);
            }
          },
        ),
        const SizedBox(height: 20),
        TextInputField(
          controller: addressController,
          bigLabel: "Adresse complète",
          hintText: "123 Rue de l'adresse, Ville, CP",
          errorText: viewModel.addressErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onAddressChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStep3Password(
      BuildContext context, RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextInputField(
          controller: passwordController,
          bigLabel: "Mot de passe",
          obscureText: viewModel.obscurePassword,
          hintText: "**********",
          suffixIcon: IconButton(
            onPressed: viewModel.togglePasswordVisibility,
            icon: Icon(
              viewModel.obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
          ),
          errorText: viewModel.passwordErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onPasswordChanged(value);
            }
          },
        ),
        const SizedBox(height: 20),
        TextInputField(
          controller: confirmPasswordController,
          bigLabel: "Confirmer le mot de passe",
          obscureText: viewModel.obscureConfirmPassword,
          hintText: "**********",
          suffixIcon: IconButton(
            onPressed: viewModel.toggleConfirmPasswordVisibility,
            icon: Icon(
              viewModel.obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
          ),
          errorText: viewModel.confirmPasswordErrorText,
          onChanged: (value) {
            if (value != null) {
              viewModel.onConfirmPasswordChanged(
                value,
                passwordController.text,
              );
            }
          },
        ),

        if (passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Builder(
              builder: (context) {
                final password = passwordController.text;
                final strength = viewModel.evaluatePasswordStrength(password);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: strength['strength'] as double,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          strength['color'] as Color,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strength['message'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: strength['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Utilisez 8+ caractères avec majuscules, minuscules et chiffres',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStep4Profile(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdown(
          title: "Sélectionnez votre profil",
          items: viewModel.profiles,
          value: viewModel.selectedProfile,
          onChanged: (value) {
            if (value != null) {
              viewModel.setSelectedProfile(value);
            }
          },
        ),
        if (viewModel.profileErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              viewModel.profileErrorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons(RegisterViewModel viewModel) {
    final isLastStep = viewModel.currentStep == viewModel.totalSteps - 1;

    final canContinue = viewModel.canGoToNextStep(
      phoneNumber: phoneNumberController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      address: addressController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PrimaryButton(
            text: viewModel.isBusy
                ? "Chargement..."
                : isLastStep
                    ? "Valider l'inscription"
                    : "Suivant",
            isActive: canContinue && !viewModel.isBusy,
            onPressed: () async {
              if (viewModel.isBusy) return;

              final isValid = viewModel.validateCurrentStep(
                phoneNumber: phoneNumberController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
                address: addressController.text,
                password: passwordController.text,
                confirmPassword: confirmPasswordController.text,
              );

              if (isValid) {
                if (isLastStep) {
                  final success = await viewModel.registerByProfile();

                  if (success) {
                    viewModel.navigationService.navigateToRegisterProfileView(
                      selectedProfile: viewModel.selectedProfile,
                      phoneNumber: phoneNumberController.text,
                      mail: emailController.text,
                      password: passwordController.text,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      address: addressController.text,
                    );
                  }
                } else {
                  viewModel.nextStep();
                }
              }
            },
          ),
        ),

        if (viewModel.currentStep > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: viewModel.isBusy ? null : viewModel.previousStep,
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

  @override
  void onViewModelReady(RegisterViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(RegisterViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) =>
      RegisterViewModel();
}
