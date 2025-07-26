import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class ComptePressingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  //* METHODS
  void logOut() {
    _navigationService.replaceWithLoginView();
  }
}
