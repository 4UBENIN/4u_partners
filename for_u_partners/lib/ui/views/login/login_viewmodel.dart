import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends FormViewModel {
  final _navigationService = locator<NavigationService>();
  bool obscurePassword = true;

  void login() {}

  void register() {
    _navigationService.replaceWithRegisterView();
  }

  void viewPassword() {
    obscurePassword = !obscurePassword;
    rebuildUi();
  }
}
