import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_model.dart';
import 'package:for_u_partners/services/pickers_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/views/delivery/activities_delivery/models/delivery_activity_model.dart';

class ActivitiesDeliveryViewModel extends BaseViewModel {
  final List<Demandes> _activities = [];
  List<Demandes> get activities => _activities;
  final navigationService = locator<NavigationService>();
  final pickerService = locator<PickersService>();
  BuildContext? _context;

  ActivitiesDeliveryViewModel() {
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setBusy(true);
      print('📦 Chargement des demandes de ramassage deja finies...');

      // Appeler le service pour récupérer les demandes
      final response = await pickerService.getActivityList();

      if (response.demandes != null) {
        activities.clear();
        activities.addAll(response.demandes!);

        print('✅ ${activities.length} demandes finies chargées');
      }
    } catch (e) {
      print('❌ Erreur chargement des demandes finies: $e');
      if (_context != null) {
        CustomToast.showError(_context!,
            message: 'Erreur lors du chargement des demandes');
      }
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  //* Obtenir la date formatée
  String formatDateTime(String input) {
    final dateTime = DateTime.parse(input);
    final formatter = DateFormat("dd/MM/yyyy 'à' HH:mm");
    return formatter.format(dateTime.toLocal());
  }

  //* Obtenir le statut formaté d'une demande
  String getDemandeStatusText(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'acceptee':
        return 'Acceptée';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return 'Affectée';
    }
  }

  //* Obtenir la couleur du statut
  Color getDemandeStatusColor(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'acceptee':
        return Colors.blue;
      case 'en_cours':
        return Colors.green;
      case 'terminee':
        return Colors.grey;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Fonction pour ajouter une nouvelle activité terminée
  // void addCompletedActivity({
  //   required String type,
  //   required String route,
  //   required DateTime endTime,
  //   required String distance,
  //   required String earning,
  // }) {
  //   final newActivity = DeliveryActivityModel(
  //     type: type,
  //     route: route,
  //     status: ActivityStatus.completed,
  //     timeAgo: DeliveryActivityModel.getTimeAgo(endTime),
  //     distance: distance,
  //     earning: earning,
  //   );

  //   _activities.insert(0, newActivity); // Ajouter en premier
  //   notifyListeners();
  // }

  // Fonction pour ajouter une activité annulée
  // void addCancelledActivity({
  //   required String type,
  //   required String route,
  //   required DateTime endTime,
  //   required String distance,
  // }) {
  //   final newActivity = DeliveryActivityModel(
  //     type: type,
  //     route: route,
  //     status: ActivityStatus.cancelled,
  //     timeAgo: DeliveryActivityModel.getTimeAgo(endTime),
  //     distance: distance,
  //     earning: '0 CFA',
  //   );

  //   _activities.insert(0, newActivity); // Ajouter en premier
  //   notifyListeners();
}

// Fonction pour mettre à jour les temps d'activité
// void updateActivityTimes() {
//   // Cette fonction peut être appelée périodiquement pour mettre à jour
//   // les temps affichés (ex: "Il y a 2h" devient "Il y a 3h")
//   // Pour cela, vous devriez stocker les DateTime réels dans le modèle
//   notifyListeners();
// }

// Fonction pour vider la liste
// void clearActivities() {
//   _activities.clear();
//   notifyListeners();
// }
// }

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
