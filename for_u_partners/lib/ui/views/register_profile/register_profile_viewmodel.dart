import 'package:stacked/stacked.dart';

class RegisterProfileViewModel extends BaseViewModel {
  bool? hasVehicle;
  final vehicles = [
    "Moto",
    "Voiture",
    "Tricycle",
  ];

  final wantedVehicles = [
    "Moto",
    "Voiture",
    "Tricycle",
  ];

  String _selectedVehicle = "Moto";
  String get selectedVehicle => _selectedVehicle;

  String _wantedVehicle = "Moto";
  String get wantedVehicle => _wantedVehicle;

  //* Functions

  void setSelectedVehicle(String value) {
    _selectedVehicle = value;
    rebuildUi();
  }

  void setWantedVehicle(String value) {
    _wantedVehicle = value;
    rebuildUi();
  }

  void setHasVehicle(bool value) {
    hasVehicle = value;
    rebuildUi();
  }
}
