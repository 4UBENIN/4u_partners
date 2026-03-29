import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.router.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _sharedpreferencesService = locator<SharedpreferencesService>();

  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await _sharedpreferencesService.getToken();
    final userType = await _sharedpreferencesService.getUserType();

    print("=== TOKEN: $token, USER TYPE: $userType ===");

    if (token != null && userType != null) {
      switch (userType) {
        case 'livreur':
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'chauffeur':
        case 'conducteur': // 👈 ajouté
          _navigationService.replaceWithHomemainView();
          break;
        case 'ramasseur':
          _navigationService.replaceWithDeliveryNavBarView();
          break;
        case 'pressing':
          _navigationService.replaceWithNavBarPressingView();
          break;
        default:
          // 👈 fallback si userType n'est pas reconnu
          _navigationService.navigateToLoginView();
          break;
      }
    } else {
      // 👈 fallback si token ou userType est null
      _navigationService.navigateToLoginView();
    }
  }
}
