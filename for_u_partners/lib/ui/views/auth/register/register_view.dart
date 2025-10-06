import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/validators/form_validators.dart';

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
  FormTextField(
    name: 'phoneNumberInput',
    validator: PhoneValidators.validatePhoneNumber,
  ),
  FormTextField(
    name: 'emailInput',
    validator: EmailValidators.validateEmail,
  ),
  FormTextField(
    name: 'passwordInput',
    validator: PasswordValidators.validatePassword,
  ),
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
                      //* Logo
                      Center(child: Image.asset("assets/logo.png")),
                      const SizedBox(height: 40),

                      const TextComponent(
                        "Inscrivez - vous !",
                        fontsize: 24,
                      ),
                      const SizedBox(height: 20),
                      //* Phone Number
                      CountryPhoneSelector(
                        controller: phoneNumberInputController,
                        errorText: viewModel.phoneNumberInputValidationMessage,
                        onChanged: (value) {
                          viewModel.onPhoneNumberChanged();
                        },
                      ),
                      if (viewModel.phoneNumberInputValidationMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                          child: Text(
                            viewModel.phoneNumberInputValidationMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),

                      //* Email
                      TextInputField(
                        controller: emailInputController,
                        bigLabel: "Email",
                        hintText: "votremail@gmail.com",
                        isEmail: true,
                        errorText: viewModel.emailInputValidationMessage,
                        onChanged: (value) {
                          viewModel.onEmailChanged();
                        },
                      ),
                      if (viewModel.emailInputValidationMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                          child: Text(
                            viewModel.emailInputValidationMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      //* Password
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextInputField(
                            controller: passwordInputController,
                            bigLabel: "Mot de passe",
                            obscureText: viewModel.obscurePassword,
                            hintText: "**********",
                            suffixIcon: IconButton(
                              onPressed: () {
                                viewModel.viewPassword();
                              },
                              icon: Icon(
                                viewModel.obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                            errorText: viewModel.passwordErrorText,
                            onTap: () {
                              viewModel.onPasswordFieldTouched();
                            },
                            onChanged: (value) {
                              viewModel.onPasswordFieldTouched();
                              // Force le recalcul de la force du mot de passe
                              viewModel.rebuildUi();
                            },
                          ),
                          
                          // Indicateur de force du mot de passe
                          if (viewModel.passwordInputValue?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                              child: Builder(
                                builder: (context) {
                                  final password = viewModel.passwordInputValue ?? '';
                                  final strength = viewModel.evaluatePasswordStrength(password);
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(
                                        value: strength['strength'] as double,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          strength['color'] as Color,
                                        ),
                                        minHeight: 4,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        strength['message'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: strength['color'] as Color,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      //* Profile Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdown(
                            title: "Profil",
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
                              padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                              child: Text(
                                viewModel.profileErrorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Message d'erreur d'inscription
                      if (viewModel.registrationError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            viewModel.registrationError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        
                      //* Continue button
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: PrimaryButton(
                          text: "Continuer",
                          isActive: viewModel.isFormValid,
                          onPressed: viewModel.isFormValid
                              ? () async {
                                  if (viewModel.validateForm(
                                    phoneNumberInputController.text,
                                    emailInputController.text,
                                    passwordInputController.text,
                                  )) {
                                    // Vérifier si le numéro est déjà utilisé
                                    final isRegistrationValid = await viewModel.registerByProfile();
                                    
                                    // Si pas d'erreur, naviguer vers l'écran suivant
                                    if (isRegistrationValid) {
                                      viewModel.navigationService
                                          .navigateToRegisterProfileView(
                                        selectedProfile: viewModel.selectedProfile,
                                        phoneNumber: phoneNumberInputController.text,
                                        mail: emailInputController.text,
                                        password: passwordInputController.text,
                                      );
                                    }
                                  }
                                }
                              : () {},
                        ),
                      ),

                      //* Connected Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TextComponent(
                            "Vous avez déjà un compte ?",
                            fontsize: 14,
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.login();
                            },
                            child: const Text(
                              "Connectez-vous !",
                              style:
                                  TextStyle(color: primaryColor, fontSize: 14),
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
  RegisterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RegisterViewModel();
}
