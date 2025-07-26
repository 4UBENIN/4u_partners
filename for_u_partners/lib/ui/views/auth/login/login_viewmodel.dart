import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  bool obscurePassword = true;
  final profiles = [
    "Pressing",
    "Livreur/Coursier",
    "Conducteur",
    "Agent d'entretien",
    "Garagiste"
  ];
  String _selectedProfile = "Pressing";
  String get selectedProfile => _selectedProfile;

  //* METHODS

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    rebuildUi();
  }

  void login(String selectedProfile) {
    if (selectedProfile == "Pressing") {
      _navigationService.replaceWithNavBarPressingView();
    } else if (selectedProfile == "Conducteur") {
      _navigationService.replaceWithHomemainView();
    } else if (selectedProfile == "Livreur/Coursier") {
    } else if (selectedProfile == "Garagiste") {
    } else if (selectedProfile == "Agent d'entretien") {}
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
