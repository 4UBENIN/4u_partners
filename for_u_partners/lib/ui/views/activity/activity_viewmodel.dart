import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/activity/models/activity_model.dart';

class ActivityViewModel extends BaseViewModel {
  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;
  final navigationService = locator<NavigationService>();
  ActivityViewModel() {
    _initializeActivities();
  }

  void _initializeActivities() {
    // Données d'exemple basées sur le HTML
    _activities = [
      ActivityModel(
          type: 'Course standard',
          route: 'Cotonou → Porto-Novo',
          status: ActivityStatus.inprogress,
          timeAgo: 'Il y a 2h',
          distance: '28 km',
          earning: '4,500 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      ActivityModel(
          type: 'Course express',
          route: 'Akpakpa → Ganhi',
          status: ActivityStatus.completed,
          timeAgo: 'Il y a 3h',
          distance: '12 km',
          earning: '2,200 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      ActivityModel(
          type: 'Course longue',
          route: 'Cotonou → Abomey-Calavi',
          status: ActivityStatus.completed,
          timeAgo: 'Il y a 5h',
          distance: '18 km',
          earning: '3,800 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      ActivityModel(
          type: 'Course standard',
          route: 'Godomey → Calavi',
          status: ActivityStatus.cancelled,
          timeAgo: 'Il y a 6h',
          distance: '8 km',
          earning: '0 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      ActivityModel(
          type: 'Course premium',
          route: 'Fidjrossè → Aéroport',
          status: ActivityStatus.completed,
          timeAgo: 'Hier',
          distance: '15 km',
          earning: '6,200 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      ActivityModel(
          type: 'Course standard',
          route: 'Godomey → Calavi',
          status: ActivityStatus.inprogress,
          timeAgo: 'Il y a 6h',
          distance: '8 km',
          earning: '0 CFA',
          totalTime: '2h',
          tarifkm: '161'),
    ];
    notifyListeners();
  }

  // Fonction pour ajouter une nouvelle activité terminée
  void addCompletedActivity({
    required String type,
    required String route,
    required DateTime endTime,
    required String distance,
    required String earning,
  }) {
    final newActivity = ActivityModel(
      type: type,
      route: route,
      status: ActivityStatus.completed,
      timeAgo: ActivityModel.getTimeAgo(endTime),
      distance: distance,
      earning: earning,
    );

    _activities.insert(0, newActivity); // Ajouter en premier
    notifyListeners();
  }

  // Fonction pour ajouter une activité annulée
  void addCancelledActivity({
    required String type,
    required String route,
    required DateTime endTime,
    required String distance,
  }) {
    final newActivity = ActivityModel(
      type: type,
      route: route,
      status: ActivityStatus.cancelled,
      timeAgo: ActivityModel.getTimeAgo(endTime),
      distance: distance,
      earning: '0 CFA',
    );

    _activities.insert(0, newActivity); // Ajouter en premier
    notifyListeners();
  }

  // Fonction pour mettre à jour les temps d'activité
  void updateActivityTimes() {
    // Cette fonction peut être appelée périodiquement pour mettre à jour
    // les temps affichés (ex: "Il y a 2h" devient "Il y a 3h")
    // Pour cela, vous devriez stocker les DateTime réels dans le modèle
    notifyListeners();
  }

  // Fonction pour vider la liste
  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }
}

// Extension du modèle ActivityModel si vous voulez stocker les vraies dates
class ActivityModelWithDate extends ActivityModel {
  final DateTime endTime;

  ActivityModelWithDate({
    required String type,
    required String route,
    required ActivityStatus status,
    required this.endTime,
    required String distance,
    required String earning,
  }) : super(
          type: type,
          route: route,
          status: status,
          timeAgo: ActivityModel.getTimeAgo(endTime),
          distance: distance,
          earning: earning,
        );

  // Méthode pour mettre à jour le timeAgo basé sur l'heure actuelle
  String get currentTimeAgo => ActivityModel.getTimeAgo(endTime);
}
