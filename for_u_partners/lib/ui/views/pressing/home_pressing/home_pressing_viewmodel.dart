import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class HomePressingViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  bool isAccepted = false;
  String depotStatus = "En attente de validation";
  String _ramassageStatus = "En attente";

  String get ramassageStatus => _ramassageStatus;

  void setAccepted(bool value) {
    print("setAccepted called with: $value");
    isAccepted = value;
    if (value) {
      _ramassageStatus = "A finaliser";
      print("Status changed to: $_ramassageStatus");
      print("Calling notifyListeners...");
      notifyListeners();
      print("notifyListeners called");
    }
  }

  void setDepotStatus(String status) {
    print("setDepotStatus called with: $status");
    depotStatus = status;
    notifyListeners();
  }

  void setRamassageStatus(String status) {
    print("setRamassageStatus called with: $status");
    _ramassageStatus = status;
    notifyListeners();
  }

  void contactDelivery() {
    print("contactDelivery called");
    _ramassageStatus = "A facturer";
    print("Status changed to: $_ramassageStatus");
    notifyListeners();
    print("notifyListeners called from contactDelivery");
  }

  void finalizeRamassage() {
    print("finalizeRamassage called");
    _ramassageStatus = "Terminé";
    print("Status changed to: $_ramassageStatus");
    notifyListeners();
    print("notifyListeners called from finalizeRamassage");
  }
}
