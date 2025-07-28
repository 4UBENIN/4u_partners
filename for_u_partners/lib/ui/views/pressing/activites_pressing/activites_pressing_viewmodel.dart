import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/views/pressing/activites_pressing/models/pressing_activities_models.dart';

class ActivitesPressingViewModel extends BaseViewModel {
  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  int get todayCount => _activities.where((a) => a.isToday()).length;
  int get weekCount => _activities.where((a) => a.isThisWeek()).length;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  List<PressingActivityModel> getFilteredActivities() {
    if (_selectedFilter == 'all') return _activities;
    return _activities.where((a) => a.type == _selectedFilter).toList();
  }

  // Données d'exemple - remplacez par vos vraies données
  final List<PressingActivityModel> _activities = [
    PressingActivityModel(
      id: '1',
      clientName: 'Teddy TOSSOU',
      type: 'pickup',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'EREVAN, Cadjehoun Aeroport',
      amount: '5 000 FCFA',
      weight: '2.5',
      services: ['Lavage Xpress 24h', 'Repassage', 'Traitement de taches'],
      standardClothes: ['T-Shirt x 4', 'Pantalon x 3', 'Boxer x 4'],
      specialClothes: ['Veste complète x2'],
    ),
    PressingActivityModel(
      id: '2',
      clientName: 'Marie KOUASSI',
      type: 'deposit',
      date: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Cotonou Centre, Rue des Palmiers',
      amount: '3 500 FCFA',
      weight: '1.8',
      services: ['Lavage standard', 'Repassage'],
      standardClothes: ['Robe x 2', 'Chemisier x 3'],
      specialClothes: [],
    ),
    PressingActivityModel(
      id: '3',
      clientName: 'Jean SOGLO',
      type: 'pickup',
      date: DateTime.now().subtract(const Duration(days: 2)),
      location: 'Akpakpa, Marché International',
      amount: '7 200 FCFA',
      weight: '3.2',
      services: ['Lavage Xpress 24h', 'Repassage', 'Pliage'],
      standardClothes: ['Pantalon x 5', 'Chemise x 6'],
      specialClothes: ['Costume complet x1'],
    ),
  ];
}
