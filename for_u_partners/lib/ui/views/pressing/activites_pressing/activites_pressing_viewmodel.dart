import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/depot_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_model.dart';
import 'package:for_u_partners/services/pressing_service.dart';
import 'package:stacked/stacked.dart';

class ActivitesPressingViewModel extends BaseViewModel {
  final _pressingService = locator<PressingService>();

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  // Dépôts
  List<Depot> _depots = [];
  List<Depot> get depot => _depots;

  // Ramassages
  List<Ramassage> _ramassages = [];
  List<Ramassage> get ramassages => _ramassages;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // (optionnel) statistiques simples (tu peux les remplir depuis /dashboard si tu veux)
  int? get todayCount => null;
  int? get weekCount => null;

  /// Charge les activités selon le filtre sélectionné.
  /// si filter == null, on utilise le filtre courant.
  Future<void> loadFinishedActivities({String? filter}) async {
    final f = filter ?? _selectedFilter;
    setBusy(true);
    _errorMessage = null;

    try {
      if (f == 'pickup') {
        _ramassages = await _pressingService.getFinishedRamassageList();
      } else if (f == 'deposit') {
        _depots = await _pressingService.getFinishedDepotList();
      } else {
        //Toutes : on charge les deux listes en parallèle
        final results = await Future.wait([
          _pressingService.getFinishedDepotList(),
          _pressingService.getFinishedRamassageList(),
        ]);
        _depots = results[0] as List<Depot>;
        _ramassages = results[1] as List<Ramassage>;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Change le filtre et recharge les données adaptées.
  void setFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
    loadFinishedActivities(filter: filter);
  }
}
