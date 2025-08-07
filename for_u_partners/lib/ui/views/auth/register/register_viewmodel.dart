import 'package:for_u_partners/ui/views/auth/register/register_view.form.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class RegisterViewModel extends FormViewModel {
  final navigationService = locator<NavigationService>();

  final profiles = [
    "pressing",
    "livreur/Coursier",
    "conducteur",
    "agent d'entretien",
    "garagiste"
  ];

  bool obscurePassword = true;
  bool hasPasswordBeenTouched =
      false; // Nouvelle variable pour tracker l'interaction

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;

  //* FONCTIONS

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void login() {
    navigationService.replaceWithLoginView();
  }

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    rebuildUi();
  }

  // Nouvelle méthode pour marquer que le champ password a été touché
  void onPasswordFieldTouched() {
    if (!hasPasswordBeenTouched) {
      hasPasswordBeenTouched = true;
      rebuildUi();
    }
  }

  // Méthode pour obtenir le message d'erreur seulement si le champ a été touché
  String? get passwordErrorText {
    if (!hasPasswordBeenTouched) {
      return null; // Ne pas afficher d'erreur si pas encore touché
    }
    return passwordInputValidationMessage;
  }

  void registerByProfile() {}
}

class PasswordValidators {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe ne peut pas être vide';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    return null;
  }
}
