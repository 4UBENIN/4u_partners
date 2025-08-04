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

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;

  //* Functions

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

  void registerByProfile() {
   
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
