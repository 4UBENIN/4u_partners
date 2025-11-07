import 'dart:async';

import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/models/daily_stats_model.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/services/tracking_service.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';

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
  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;
  bool get hasLocation => _currentPosition != null;
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;
  StreamSubscription<LocationData>? _locationSubscription;

  HomeViewModel() {
    initialise();
    _loadOnlineStatus();
  }

  // Charger l'état enregistré
  Future<void> _loadOnlineStatus() async {
    _isOnline = await _sharedpreferencesService.getOnlineStatus() ?? true;
    notifyListeners();
  }

  Future<void> toggleOnlineStatus() async {
    try {
      setBusy(true);
      _isOnline = !_isOnline;

      print("toggle-online-status: $_isOnline");

      await driverService.updateStatus(_isOnline);
      await _sharedpreferencesService.setOnlineStatus(_isOnline);

      print("status-updated-successfully: $_isOnline");
      notifyListeners();
    } catch (e) {
      _isOnline = !_isOnline;
      errorMessage = "Erreur lors du changement d'état";
      print("error-toggle-status: $e");
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
        trackingService.demarrerTrackingContinu(),
      ]);

      _startHeartbeatTimer();

      await _initialiseLocationTracking();

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

  Future<void> _initialiseLocationTracking() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          errorMessage = "Activez la localisation pour afficher la carte";
          notifyListeners();
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          errorMessage = "Autorisez l'accès à la localisation";
          notifyListeners();
          return;
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        errorMessage =
            "Autorisez la localisation depuis les réglages de l'appareil";
        notifyListeners();
        return;
      }

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 4000,
        distanceFilter: 10,
      );

      final currentLocation = await _location.getLocation();
      _setCurrentLocation(currentLocation);

      if (_mapController != null && _currentPosition != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 15.5,
            ),
          ),
        );
      }

      _locationSubscription?.cancel();
      _locationSubscription = _location.onLocationChanged.listen((event) {
        _setCurrentLocation(event, animate: true);
      });
    } catch (e) {
      print('Erreur lors de l\'initialisation de la localisation: $e');
      errorMessage = "Impossible de récupérer votre position";
      notifyListeners();
    }
  }

  void _setCurrentLocation(LocationData data, {bool animate = false}) {
    final latitude = data.latitude;
    final longitude = data.longitude;
    if (latitude == null || longitude == null) {
      return;
    }

    final newPosition = LatLng(latitude, longitude);
    final hadError = errorMessage != null;
    final hasMoved = _currentPosition == null ||
        _currentPosition!.latitude != newPosition.latitude ||
        _currentPosition!.longitude != newPosition.longitude;

    _currentPosition = newPosition;

    if (animate && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 16,
          ),
        ),
      );
    }

    if (hadError) {
      errorMessage = null;
    }

    if (hasMoved || hadError) {
      notifyListeners();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 15.5,
          ),
        ),
      );
    }
  }

  Future<void> recenterOnDriver() async {
    if (_mapController == null || _currentPosition == null) {
      return;
    }
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }
}
