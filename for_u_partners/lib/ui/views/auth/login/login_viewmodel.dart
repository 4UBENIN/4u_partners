import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  bool obscurePassword = true;

  void login() {
    _navigationService.replaceWithHomemainView();
  }

  void register() {
    _navigationService.replaceWithRegisterView();
  }

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }
}

class PasswordValidators {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe ne peut pas être vide';
    }

    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

    if (!passwordRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre, et avoir 8 caractères minimum.';
    }

    return null;
  }
}
