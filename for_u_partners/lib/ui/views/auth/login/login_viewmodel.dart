import 'package:for_u_partners/app/models/login_model.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/ui/views/auth/login/login_view.form.dart';
// import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  // final _sharedPreferencesServices = locator<SharedpreferencesService>();
  final _authService = locator<AuthService>();
  bool obscurePassword = true;
  final profiles = [
    "pressing",
    "coursier",
    "conducteur",
    "agent d'entretien",
    "garagiste"
  ];

  String _selectedProfile = "pressing";
  String get selectedProfile => _selectedProfile;

  bool hasPasswordBeenTouched = false;

  // late Future<String?> selectedProfile;

  // LoginViewModel() {
  //  selectedProfile = _sharedPreferencesServices.getUserType();
  // }

  //* METHODS

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    rebuildUi();
  }

  void login(LoginModel model) async {
    setBusy(true);

    try {
      await _authService.login(model, _selectedProfile);
      // _navigationService.replaceWithDeliveryNavBarView();
    } catch (e) {
      setBusy(false);
    }
  }

  void register() {
    _navigationService.replaceWithRegisterView();
  }

  void viewPassword() {
    obscurePassword = !obscurePassword;
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
