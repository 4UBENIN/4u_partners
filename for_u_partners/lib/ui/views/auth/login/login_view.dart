import 'dart:ui';

import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/ui/password_reset/forgot_password_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'login_view.form.dart';
import 'login_viewmodel.dart';
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
  ),
  FormTextField(
    name: 'passwordInput',
  ),
])
class LoginView extends StackedView<LoginViewModel> with $LoginView {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        //* Logo
                        Center(child: Image.asset("assets/logo.png")),

                        const SizedBox(height: 40),
                        const TextComponent(
                          "Connectez-vous !",
                          fontsize: 24,
                        ),
                        const SizedBox(height: 20),

                        //* Phone
                        CountryPhoneSelector(
                          controller: phoneNumberInputController,
                          onChanged: (value) {
                            viewModel.onPhoneNumberChanged(value);
                          },
                          errorText: viewModel.phoneNumberErrorText,
                        ),
                        if (viewModel.phoneNumberErrorText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            viewModel.phoneNumberErrorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        //* Profile
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
                        if (viewModel.profileErrorText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            viewModel.profileErrorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                          ],
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Mot de passe oublié ?",
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Message d'erreur de connexion
                        if (viewModel.loginError != null)
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
                                    viewModel.loginError!,
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

                        //* Connection Button
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: PrimaryButton(
                            text: "Se connecter",
                            isActive: viewModel.isFormValid,
                            onPressed: viewModel.isFormValid
                                ? () async {
                                    if (viewModel.validateForm(
                                      phoneNumberInputController.text,
                                      passwordInputController.text,
                                    )) {
                                      LoginModel model = LoginModel(
                                        telephone:
                                            "+229${phoneNumberInputController.text}",
                                        motDePasse:
                                            passwordInputController.text,
                                        type: viewModel.selectedProfile ==
                                                "livreur"
                                            ? "conducteur"
                                            : viewModel.selectedProfile,
                                      );

                                      await viewModel.login(model, context);
                                    }
                                  }
                                : () {
                                    // Déclencher la validation pour afficher les erreurs
                                    viewModel.validateForm(
                                      phoneNumberInputController.text,
                                      passwordInputController.text,
                                    );
                                  },
                          ),
                        ),

                        //* Register Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const TextComponent(
                              "Vous n'avez pas de compte ?",
                              fontsize: 14,
                            ),
                            TextButton(
                                onPressed: () {
                                  viewModel.register();
                                },
                                child: const Text(
                                  "Inscrivez-vous !",
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 14),
                                ))
                          ],
                        ),
                        const SizedBox(height: 30),
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
            ),
          );
        },
      ),
    );
  }

  @override
  void onViewModelReady(LoginViewModel viewModel) {
    syncFormWithViewModel(viewModel);
  }

  @override
  void onDispose(LoginViewModel viewModel) {
    super.onDispose(viewModel);
    disposeForm();
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel();
}