import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/pressing_dashboard_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';

class ProfilPressingViewModel extends BaseViewModel {
  final _pressingService = locator<PressingService>();

  Pressing? _pressing;
  Pressing? get pressing => _pressing;

  Future<void> fetchPressingInfo() async {
    setBusy(true);
    final response = await _pressingService.getPressingInfo();
    if (response != null) {
      _pressing = response.pressing;
    }
    setBusy(false);
  }
}
