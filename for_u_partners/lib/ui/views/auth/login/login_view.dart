import 'dart:ui';

import 'package:for_u_partners/app/models/login_model.dart';
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
  FormTextField(name: 'phoneNumberInput'),
  FormTextField(
    name: 'passwordInput',
    validator: PasswordValidators.validatePassword,
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
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centrage vertical
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                            height: 60), // Pour laisser un peu d'air en haut

                        //* Logo
                        Center(child: Image.asset("assets/logo.png")),

                        const SizedBox(height: 40),
                        const TextComponent(
                          "Connectez - vous !",
                          fontsize: 24,
                        ),
                        const SizedBox(height: 20),

                        //* Phone
                        CountryPhoneSelector(
                          controller: phoneNumberInputController,
                        ),
                        const SizedBox(height: 20),

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
                        const SizedBox(height: 25),

                        //* Password
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
                          // Utilisez validator pour la validation automatique
                          validator: PasswordValidators.validatePassword,
                          // Utilisez errorText seulement si le champ a été touché
                          errorText: viewModel.passwordErrorText,
                          // Ajoutez un callback onTap pour marquer le champ comme touché
                          onTap: () {
                            viewModel.onPasswordFieldTouched();
                          },
                          // Ajoutez aussi onChanged pour marquer comme touché dès la première saisie
                          onChanged: (value) {
                            viewModel.onPasswordFieldTouched();
                          },
                        ),

                        TextButton(
                            onPressed: () {},
                            child: const TextComponent(
                              "Mot de passe oublié ?",
                              textcolor: primaryColor,
                            )),

                        //* Connection Button
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: PrimaryButton(
                              text: "Se connecter",
                              onPressed: () async {
                                LoginModel model = LoginModel(
                                    telephone:
                                        "+229${phoneNumberInputController.text}",
                                    motDePasse: passwordInputController.text,
                                    type: viewModel.selectedProfile == "livreur"
                                        ? "conducteur"
                                        : viewModel.selectedProfile);
                                print("=== MODEL: ${model.toJson()} ===");
                                viewModel.login(model, context);
                              }),
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
                        const SizedBox(height: 30), // Espace en bas
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
