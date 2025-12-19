import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/models/global_stats_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:stacked/stacked.dart';

class StatistiquesViewModel extends BaseViewModel {
  final _driverService = locator<DriverService>();

  GlobalStats? _globalStats;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  GlobalStats? get globalStats => _globalStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StatistiquesViewModel() {
    loadGlobalStats();
  }

  Future<void> loadGlobalStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _globalStats = await _driverService.fetchGlobalStats();
    } catch (e) {
      _errorMessage = 'Impossible de charger les statistiques: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
