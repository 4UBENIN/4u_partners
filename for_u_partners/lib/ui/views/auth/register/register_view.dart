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
  FormTextField(name: 'phoneNumberInput'),
  FormTextField(name: 'emailInput'),
  FormTextField(name: 'passwordInput'),
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
                        "Inscrivez-vous !",
                        fontsize: 24,
                      ),
                      const SizedBox(height: 20),

                      //* Phone Number
                      CountryPhoneSelector(
                        controller: phoneNumberInputController,
                        errorText: viewModel.phoneNumberErrorText,
                        onChanged: (value) {
                          viewModel.onPhoneNumberChanged(value);
                        },
                      ),
                      if (viewModel.phoneNumberErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            viewModel.phoneNumberErrorText!,
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
                        errorText: viewModel.emailErrorText,
                        onChanged: (value) {
                          viewModel.onEmailChanged(value!);
                        },
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
                              viewModel.onPasswordChanged(value!);
                            },
                          ),

                          // Indicateur de force du mot de passe
                          if (passwordInputController.text.isNotEmpty &&
                              viewModel.passwordErrorText == null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 0.0, right: 0.0),
                              child: Builder(
                                builder: (context) {
                                  final password =
                                      passwordInputController.text;
                                  final strength = viewModel
                                      .evaluatePasswordStrength(password);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: strength['strength'] as double,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            strength['color'] as Color,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        strength['message'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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
                              padding: const EdgeInsets.only(top: 4.0),
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

                      const SizedBox(height: 8),

                      // Message d'erreur d'inscription stylisé
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

                      //* Continue button
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: PrimaryButton(
                          text: viewModel.isBusy
                              ? "Vérification en cours..."
                              : "Continuer",
                          isActive: viewModel.isFormValid && !viewModel.isBusy,
                          onPressed: (viewModel.isFormValid && !viewModel.isBusy)
                              ? () async {
                                  if (viewModel.validateForm(
                                    phoneNumberInputController.text,
                                    emailInputController.text,
                                    passwordInputController.text,
                                  )) {
                                    // Vérifier l'inscription
                                    final isRegistrationValid =
                                        await viewModel.registerByProfile();

                                    // Si pas d'erreur, naviguer vers l'écran suivant
                                    if (isRegistrationValid) {
                                      viewModel.navigationService
                                          .navigateToRegisterProfileView(
                                        selectedProfile:
                                            viewModel.selectedProfile,
                                        phoneNumber:
                                            phoneNumberInputController.text,
                                        mail: emailInputController.text,
                                        password: passwordInputController.text,
                                      );
                                    }
                                  }
                                }
                              : () {
                                  // Déclencher la validation pour afficher les erreurs
                                  viewModel.validateForm(
                                    phoneNumberInputController.text,
                                    emailInputController.text,
                                    passwordInputController.text,
                                  );
                                },
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
                              style: TextStyle(
                                  color: primaryColor, fontSize: 14),
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