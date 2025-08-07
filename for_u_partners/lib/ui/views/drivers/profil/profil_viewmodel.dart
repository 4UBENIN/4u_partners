import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfilViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _sharedPreferencesServices = locator<SharedpreferencesService>();

  //* METHODS
  void logOut() {
    _sharedPreferencesServices.removeToken();
    _navigationService.replaceWithLoginView();
  }
}
