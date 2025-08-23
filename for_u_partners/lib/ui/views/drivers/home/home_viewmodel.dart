import 'package:for_u_partners/models/daily_stats_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/tracking_service.dart';

class HomeViewModel extends BaseViewModel {
  final _sharedpreferencesService = locator<SharedpreferencesService>();
  final trackingService = TrackingService();

  final driverService = locator<DriverService>();

  // Données utilisateur

  String? name;
  double solde = 0;

  // Statistiques quotidiennes
  DailyStats? dailyStats;
  String? errorMessage;

  HomeViewModel() {
    initialise();
  }

  Future<void> initialise() async {
    setBusy(true);
    try {
      await Future.wait([
        getUserName(),
        getWalletSold(),
        getDailyStats(),
        registerDriverToken(),
        trackingService.demarrerTrackingContinu(),
      ]);
    } catch (e) {
      print("Erreur lors de l'initialisation: $e");
      errorMessage = "Erreur lors du chargement des données";
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Récupère les statistiques quotidiennes
  Future<void> getDailyStats() async {
    try {
      final stats = await driverService.fetchDailyStats();
      dailyStats = stats;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erreur lors de la récupération des statistiques';
      print('Erreur dans getDailyStats: $e');
      notifyListeners();
    }
  }

  // Récupère le nom de l'utilisateur
  Future<void> getUserName() async {
    try {
      name = await _sharedpreferencesService.getUserName() ?? "";
      notifyListeners();
    } catch (e) {
      name = "";
      print("Erreur lors de la récupération du nom: $e");
    }
  }


  // Enregistre le token de notification
  Future<void> registerDriverToken() async {
    try {
      await FirebaseMessagingService()
          .sendCurrentTokenToBackend(ApiConstant.saveFcmTokenDriver);
    } catch (e) {
      print("Erreur lors de l'enregistrement du token: $e");
    }
  }

  // Récupère le solde du portefeuille
  Future<void> getWalletSold() async {
    try {
      solde = await driverService.fetchWalletSold();
      print("WALLET SOLD: $solde");
      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement du solde: $e");
      errorMessage = "Impossible de charger le solde";
      rethrow;

    }
  }

  // Méthodes utilitaires pour accéder facilement aux données
  int get todayCourses => dailyStats?.totalActiviteToday ?? 0;
  String get todayEarnings => '${dailyStats?.montantGainToday ?? 0} FCFA';
  bool get hasActiveRide => dailyStats?.activiteEnCours != null;
  String get activeRideClientName =>
      dailyStats?.activiteEnCours?.clientNom ?? 'Client';
  String get activeRideDestination =>
      dailyStats?.activiteEnCours?.destinationClient ?? 'Destination inconnue';
  double get activeRideDistance =>
      dailyStats?.activiteEnCours?.distanceKm ?? 0.0;
  bool get hasRecentActivity => dailyStats?.activiteRecenteTerminee != null;
  bool get hasRatings => (dailyStats?.dernieresEvaluations.length ?? 0) > 0;
}
