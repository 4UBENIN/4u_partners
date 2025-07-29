import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/models/delivery_activity_model.dart';

class ActivitiesDeliveryViewModel extends BaseViewModel {
  List<DeliveryActivityModel> _activities = [];
  List<DeliveryActivityModel> get activities => _activities;
  final navigationService = locator<NavigationService>();
  ActivitiesDeliveryViewModel() { 
    _initializeActivities();
  }

  void _initializeActivities() {
    // Données d'exemple basées sur le HTML
    _activities = [
      DeliveryActivityModel(
          type: 'Livraison',
          route: 'Cotonou → Fidjrossè',
          status: ActivityStatus.inprogress,
          timeAgo: 'Il y a 2h',
          distance: '28 km',
          earning: '4,500 CFA',
          totalTime: '1h',
          tarifkm: '161'),
      DeliveryActivityModel(
          type: 'Ramassage',
          route: 'Akpakpa → 4U Akpakpa',
          status: ActivityStatus.completed,
          timeAgo: 'Il y a 3h',
          distance: '2 km',
          earning: '1,200 CFA',
          totalTime: '30min',
          tarifkm: '161'),
      DeliveryActivityModel(
          type: 'Livraison',
          route: 'Cotonou → Abomey-Calavi',
          status: ActivityStatus.completed,
          timeAgo: 'Il y a 5h',
          distance: '18 km',
          earning: '3,800 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      DeliveryActivityModel(
          type: 'Livraison',
          route: 'Godomey → Calavi',
          status: ActivityStatus.cancelled,
          timeAgo: 'Il y a 6h',
          distance: '8 km',
          earning: '0 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      DeliveryActivityModel(
          type: 'Ramassage',
          route: 'Fidjrossè → 4U Fidjrossè',
          status: ActivityStatus.completed,
          timeAgo: 'Hier',
          distance: '2 km',
          earning: '1,200 CFA',
          totalTime: '2h',
          tarifkm: '161'),
      DeliveryActivityModel(
          type: 'Livraison',
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
    final newActivity = DeliveryActivityModel(
      type: type,
      route: route,
      status: ActivityStatus.completed,
      timeAgo: DeliveryActivityModel.getTimeAgo(endTime),
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
    final newActivity = DeliveryActivityModel(
      type: type,
      route: route,
      status: ActivityStatus.cancelled,
      timeAgo: DeliveryActivityModel.getTimeAgo(endTime),
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

// Extension du modèle DeliveryActivityModel si vous voulez stocker les vraies dates
class DeliveryActivityModelWithDate extends DeliveryActivityModel {
  final DateTime endTime;

  DeliveryActivityModelWithDate({
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
          timeAgo: DeliveryActivityModel.getTimeAgo(endTime),
          distance: distance,
          earning: earning,
        );

  // Méthode pour mettre à jour le timeAgo basé sur l'heure actuelle
  String get currentTimeAgo => DeliveryActivityModel.getTimeAgo(endTime);
}
