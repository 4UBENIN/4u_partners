import 'package:for_u_partners/models/daily_stats_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:stacked/stacked.dart';
import 'package:for_u_partners/ui/common/get_fcm_token.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'dart:async';
import 'package:for_u_partners/services/tracking_service.dart';
import 'package:location/location.dart';

class HomeViewModel extends BaseViewModel {
  Timer? _heartbeatTimer;
  final Location _location = Location();
  final _sharedpreferencesService = locator<SharedpreferencesService>();
  final trackingService = TrackingService();
  final driverService = locator<DriverService>();
  int todayCourses = 0;
  double montantGainToday = 0.0;
  // Données utilisateur
  String? name;
  double balance = 0.0;

  // Statistiques quotidiennes
  DailyStats? dailyStats;
  String? errorMessage;

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  HomeViewModel() {
    initialise();
    _loadOnlineStatus();
  }

  // Charger l'état enregistré
  Future<void> _loadOnlineStatus() async {
    _isOnline = await _sharedpreferencesService.getOnlineStatus() ?? true;
    notifyListeners();
  }

  // Basculer entre en ligne/hors ligne
  Future<void> toggleOnlineStatus() async {
    try {
      setBusy(true);
      _isOnline = !_isOnline;
      await _sharedpreferencesService.setOnlineStatus(_isOnline);

      // Appeler l'API appropriée
      if (_isOnline) {
        await driverService.goOnline();
      } else {
        await driverService.goOffline();
      }

      notifyListeners();
    } catch (e) {
      // En cas d'erreur, on revient à l'état précédent
      _isOnline = !_isOnline;
      errorMessage = "Erreur lors du changement d'état";
      notifyListeners();
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> initialise() async {
    setBusy(true);
    try {
      await Future.wait([
        getUserName(),
        getWalletBalance(),
        getDailyStats(),
        registerDriverToken(),
        trackingService.demarrerTrackingContinu(),
      ]);

      // Démarrer le timer des heartbeats après l'initialisation
      _startHeartbeatTimer();

      _debugLogCourses();
    } catch (e) {
      print("Erreur lors de l'initialisation: $e");
      errorMessage = "Erreur lors du chargement des données";
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> _debugLogCourses() async {
    try {
      print('🔍 DEBUG: Fetching courses list...');
      final courses = await driverService.getCoursesList();

      final activeCourse = courses.firstWhere(
        (course) => course['statut'] == 'chauffeur_en_route',
        orElse: () => {},
      );

      if (activeCourse.isNotEmpty) {
        print('🔍 DEBUG: Found active course, fetching full details...');
        await driverService.getCourseDetails(activeCourse['id']);
      } else {
        print('🔍 DEBUG: No active course found');
      }
    } catch (e) {
      print('🔍 DEBUG: Error fetching courses: $e');
    }
  }

  // Récupère les statistiques quotidiennes
  Future<void> getDailyStats() async {
    try {
      final stats = await driverService.fetchDailyStats();
      dailyStats = stats;
      todayCourses = dailyStats?.totalActiviteToday ?? 0;
      montantGainToday = (dailyStats?.montantGainToday ?? 0).toDouble();
      print("MONTANT GAIN TODAY: $montantGainToday");
      print("TOTAL ACTIVITE TODAY: ${dailyStats?.totalActiviteToday}");
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

  // Récupère la balance du portefeuille
  Future<void> getWalletBalance() async {
    try {
      balance = await driverService.fetchWalletSold();
      print("WALLET BALANCE: $balance");
      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement de la balance: $e");
      errorMessage = "Impossible de charger la balance";
      rethrow;
    }
  }

  // Méthodes utilitaires pour accéder facilement aux données
  bool get hasActiveRide => dailyStats?.activiteEnCours != null;
  String get activeRideClientName =>
      dailyStats?.activiteEnCours?.clientNom ?? 'Client';
  String get activeRideDestination =>
      dailyStats?.activiteEnCours?.destinationClient ?? 'Destination inconnue';
  double get activeRideDistance =>
      dailyStats?.activiteEnCours?.distanceKm ?? 0.0;
  bool get hasRecentActivity => dailyStats?.activiteRecenteTerminee != null;
  bool get hasRatings => (dailyStats?.dernieresEvaluations.length ?? 0) > 0;

  // Démarrer le timer pour les heartbeats
  void _startHeartbeatTimer() {
    // Annuler le timer existant s'il y en a un
    _heartbeatTimer?.cancel();

    // Exécuter immédiatement le premier appel
    _sendHeartbeat();

    // Puis programmer un appel toutes les 5 minutes
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      print("Heartbeat envoyé avec succès");
      _sendHeartbeat();
    });
  }

  // Envoyer un heartbeat avec la position actuelle
  Future<void> _sendHeartbeat() async {
    try {
      final location = await _location.getLocation();
      await driverService.postdriverheartbeat(
          location.latitude ?? 0.0, location.longitude ?? 0.0);
      print('Heartbeat envoyé avec succès');
    } catch (e) {
      print('Erreur lors de l\'envoi du heartbeat: $e');
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    super.dispose();
  }
}
