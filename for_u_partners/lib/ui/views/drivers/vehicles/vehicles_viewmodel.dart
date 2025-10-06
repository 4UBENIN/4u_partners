import 'package:for_u_partners/ui/views/drivers/vehicles/vehicles_view.dart';
import 'package:stacked/stacked.dart';

// mes_vehicules_viewmodel.dart
class MesVehiculesViewModel extends BaseViewModel {
  Vehicle? _vehiculeActif;
  List<Vehicle> _vehiculesApprouves = [];
  bool _isApprovedExpanded = true;

  Vehicle? get vehiculeActif => _vehiculeActif;
  List<Vehicle> get vehiculesApprouves => _vehiculesApprouves;
  bool get isApprovedExpanded => _isApprovedExpanded;

  Future<void> initialise() async {
    setBusy(true);
    // Ici vous appellerez votre API pour récupérer les données
    // Exemple:
    // _vehiculeActif = await _apiService.getVehiculeActif();
    // _vehiculesApprouves = await _apiService.getVehiculesApprouves();
    setBusy(false);
  }

  void toggleApprovedExpanded() {
    _isApprovedExpanded = !_isApprovedExpanded;
    notifyListeners();
  }

  void toggleCourseHeure(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.courseHeure = value;
      notifyListeners();
      // Appel API pour mettre à jour
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      // Appel API pour mettre à jour
    }
  }

  void addNewVehicle() {
    // Navigation vers la page d'ajout de véhicule
    print('Ajouter un nouveau véhicule');
  }
}