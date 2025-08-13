import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:for_u_partners/app/app.locator.dart';

class HomeViewModel extends BaseViewModel {
  final _sharedpreferencesService = locator<SharedpreferencesService>();

  String? name;

  HomeViewModel() {
    registerDriverToken();
    getUserName();
  }

  void sendTokenToBackend() async {
    await registerDriverToken();
    rebuildUi();
  }

  Future<void> getUserName() async {
    setBusy(true);
    try {
      name = await _sharedpreferencesService.getUserName() ?? "";
    } catch (e) {
      name = "";
    }
    print("NAME: $name");
    rebuildUi();
    setBusy(false);
  }

 Future<void> registerDriverToken() async {
 

  rebuildUi(); // ou notifyListeners()

  print("=== ENREGISTREMENT TOKEN CONDUCTEUR ===");
  bool success = await FirebaseMessagingService()
      .sendCurrentTokenToBackend(ApiConstant.saveFcmTokenDriver);

  if (success) {
    print('Token conducteur enregistré');
  }
}
} 
