import 'register_view.form.dart';
import 'register_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/app_dropdown.dart';
import 'package:for_u_partners/ui/common/app_text_Input.dart';
import 'package:for_u_partners/ui/common/app_text_component.dart';
import 'package:for_u_partners/ui/common/app_button_component.dart';

@FormView(fields: [
  FormTextField(name: 'phoneNumberInput'),
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                      const CountryPhoneSelector(),
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      //* Profile Dropdown
                      CustomDropdown(
                        title: "Profil",
                        items: viewModel.profiles,
                        value: viewModel.selectedProfile,
                        onChanged: (value) {
                          if (value != null) {
                            viewModel
                                .setSelectedProfile(value);
                          }
                        },
                      ),

                      //* Continue button
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: PrimaryButton(
                          text: "Continuer",
                          onPressed: () {
                            viewModel.registerByProfile();
                          },
                        ),
                      ),

                      //* Connected Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TextComponent(
                            "Vous avez déjà un compte ?",
                            fontsize: 15,
                          ),
                          TextButton(
                            onPressed: () {
                              viewModel.login();
                            },
                            child: const Text(
                              "Connectez - vous !",
                              style:
                                  TextStyle(color: primaryColor, fontSize: 15),
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
