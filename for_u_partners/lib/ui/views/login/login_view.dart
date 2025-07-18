import 'login_view.form.dart';
import 'login_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/app_text_Input.dart';
import 'package:for_u_partners/ui/common/app_text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

@FormView(fields: [
  FormTextField(name: 'phoneNumberInput'),
  FormTextField(name: 'passwordInput'),
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
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      ))),
              TextButton(
                  onPressed: () {},
                  child: const TextComponent(
                    "Mot de passe oublié ?",
                    textcolor: primaryColor,
                  )),

              //* Connection Button
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: PrimaryButton(text: "Se connecter", onPressed: () {}),
              ),

              //* Register Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextComponent(
                    "Vous n'avez pas de compte ?",
                    fontsize: 15,
                  ),
                  TextButton(
                      onPressed: () {
                        LoginViewModel().register();
                      },
                      child: const Text(
                        "Inscrivez-vous !",
                        style: TextStyle(color: primaryColor, fontSize: 15),
                      ))
                ],
              ),
            ],
          ),
        ));
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
