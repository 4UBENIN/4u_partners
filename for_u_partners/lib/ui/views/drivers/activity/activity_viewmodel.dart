import 'package:stacked/stacked.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/views/drivers/activity/models/activity_model.dart';

class ActivityViewModel extends BaseViewModel {
  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final _driverService = locator<DriverService>();
  final _navigationService = locator<NavigationService>();

  ActivityViewModel() {
    _initializeActivities();
  }

  Future<void> _initializeActivities() async {
    await loadActivities();
  }

  // Charger les activités depuis l'API de manière optimisée
  Future<void> loadActivities() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('⏳ Début du chargement des activités...');
      final startTime = DateTime.now();

      // 1. Récupérer la liste des courses
      final coursesList = await _driverService.getCoursesList();
      print('✅ ${coursesList.length} cours récupérés en ${DateTime.now().difference(startTime).inMilliseconds}ms');

      // 2. Préparer les appels API en parallèle
      final List<Future<ActivityModel>> futures = [];
      
      for (var course in coursesList) {
        futures.add(_loadCourseWithDetails(course));
      }

      // 3. Exécuter tous les appels en parallèle
      final loadedActivities = await Future.wait(futures);
      
      // 4. Trier par date de création (les plus récentes en premier)
      loadedActivities.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

      _activities = loadedActivities;
      print('✨ ${_activities.length} activités chargées en ${DateTime.now().difference(startTime).inMilliseconds}ms');
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des activités: $e';
      print('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode privée pour charger les détails d'une course
  Future<ActivityModel> _loadCourseWithDetails(Map<String, dynamic> course) async {
    try {
      // Si c'est une course terminée ou annulée, on a besoin des détails complets
      if (course['statut'] == 'termine' || course['statut'] == 'annule') {
        final details = await _driverService.getCourseDetails(course['id']);
        return ActivityModel.fromApiData({
          ...course,
          ...details, // Fusionner les données de base avec les détails
        });
      } else {
        // Pour les courses en cours ou en attente, on utilise les données de base
        return ActivityModel.fromApiData(course);
      }
    } catch (e) {
      print('⚠️ Erreur détails de la course ${course['id']}: $e');
      // En cas d'erreur, retourner les données de base
      return ActivityModel.fromApiData(course);
    }
  }

  // Rafraîchir la liste des activités
  Future<void> refreshActivities() async {
    await loadActivities();
  }

  // Obtenir une activité par son ID
  ActivityModel? getActivityById(int id) {
    try {
      return _activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour le statut d'une activité
  void updateActivityStatus(int activityId, String newStatus) {
    final index =
        _activities.indexWhere((activity) => activity.id == activityId);
    if (index != -1) {
      final updatedActivity = _activities[index];
      // Mettre à jour le statut (cette partie peut être adaptée selon vos besoins)
      _activities[index] = ActivityModel.fromApiData({
        ...updatedActivity.toJson(),
        'statut': newStatus,
      });
      notifyListeners();
    }
  }
}

// Extension pour convertir un ActivityModel en Map (utile pour les mises à jour)
extension ActivityModelExtension on ActivityModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': id,
      'numero': numero,
      'adresse_depart': adresseDepart,
      'adresse_arrivee': adresseArrivee,
      'statut': status.toString().split('.').last,
      'créée_le': dateCreation.toIso8601String(),
      'distance_km': double.tryParse(distance.replaceAll(' km', '')) ?? 0,
      'montant':
          double.tryParse(earning.replaceAll(' CFA', '').replaceAll(' ', '')) ??
              0,
      'mode_paiement': modePaiement,
      'vehicule': vehicule,
      'client': client,
      'point_depart': pointDepart,
      'point_arrivee': pointArrivee,
    };
  }
}
