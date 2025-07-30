import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class HomePressingViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  bool isAccepted = false;
  String depotStatus = "En attente de validation";
  String ramassageStatus = "En attente";

  void setAccepted(bool value) {
    isAccepted = value;
    if (value) {
      ramassageStatus = "En attente de facturation";
    }
    notifyListeners();
  }

  void setDepotStatus(String status) {
    depotStatus = status;
    notifyListeners();
  }

  void setRamassageStatus(String status) {
    ramassageStatus = status;
    notifyListeners();
  }

  void finalizeRamassage() {
    ramassageStatus = "Terminé";
    notifyListeners();
  }
}
