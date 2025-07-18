import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class RegisterViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();

  final profiles = [
    "Pressing",
    "Livreur/Coursier",
    "Conducteur",
    "Agent d'entretien",
    "Garagiste"
  ];

  bool obscurePassword = true;

  String _selectedProfile = "Pressing";
  String get selectedProfile => _selectedProfile;

  //* Functions

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }

  void login() {
    _navigationService.replaceWithLoginView();
  }

  void setSelectedProfile(String value) {
    _selectedProfile = value;
    rebuildUi();
  }

  void registerByProfile() {
    _navigationService.navigateToRegisterProfileView(
        selectedProfile: _selectedProfile);
  }
}
