import 'package:stacked/stacked.dart';

class HomePressingViewModel extends BaseViewModel {
  bool isAccepted = false;
  String depotStatus = "En attente de validation";

  void setAccepted(bool value) {
    isAccepted = value;
    notifyListeners();
  }

  void setDepotStatus(String status) {
    depotStatus = status;
    notifyListeners();
  }
}
