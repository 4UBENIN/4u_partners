import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel() {
    registerDriverToken();
  }

  void sendTokenToBackend() async {
    await registerDriverToken();
  }

  Future<void> registerDriverToken() async {
    bool success = await FirebaseMessagingService()
        .sendCurrentTokenToBackend(ApiConstant.saveFcmTokenDriver);

    if (success) {
      print('Token conducteur enregistré');
    }
  }
}
