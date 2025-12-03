import 'dart:async';
import 'dart:convert';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/course_event_service.dart';
import 'package:for_u_partners/services/course_notificationstorage_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/services/marker_icon_service.dart';
import 'package:for_u_partners/services/location_tracking_service.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:for_u_partners/ui/common/api_constant.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io' show Platform;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:for_u_partners/services/local_notif_service.dart';
import 'package:for_u_partners/services/ride/ride_persistence_service.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel.dart';
import 'package:for_u_partners/services/course_restoration_service.dart';
import 'package:for_u_partners/services/arrival_state_service.dart';
import 'package:for_u_partners/services/tracking_service.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;

class CoursesViewModel extends BaseViewModel {
  final _driverService = locator<DriverService>();
  final _arrivalStateService = locator<ArrivalStateService>();
  final _trackingService = TrackingService();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  LatLng _mapCenter = const LatLng(48.8566, 2.3522);
  LatLng get mapCenter => _mapCenter;

  double _mapZoom = 16.5;
  double get mapZoom => _mapZoom;

  final Set<Marker> _markers = <Marker>{};
  Set<Marker> get markers => _markers;

  // Liste des conducteurs en ligne
  List<DriverLocation> _onlineDrivers = [];
  List<DriverLocation> get onlineDrivers => _onlineDrivers;

  // Timer pour le rafraîchissement des conducteurs en ligne
  Timer? _driversRefreshTimer;

  // Polylines pour les trajets
  final Set<Polyline> _polylines = <Polyline>{};
  Set<Polyline> get polylines => _polylines;

  // Course actuellement sélectionnée
  ClientData? _currentCourse;
  ClientData? get currentCourse => _currentCourse;
  set currentCourse(ClientData? course) => _currentCourse = course;

  // Current user location
  LatLng? _currentLocation;

  // Current vehicle type (e.g., "moto", "voiture")
  String? _vehicleType;

  // État du trajet
  bool _isGoingToPickup = false;
  bool get isGoingToPickup => _isGoingToPickup;

  bool _isOnTrip = false;
  bool get isOnTrip => _isOnTrip;

  String? _destinationName;

  final CourseEventService _courseEventService = CourseEventService();
  StreamSubscription<CourseNotificationData>? _newCourseSubscription;
  StreamSubscription<CourseNotificationData>? _courseUpdateSubscription;

  // Liste des courses disponibles
  final List<ClientData> _availableCourses = [];
  List<ClientData> get availableCourses => _availableCourses;

  // Current location name
  String? _currentLocationName;

  // Référence au ViewModel principal
  HomemainViewModel? _homeMainViewModel;

  void setHomeMainViewModel(HomemainViewModel viewModel) {
    _homeMainViewModel = viewModel;
  }

  // Mettre à jour le compteur de courses en attente
  void _updatePendingCoursesCount() {
    if (_homeMainViewModel != null) {
      _homeMainViewModel!.updatePendingCoursesCount(_availableCourses.length);
    }
  }

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  // ✨ État de chargement des notifications
  bool _isLoadingCourses = true;
  bool get isLoadingCourses => _isLoadingCourses;

  // Loading state for general operations
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // État de restauration
  bool _isRestoringState = false;
  bool get isRestoringState => _isRestoringState;

  loc.LocationData? _currentPosition;
  loc.LocationData? get currentPosiction => _currentPosition;

  BottomSheetAppType _currentBottomSheetType = BottomSheetAppType.none;
  BottomSheetAppType get currentBottomSheetType => _currentBottomSheetType;

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  final driverservice = locator<DriverService>();
  final navigationService = locator<NavigationService>();
  final _locationService = locator<LocationTrackingService>();
  StreamSubscription<loc.LocationData>? _locationStreamSubscription;

  static const String _googleApiKey = 'AIzaSyAVtrvygnbsdnL6VMEJS_DB0JfEa0piHqM';
  static const Set<String> _allowedCourseStatuses = {
    'en_attente_chauffeur',
    'attente',
    'en_attente',
  };

  String? _error;
  bool _isInitialized = false;

  CoursesViewModel();

  // ✨ Initialisation complète du ViewModel
  Future<void> initializeViewModel() async {
    // Prevent double initialization
    if (_isInitialized) {
      print('⚠️ ViewModel already initialized, skipping...');
      return;
    }
    _isInitialized = true;
    print('✅ Initializing ViewModel for the first time...');

    // Load vehicle type from SharedPreferences
    _vehicleType = await _sharedPreferencesService.getActiveVehicleType();
    debugPrint('🚗 [Vehicle] Loaded vehicle type from cache: $_vehicleType');

    // TODO: If vehicle type is null, fetch it from API
    // if (_vehicleType == null) {
    //   debugPrint('⏳ [Vehicle] Vehicle type is null, fetching from API...');
    //   await _fetchVehicleTypeFromAPI();
    // }

    // Initialize location service and get last known location (instant)
    await _initializeLocation();

    // Load stored notifications
    await _loadStoredNotifications();

    _setupCourseListeners();

    // Start real-time location tracking (non-blocking)
    _startLocationTracking();

    // Démarrer le rafraîchissement des conducteurs en ligne
    startDriversRefresh();

    // Check for pending course restoration
    await _checkPendingRestoration();

    // ✅ Start continuous general position tracking if driver is online
    await _startGeneralPositionTracking();

    // Afficher le bottom sheet s'il y a des courses
    print(
        '🔍 État après _loadStoredNotifications - availableCourses: ${_availableCourses.length}');
    print(
        '🔍 Contenu de availableCourses: ${_availableCourses.map((c) => '${c.courseId}: ${c.name}').toList()}');

    if (_availableCourses.isNotEmpty) {
      setBottomSheetType(BottomSheetAppType.clients);
      // Draw route for the first available course
      if (_availableCourses.isNotEmpty) {
        await _drawRouteForNewCourse(_availableCourses.first);
      }
    }
    print("currentBottomSheetType: $_currentBottomSheetType");
  }

  /// Check for pending course restoration from app resume
  Future<void> _checkPendingRestoration() async {
    try {
      debugPrint('🔍 [Restoration] Checking for pending course restoration...');
      final restorationService = locator<CourseRestorationService>();
      final pendingCourse = restorationService.consumePendingRestoration();

      if (pendingCourse != null) {
        debugPrint('📦 [Restoration] Found pending course restoration!');
        debugPrint('📦 [Restoration] Course data: $pendingCourse');
        await restoreActiveCourse(pendingCourse);
      } else {
        debugPrint('ℹ️ [Restoration] No pending course restoration found');
      }
    } catch (e) {
      debugPrint('❌ [Restoration] Error checking pending restoration: $e');
    }
  }

  // ✨ Charger les notifications stockées au démarrage
  Future<void> _loadStoredNotifications() async {
    try {
      _isLoadingCourses = true;
      notifyListeners();

      print('📱 Chargement des notifications stockées...');

      // Nettoyer d'abord les notifications expirées
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(minutes: 15), // Augmenté à 15 minutes
      );

      // Récupérer uniquement les notifications valides
      final storedNotifications =
          await CourseNotificationStorage.getValidNotifications(
        maxAge: const Duration(minutes: 15), // Augmenté à 15 minutes
      );

      print(
          '📱 ${storedNotifications.length} notifications trouvées en storage');

      // Vérifier si des notifications ont été supprimées
      if (storedNotifications.isEmpty) {
        // Si aucune notification valide, vider complètement la liste
        if (_availableCourses.isNotEmpty) {
          _availableCourses.clear();
          _updatePendingCoursesCount();
          print('🧹 Aucune notification valide, liste des courses vidée');
        }
        // Clear route-specific markers and polylines when no courses
        _polylines.clear();
        _markers.removeWhere((marker) =>
          marker.markerId.value == 'pickup_point' ||
          marker.markerId.value == 'destination_point'
        );
        print('🧹 Cleared route markers and polylines (no stored notifications)');
      } else {
        // Convertir les notifications en ClientData
        final validCourseIds = <String>[];

        for (final notification in storedNotifications) {
          final clientData = notification.toClientData();
          validCourseIds.add(notification.courseId);

          // Vérifier si pas déjà dans la liste (éviter doublons)
          final existingIndex = _availableCourses.indexWhere(
            (course) => course.courseId == notification.courseId,
          );

          if (existingIndex == -1) {
            _availableCourses.add(clientData);
            print('✅ Course chargée depuis storage: ${clientData.name}');
          } else {
            // Mettre à jour la course existante
            _availableCourses[existingIndex] = clientData;
            print('🔄 Course mise à jour depuis storage: ${clientData.name}');
          }
        }

        // Supprimer les courses qui ne sont plus dans le stockage
        _availableCourses.removeWhere((course) =>
            course.courseId != null &&
            !validCourseIds.contains(course.courseId));

        // Trier par courseId (plus récent en premier)
        _availableCourses.sort((a, b) => b.courseId!.compareTo(a.courseId!));

        // Mettre à jour le compteur de courses en attente
        _updatePendingCoursesCount();
      }

      _isLoadingCourses = false;
      notifyListeners();

      print('✅ ${_availableCourses.length} courses chargées au total');

      // Si aucune course disponible ET aucune course active, cacher le bottom sheet
      if (_availableCourses.isEmpty && _currentCourse == null) {
        hideBottomSheet();
      }
    } catch (e) {
      print('❌ Erreur chargement notifications stockées: $e');
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // ✨ Méthode pour rafraîchir manuellement les notifications
  Future<void> refreshStoredNotifications() async {
    _availableCourses.clear(); // Vider la liste actuelle
    await _loadStoredNotifications();

    // Réafficher le bottom sheet si nécessaire
    if (_availableCourses.isNotEmpty &&
        _currentBottomSheetType == BottomSheetAppType.none) {
      setBottomSheetType(BottomSheetAppType.clients);
    } else if (_availableCourses.isEmpty && _currentCourse == null) {
      // Clear route-specific markers and polylines when no courses remain
      _polylines.clear();
      _markers.removeWhere((marker) =>
        marker.markerId.value == 'pickup_point' ||
        marker.markerId.value == 'destination_point'
      );
      hideBottomSheet();
      print('🧹 No courses after refresh, cleared route markers and polylines');
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    try {
      _mapController = controller;
      if (_currentPosition != null) {
        await _moveToPosition(
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        );
      }
      // Forcer un rafraîchissement de l'affichage
      notifyListeners();
    } catch (e) {
      print('Erreur dans onMapCreated: $e');
      // En cas d'erreur, on réessaie d'initialiser la carte après un court délai
      await Future.delayed(const Duration(milliseconds: 500));
      if (_mapController != null) {
        await onMapCreated(_mapController!);
      }
    }
  }

  // Initialize location service and load last known position (instant)
  Future<void> _initializeLocation() async {
    try {
      print("📍 Initializing location service...");

      // Initialize and get last known location from storage (instant, no blocking)
      final lastKnown = await _locationService.initialize();

      if (lastKnown != null) {
        _currentPosition = lastKnown;
        _isLoadingLocation = false;

        print(
            "✅ Last known position loaded: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");

        // Update map center
        _mapCenter = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);

        // Move map to last known position
        if (_mapController != null) {
          await _moveToPosition(_mapCenter);
        }

        await _addUserLocationMarker();
        notifyListeners();
      } else {
        // No stored location, get current location once
        await _getCurrentLocationOnce();
      }
    } catch (e) {
      print('❌ Error initializing location: $e');
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // Get current location once (fallback)
  Future<void> _getCurrentLocationOnce() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      final location = await _locationService.getCurrentLocation();

      if (location != null) {
        _currentPosition = location;
        _isLoadingLocation = false;

        if (location.latitude != null && location.longitude != null) {
          _mapCenter = LatLng(location.latitude!, location.longitude!);

          if (_mapController != null) {
            await _moveToPosition(_mapCenter);
          }
        }

        await _addUserLocationMarker();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error getting current location: $e');
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // Start real-time location tracking (non-blocking)
  void _startLocationTracking() {
    print("🎯 Starting real-time location tracking...");

    // Start tracking
    _locationService.startTracking();

    // Listen to location updates
    _locationStreamSubscription = _locationService.locationStream.listen(
      (loc.LocationData locationData) {
        _currentPosition = locationData;

        // Update driver marker position smoothly
        _updateDriverMarkerPosition(locationData);

        print(
            "📍 Location updated: ${locationData.latitude}, ${locationData.longitude}");
      },
      onError: (error) {
        print('❌ Location stream error: $error');
      },
    );
  }

  // Update driver marker position without full reload
  void _updateDriverMarkerPosition(loc.LocationData location) async {
    if (location.latitude == null || location.longitude == null) return;

    final newPosition = LatLng(location.latitude!, location.longitude!);

    try {
      // Find the driver marker
      final driverMarker = _markers.firstWhere(
        (marker) => marker.markerId.value == 'user_location',
      );

      // Remove old marker
      _markers.removeWhere((marker) => marker.markerId.value == 'user_location');

      // Add updated marker
      _markers.add(
        driverMarker.copyWith(
          positionParam: newPosition,
        ),
      );

      // Move camera to follow driver with street-level zoom
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16.5),
        );
      }

      debugPrint('🚗 Driver marker updated: ${location.latitude}, ${location.longitude}');
      // DON'T call notifyListeners() here to avoid bottom sheet flickering
      // The map will update automatically via the markers Set
    } catch (e) {
      // Marker doesn't exist yet, create it
      debugPrint('⚠️ Driver marker not found, creating new one at ${location.latitude}, ${location.longitude}');
      final driverIcon = await MarkerIconService.getDriverMarker(vehicleType: _vehicleType);
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: newPosition,
          icon: driverIcon,
          infoWindow: const InfoWindow(
            title: 'Ma position',
            snippet: 'Vous êtes ici',
          ),
        ),
      );

      // Move camera to new marker with street-level zoom
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16.5),
        );
      }

      debugPrint('✅ Driver marker created');
      // Only notify on first marker creation
      notifyListeners();
    }
  }

  Future<void> _moveToPosition(LatLng position) async {
    try {
      if (_mapController == null) {
        print('Erreur: _mapController est null dans _moveToPosition');
        return;
      }

      // Vérifier si la position est valide
      if (position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        print('Position invalide: $position');
        return;
      }

      // Utiliser un try-catch pour capturer les erreurs potentielles
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(position, _mapZoom),
      );

      // Mettre à jour le centre de la carte
      _mapCenter = position;
      notifyListeners();
    } catch (e) {
      print('Erreur dans _moveToPosition: $e');
      // En cas d'erreur, on réessaie après un court délai
      await Future.delayed(const Duration(milliseconds: 300));
      if (_mapController != null) {
        _moveToPosition(position);
      }
    }
  }

  Future<void> _addUserLocationMarker() async {
    // Only remove the user_location marker, not all markers
    _markers.removeWhere((marker) => marker.markerId.value == 'user_location');

    if (_currentPosition != null) {
      final driverIcon = await MarkerIconService.getDriverMarker(vehicleType: _vehicleType);
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position:
              LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
          icon: driverIcon,
          infoWindow: const InfoWindow(
            title: 'Ma position',
            snippet: 'Vous êtes ici',
          ),
        ),
      );
    }
  }

  List<ClientData> getClientsList() {
    return _availableCourses;
  }

  void _setupCourseListeners() {
    _newCourseSubscription = _courseEventService.newCourseStream.listen(
      (courseData) {
        print(
            '🚗 Nouvelle course reçue dans ViewModel: ${courseData.toString()}');
        _onNewCourseReceived(courseData);
      },
      onError: (error) {
        print('❌ Erreur stream nouvelle course: $error');
      },
    );

    _courseUpdateSubscription = _courseEventService.courseUpdateStream.listen(
      (courseData) {
        print('🔄 Course mise à jour dans ViewModel: ${courseData.toString()}');
        _onCourseUpdated(courseData);
      },
      onError: (error) {
        print('❌ Erreur stream mise à jour course: $error');
      },
    );
  }

  void _onNewCourseReceived(CourseNotificationData courseData) {
    final clientData = courseData.toClientData();

    final existingIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseData.courseId,
    );

    if (existingIndex == -1) {
      _availableCourses.insert(0, clientData);
      print('✅ Course ajoutée: ${clientData.name}');
      print('📍 Coordonnées de la course:');
      print('   - Départ: (${clientData.depLat}, ${clientData.depLong})');
      print(
          '   - Destination: (${clientData.destLat}, ${clientData.destLong})');

      // Automatically draw route polyline for the new course
      _drawRouteForNewCourse(clientData);
    } else {
      _availableCourses[existingIndex] = clientData;
      print('🔄 Course mise à jour: ${clientData.name}');
    }

    if (_currentBottomSheetType != BottomSheetAppType.clients) {
      setBottomSheetType(BottomSheetAppType.clients);
    }

    // Mettre à jour le compteur de courses en attente
    _updatePendingCoursesCount();

    notifyListeners();
  }

  // Draw route polyline when a new course is received
  Future<void> _drawRouteForNewCourse(ClientData course) async {
    if (course.depLat == null || course.depLong == null ||
        course.destLat == null || course.destLong == null) {
      print('⚠️ Course coordinates missing, skipping route draw');
      return;
    }

    // Wait for initialization to complete before drawing routes
    if (!_isInitialized || _currentPosition == null) {
      print('⚠️ ViewModel not fully initialized or location not ready, skipping route draw for now');
      return;
    }

    try {
      final pickupLatLng = LatLng(course.depLat!, course.depLong!);
      final destLatLng = LatLng(course.destLat!, course.destLong!);

      // Clear existing polylines and route-specific markers only
      _polylines.clear();
      _markers.removeWhere((marker) =>
        marker.markerId.value == 'pickup_point' ||
        marker.markerId.value == 'destination_point'
      );

      // Ensure user location marker exists
      await _addUserLocationMarker();

      // Load custom marker icons
      final pickupIcon = await MarkerIconService.getPickupMarker();
      final destinationIcon = await MarkerIconService.getDestinationMarker();

      // Add pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickupLatLng,
          icon: pickupIcon,
          infoWindow: const InfoWindow(title: 'Point de départ'),
        ),
      );

      // Add destination marker
      _markers.add(
        Marker(
          markerId: const MarkerId('destination_point'),
          position: destLatLng,
          icon: destinationIcon,
          infoWindow: InfoWindow(title: course.destination),
        ),
      );

      // Draw single route: driver -> pickup -> destination
      PolylinePoints polylinePoints = PolylinePoints(apiKey: _googleApiKey);

      PolylineResult resultToPickup = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
          destination: PointLatLng(pickupLatLng.latitude, pickupLatLng.longitude),
          mode: TravelMode.driving,
        ),
      );

      PolylineResult resultToDestination = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(pickupLatLng.latitude, pickupLatLng.longitude),
          destination: PointLatLng(destLatLng.latitude, destLatLng.longitude),
          mode: TravelMode.driving,
        ),
      );

      // Add dashed polyline from driver to pickup (primary color)
      if (resultToPickup.points.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_pickup'),
            color: kcPrimaryColor,
            width: 4,
            points: resultToPickup.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
      }

      // Add solid polyline from pickup to destination (black)
      if (resultToDestination.points.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_destination'),
            color: Colors.black,
            width: 4,
            points: resultToDestination.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
          ),
        );
      }

      // Animate camera to show all markers
      if (_mapController != null) {
        final currentLatLng = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
        final bounds = _calculateBounds([
          currentLatLng,
          pickupLatLng,
          destLatLng,
        ]);

        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }

      notifyListeners();
      print('✅ Route tracée automatiquement pour la course ${course.courseId}');
    } catch (e) {
      print('❌ Erreur lors du tracé de la route: $e');
    }
  }

  void _onCourseUpdated(CourseNotificationData courseData) {
    final existingIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseData.courseId,
    );

    if (existingIndex != -1) {
      _availableCourses[existingIndex] = courseData.toClientData();
      _updatePendingCoursesCount();
      notifyListeners();
      print('🔄 Course ${courseData.courseId} mise à jour');
    }
  }

  // ✨ Supprimer une course (et du storage aussi)
  void removeCourse(String courseId) async {
    _availableCourses.removeWhere((course) => course.courseId == courseId);

    // ✨ Supprimer aussi du storage
    await CourseNotificationStorage.removeNotification(courseId);

    // Mettre à jour le compteur de courses en attente
    _updatePendingCoursesCount();

    // 🧹 Always clean up route-specific markers and polylines
    _polylines.clear();
    _markers.removeWhere((marker) =>
      marker.markerId.value == 'pickup_point' ||
      marker.markerId.value == 'destination_point'
    );

    if (_availableCourses.isEmpty && _currentCourse == null) {
      // No more courses and no active course - hide bottom sheet
      hideBottomSheet();
      print('🧹 No more courses, cleared route markers and polylines');
    } else if (_availableCourses.isNotEmpty) {
      // Draw route for the next available course
      await _drawRouteForNewCourse(_availableCourses.first);
    }

    notifyListeners();
  }

  void setBottomSheetType(BottomSheetAppType type) {
    print(
        '[BottomSheet] Changement d\'état: $_currentBottomSheetType -> $type');
    _currentBottomSheetType = type;
    notifyListeners();

    // Ne pas sauvegarder l'état si c'est 'none' ou si on n'a pas de course en cours
    if (type != BottomSheetAppType.none && _currentCourse != null) {
      _saveRideState(type.toString().split('.').last);
    }
  }

  void _scheduleBottomSheetChange(BottomSheetAppType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentBottomSheetType = type;
      notifyListeners();
    });
  }

  void onNewClientRequest() {
    setBottomSheetType(BottomSheetAppType.clients);
  }

  void hideBottomSheet() {
    print('[BottomSheet] Masquage de la feuille sans sauvegarder l\'état');
    _currentBottomSheetType = BottomSheetAppType.none;
    notifyListeners();
  }

  Future<void> recenterOnUserLocation() async {
    if (_currentPosition != null && _mapController != null) {
      await _moveToPosition(
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!));
    } else {
      await _getCurrentLocationOnce();
    }
  }

  void onMapTapped(LatLng point) {
    // Disabled: Prevent adding markers by tapping on the map
    // addMarker(point);
  }

  Future<void> addMarker(LatLng position) async {
    final markerId = 'marker_${_markers.length}';
    final destinationIcon = await MarkerIconService.getDestinationMarker();
    final newMarker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: destinationIcon,
      infoWindow: InfoWindow(
        title: 'Marqueur $markerId',
        snippet:
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
      ),
    );

    _markers.add(newMarker);
    notifyListeners();
  }

  Future<void> changeMapCenter(LatLng newCenter) async {
    _mapCenter = newCenter;
    if (_mapController != null) {
      await _moveToPosition(newCenter);
    }
    notifyListeners();
  }

  void changeZoom(double newZoom) {
    _mapZoom = newZoom;
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_mapCenter, newZoom),
      );
    }
    notifyListeners();
  }

  void acceptCourse(String courseId, BuildContext context) async {
    final courseIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseId,
    );

    if (courseIndex == -1) {
      print('❌ Course non trouvée: $courseId');
      return;
    }

    final course = _availableCourses[courseIndex];
    final courseNumericId = int.tryParse(courseId);
    if (courseNumericId == null) {
      print('❌ Identifiant de course invalide: $courseId');
      return;
    }

    // Verify course is still acceptable before proceeding
    final canProceed =
        await _ensureCourseIsAcceptable(courseNumericId, context);
    if (!canProceed) {
      print('🚫 Course $courseId not acceptable, aborting acceptance');
      return;
    }

    // Set current course BEFORE calling API
    _currentCourse = course;
    _isGoingToPickup = true;
    _isOnTrip = false;

    print("acceptCourse appelé: ${course.depLat}, ${course.depLong}");
    print('✅ Course acceptée: ${course.name} (ID: $courseId)');

    // Afficher la notification d'acceptation
    await LocalNotificationService.showCourseAcceptedNotification(
      courseId: courseId,
    );

    // Tracer la polyligne jusqu'au point de départ
    if (_currentPosition != null &&
        course.depLat != null &&
        course.depLong != null) {
      await _drawRouteToPickup();
    }

    // Supprimer du storage car course acceptée
    await CourseNotificationStorage.removeNotification(courseId);

    // Appeler le service
    await acceptCourseService(courseNumericId, context);

    // 🌐 Enable backend location updates AFTER successful acceptance
    // Only if _currentCourse is still set (not rejected/cancelled in the meantime)
    print('🌐 [acceptCourse] Checking location tracking for course $courseNumericId');
    print('🌐 [acceptCourse] _currentCourse: ${_currentCourse?.courseId}');
    print('🌐 [acceptCourse] isPickupCourse: ${_currentCourse?.isPickupCourse}');

    // ⚡ Skip location tracking for pickup courses (service_id = 3)
    if (_currentCourse != null && _currentCourse!.courseId == courseId) {
      debugPrint('🔍🔍🔍 [acceptCourse] LOCATION TRACKING CHECK:');
      debugPrint('🔍 [acceptCourse] courseId: $courseId');
      debugPrint('🔍 [acceptCourse] courseNumericId: $courseNumericId');
      debugPrint('🔍 [acceptCourse] _currentCourse: $_currentCourse');
      debugPrint('🔍 [acceptCourse] _currentCourse.serviceId: ${_currentCourse!.serviceId}');
      debugPrint('🔍 [acceptCourse] _currentCourse.isPickupCourse: ${_currentCourse!.isPickupCourse}');
      debugPrint('🔍🔍🔍 [acceptCourse] ================================================');

      if (_currentCourse!.isPickupCourse) {
        debugPrint('⚡⚡⚡ [acceptCourse] PICKUP COURSE DETECTED: Skipping backend location updates');
        debugPrint('⚡ [acceptCourse] Pickup courses do not send real-time location to backend');
        debugPrint('⚡ [acceptCourse] Location tracking will NOT be enabled');
      } else {
        debugPrint('🌐🌐🌐 [acceptCourse] REGULAR COURSE: Enabling backend location updates');
        debugPrint('🌐 [acceptCourse] Course ID: $courseNumericId');
        _locationService.enableBackendUpdates(
        courseId: courseNumericId,
        onLocationUpdate: (locationData) {
          debugPrint('🔔 [CALLBACK] ========== LOCATION CALLBACK TRIGGERED ==========');
          debugPrint('🔔 [CALLBACK] Course ID: $courseNumericId');
          debugPrint('🔔 [CALLBACK] Latitude: ${locationData.latitude}');
          debugPrint('🔔 [CALLBACK] Longitude: ${locationData.longitude}');
          debugPrint('🔔 [CALLBACK] Accuracy: ${locationData.accuracy}');
          debugPrint('🔔 [CALLBACK] Heading: ${locationData.heading}');
          debugPrint('🔔 [CALLBACK] Speed: ${locationData.speed}');

          if (locationData.latitude != null && locationData.longitude != null) {
            // ✅ Additional safety check: Only send if course is still current
            if (_currentCourse?.courseId != courseId.toString()) {
              debugPrint('⚠️ [CALLBACK] Course has changed or ended - skipping update');
              debugPrint('⚠️ [CALLBACK] Expected: $courseId, Current: ${_currentCourse?.courseId}');
              debugPrint('⚠️ [CALLBACK] Disabling backend updates...');
              _locationService.disableBackendUpdates();
              return;
            }

            debugPrint('✅ [CALLBACK] Calling sendLocationUpdate API...');
            debugPrint('✅ [CALLBACK] Request details:');
            debugPrint('   - Course ID: $courseNumericId');
            debugPrint('   - Latitude: ${locationData.latitude}');
            debugPrint('   - Longitude: ${locationData.longitude}');
            debugPrint('   - Heading: ${locationData.heading}');
            debugPrint('   - Speed: ${locationData.speed}');
            debugPrint('   - Accuracy: ${locationData.accuracy}');

            driverservice.sendLocationUpdate(
              courseId: courseNumericId,
              latitude: locationData.latitude!,
              longitude: locationData.longitude!,
              heading: locationData.heading,
              speed: locationData.speed,
              accuracy: locationData.accuracy,
            ).then((success) {
              if (success) {
                debugPrint('✅ [CALLBACK] API call successful for course $courseNumericId');
              } else {
                debugPrint('❌ [CALLBACK] ========== API CALL FAILED ==========');
                debugPrint('❌ [CALLBACK] Course ID: $courseNumericId');
                debugPrint('❌ [CALLBACK] REASON: Server returned non-200 status');
                debugPrint('❌ [CALLBACK] This usually means the course has ended or changed status');
                debugPrint('❌ [CALLBACK] Disabling backend updates to prevent further errors...');
                _locationService.disableBackendUpdates();
              }
            }).catchError((error) {
              debugPrint('❌ [CALLBACK] ========== API CALL EXCEPTION ==========');
              debugPrint('❌ [CALLBACK] Exception: $error');
              debugPrint('❌ [CALLBACK] Course ID: $courseNumericId');
              debugPrint('❌ [CALLBACK] Disabling backend updates...');
              _locationService.disableBackendUpdates();
            });
          } else {
            debugPrint('⚠️ [CALLBACK] CRITICAL: Location data has NULL lat/lng!');
            debugPrint('⚠️ [CALLBACK] This means GPS is not providing coordinates');
          }
        },
      );
        print('✅ [acceptCourse] Backend location updates enabled for course $courseNumericId');
      }
    } else {
      print('⚠️ [acceptCourse] Cannot enable backend updates: _currentCourse is null or changed');
    }

    // Sauvegarder l'état de la course
    if (_currentCourse != null && _currentCourse!.courseId == courseId) {
      await _saveRideState('accepted');
    }
  }

  // ✨ Méthode appelée quand le client confirme la course
  void onClientConfirmedCourse(String courseId) async {
    if (_currentCourse?.courseId == courseId) {
      // Mettre à jour l'état si nécessaire
      _isGoingToPickup = true;

      // Afficher la notification de confirmation
      await LocalNotificationService.showClientConfirmedNotification(
        courseId: courseId,
      );

      notifyListeners();
    }
  }

  // ✨ Annuler une course
  Future<void> cancelCourse(String courseId, {String? reason}) async {
    if (_currentCourse?.courseId == courseId) {
      // 🌐 Disable backend location updates
      _locationService.disableBackendUpdates();
      print('🌐 Backend location updates disabled (course cancelled)');

      // Afficher la notification d'annulation
      await LocalNotificationService.showCourseCancelledNotification(
        courseId: courseId,
        reason: reason,
      );

      // Réinitialiser l'état
      _currentCourse = null;
      _isGoingToPickup = false;
      _isOnTrip = false;
      _polylines.clear();
      _markers
          .removeWhere((marker) => marker.markerId.value != 'current_location');

      // TODO: Appeler l'API pour annuler la course

      notifyListeners();
    }
  }

  // ✨ Refuser une course (et la supprimer du storage)
  Future<void> rejectCourseById(String courseId) async {
    try {
      print('🔄 Tentative de refus de la course: $courseId');

      // 1. Supprimer du stockage d'abord
      await CourseNotificationStorage.removeNotification(courseId);
      print('✅ Notification supprimée du stockage pour la course: $courseId');

      // 2. Supprimer de la liste des courses disponibles
      final courseIndex = _availableCourses.indexWhere(
        (course) => course.courseId == courseId,
      );

      if (courseIndex != -1) {
        final course = _availableCourses[courseIndex];
        print('❌ Course refusée: ${course.name} (ID: $courseId)');

        _availableCourses.removeAt(courseIndex);
        _updatePendingCoursesCount();

        // 3. Nettoyer à nouveau pour s'assurer que tout est en ordre
        await CourseNotificationStorage.cleanExpiredNotifications(
          maxAge: const Duration(minutes: 1),
        );

        // 4. 🧹 Clean up route-specific markers and polylines
        _polylines.clear();
        _markers.removeWhere((marker) =>
          marker.markerId.value == 'pickup_point' ||
          marker.markerId.value == 'destination_point'
        );

        // 5. Cacher le bottom sheet si plus de courses ET aucune course active
        if (_availableCourses.isEmpty && _currentCourse == null) {
          hideBottomSheet();
          print('🧹 No more courses, cleared route markers and polylines');
        } else if (_availableCourses.isNotEmpty) {
          // Draw route for the next available course
          await _drawRouteForNewCourse(_availableCourses.first);
        }

        // 6. Notifier les écouteurs
        notifyListeners();
        print('✅ Refus de la course $courseId traité avec succès');
      } else {
        print(
            '⚠️ Course non trouvée dans la liste des courses disponibles: $courseId');
      }
    } catch (e) {
      print('❌ Erreur lors du refus de la course $courseId: $e');
      // En cas d'erreur, on nettoie quand même le cache
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(minutes: 1),
      );
      // On notifie quand même pour rafraîchir l'interface
      notifyListeners();
    }
  }

  // ✨ Nettoyer les notifications expirées (méthode utilitaire)
  Future<void> cleanExpiredNotifications() async {
    try {
      // Utiliser la même durée de validité que partout ailleurs (1 minute)
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(minutes: 1),
      );
      // Recharger les notifications après nettoyage
      await refreshStoredNotifications();
      print('🧹 Notifications expirées nettoyées');
    } catch (e) {
      print('❌ Erreur nettoyage notifications: $e');
    }
  }

  // Courses services functions

  Future<bool> _ensureCourseIsAcceptable(
      int courseId, BuildContext context) async {
    try {
      final details = await driverservice.getRideDetails(courseId);
      final status = _extractCourseStatus(details).toLowerCase();
      print('ℹ️ Statut actuel de la course $courseId: $status');
      if (status.isEmpty) {
        return true;
      }
      if (_allowedCourseStatuses.contains(status)) {
        return true;
      }
      print('⚠️ Course $courseId indisponible avec le statut $status');
      removeCourse(courseId.toString());
      if (context.mounted) {
        CustomToast.showWarning(context,
            message: "Cette course n'est plus disponible");
      }
      return false;
    } catch (e) {
      print('⚠️ Impossible de vérifier le statut de la course $courseId: $e');
      return true;
    }
  }

  String _extractCourseStatus(dynamic payload) {
    if (payload is Map) {
      for (final key in ['statut', 'status']) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
      for (final value in payload.values) {
        final nestedStatus = _extractCourseStatus(value);
        if (nestedStatus.isNotEmpty) {
          return nestedStatus;
        }
      }
    } else if (payload is Iterable) {
      for (final item in payload) {
        final nestedStatus = _extractCourseStatus(item);
        if (nestedStatus.isNotEmpty) {
          return nestedStatus;
        }
      }
    }
    return '';
  }

  Future<void> acceptCourseService(int courseId, BuildContext context) async {
    bool canAccept = false;
    try {
      setBusy(true);
      print("🔄 Début acceptation course $courseId...");

      await driverservice.acceptCourse(courseId);

      canAccept = true;
      print("✅ Course $courseId acceptée avec succès");
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      print('❌ Erreur acceptation course $courseId: $e');
      canAccept = false;

      // Détecter le type d'erreur
      if (errorMessage.contains('déjà prise') ||
          errorMessage.contains('introuvable') ||
          errorMessage.contains('conflict')) {
        // Course déjà prise par quelqu'un d'autre
        print('ℹ️ Course $courseId déjà prise, suppression locale');

        // Supprimer de la liste et du cache
        removeCourse(courseId.toString());

        // Message approprié
        if (context.mounted) {
          CustomToast.showWarning(context,
              message: "Cette course a été prise par un autre chauffeur");
        }
      } else if (errorMessage.contains('timeout') ||
          errorMessage.contains('network')) {
        // Problème de connexion
        if (context.mounted) {
          CustomToast.showError(context,
              message: "Problème de connexion. Vérifiez votre internet");
        }
      } else {
        // Autre erreur
        if (context.mounted) {
          CustomToast.showError(context,
              message: "Impossible d'accepter la course");
        }
      }

      // Réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      await _addUserLocationMarker();
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canAccept) {
        setBottomSheetType(BottomSheetAppType.pickup);

        // Recentrer la carte
        if (_currentCourse != null &&
            _currentCourse!.depLat != null &&
            _currentCourse!.depLong != null) {
          final pickupLatLng =
              LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(pickupLatLng, 15.0),
          );
        }
      } else {
        hideBottomSheet();
      }
    }
  }

  Future<void> rejectCourseService(int courseId, BuildContext context) async {
    bool canReject = false;
    try {
      setBusy(true);
      print("🔄 Début refus course...");
      await _arrivalStateService.clearCourseState(courseId);
      await driverservice.rejectCourse(courseId);
      canReject = true;

      // 🌐 Disable backend location updates
      _locationService.disableBackendUpdates();
      print('🌐 Backend location updates disabled (course rejected)');

      print("✅ Course refusée avec succès");
    } catch (e) {
      print('❌ Erreur refus course: $e');
      canReject = false;
      CustomToast.showError(context, message: e.toString());

      // En cas d'erreur, réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      await _addUserLocationMarker();
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canReject) {
        hideBottomSheet();
      }
    }
  }

  Future<void> startCourseService(int courseId, BuildContext context) async {
    bool canStart = false;
    try {
      setBusy(true);
      print("🔄 Début démarrage course...");

      // ⚡ Check if this is a pickup course
      final isPickup = _currentCourse?.isPickupCourse ?? false;

      if (isPickup) {
        print('⚡ [PICKUP] Starting pickup course $courseId via service');
        await driverservice.startPickupCourse(courseId);
      } else {
        print('🚗 [REGULAR] Starting regular course $courseId via service');
        await driverservice.startCourse(courseId);
      }

      await _arrivalStateService.clearCourseState(courseId);
      canStart = true;
      print("✅ Course démarrée avec succès");
    } catch (e) {
      print('❌ Erreur démarrage course: $e');
      canStart = false;
      CustomToast.showError(context, message: e.toString());

      // En cas d'erreur, revenir à l'état d'attente du client
      _isGoingToPickup = true;
      _isOnTrip = false;
      _polylines.clear();

      if (_currentCourse != null) {
        setBottomSheetType(BottomSheetAppType.pickup);
      } else {
        hideBottomSheet();
      }
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canStart) {
        setBottomSheetType(BottomSheetAppType.inprogress);
      }
    }
  }

  Future<void> completeCourseService(int courseId, BuildContext context) async {
    bool canComplete = false;
    try {
      setBusy(true);
      print("🔄 Début fin course...");

      // 🌐 Disable backend location updates BEFORE completing course
      _locationService.disableBackendUpdates();
      print('🌐 Backend location updates disabled (course completing)');

      // ⚡ Check if this is a pickup course
      final isPickup = _currentCourse?.isPickupCourse ?? false;

      if (isPickup) {
        print('⚡ [PICKUP] Completing pickup course $courseId via service');
        await driverservice.completePickupCourse(courseId);
      } else {
        print('🚗 [REGULAR] Completing regular course $courseId via service');
        await driverservice.completeCourse(courseId);
      }

      canComplete = true;
      print("✅ Course terminée avec succès");
    } catch (e) {
      print('❌ Erreur fin course: $e');
      canComplete = false;

      // Check if error is related to pause and show appropriate dialog
      final errorMessage = e.toString();
      if (errorMessage.contains('pause')) {
        _showPauseErrorDialog(context);
      } else {
        CustomToast.showError(context, message: errorMessage);
      }

      // En cas d'erreur, réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      await _addUserLocationMarker();

      // 🌐 Also disable on error to prevent continued updates
      _locationService.disableBackendUpdates();
      print('🌐 Backend location updates disabled (error during completion)');
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canComplete) {
        setBottomSheetType(BottomSheetAppType.none);
      }
    }
  }

  void _showPauseErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pause_circle_filled,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Course en pause',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vous ne pouvez pas terminer une course qui est actuellement en pause.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Veuillez d\'abord reprendre la course en cliquant sur le bouton de reprise.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('J\'ai compris'),
            ),
          ],
        );
      },
    );
  }

  // ✨ Méthode pour gérer la réception d'une notification push
  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'];
    final courseId = data['courseId'];

    switch (type) {
      case 'client_confirmed':
        onClientConfirmedCourse(courseId);
        break;
      case 'client_cancelled':
        cancelCourse(courseId, reason: 'Le client a annulé la course');
        break;
      // Ajouter d'autres cas selon les besoins
    }
  }

  String buildGoogleMapsUrlFlexible({
    double? originLat,
    double? originLng,
    String? originAddress,
    required String destAddress,
    String travelMode = "driving",
  }) {
    // Détermine l'origine : adresse ou coordonnées
    final String origin = originAddress != null
        ? Uri.encodeComponent(originAddress)
        : (originLat != null && originLng != null
            ? "$originLat,$originLng"
            : throw ArgumentError(
                "Il faut soit originAddress, soit originLat+originLng"));

    // Encode la destination
    final String encodedDestination = Uri.encodeComponent(destAddress);

    return "https://www.google.com/maps/dir/?api=1"
        "&origin=$origin"
        "&destination=$encodedDestination"
        "&travelmode=$travelMode";
  }

  Future<void> redirectPickupToGoogleMaps() async {
    try {
      // Vérifier que les données nécessaires sont disponibles
      if (_currentPosition == null) {
        throw "Position actuelle non disponible";
      }
      if (_currentPosition!.latitude == null || _currentPosition!.longitude == null) {
        throw "Coordonnées GPS non disponibles";
      }
      if (_currentCourse == null) {
        throw "Aucune course active";
      }
      if (_currentCourse!.adresseDepart == null || _currentCourse!.adresseDepart!.isEmpty) {
        throw "Adresse de départ non disponible";
      }

      final Uri uri = Uri.parse(buildGoogleMapsUrlFlexible(
        originLat: _currentPosition!.latitude!,
        originLng: _currentPosition!.longitude,
        destAddress: _currentCourse!.adresseDepart!,
      ));

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw "❌ Impossible d'ouvrir Google Maps: $e";
    }
  }

  Future<void> redirectDestinationToGoogleMaps() async {
    try {
      // Vérifier que les données nécessaires sont disponibles
      if (_currentCourse == null) {
        throw "Aucune course active";
      }
      if (_currentCourse!.adresseDepart == null || _currentCourse!.adresseDepart!.isEmpty) {
        throw "Adresse de départ non disponible";
      }
      if (_currentCourse!.destination.isEmpty) {
        throw "Destination non disponible";
      }

      final Uri uri = Uri.parse(buildGoogleMapsUrlFlexible(
        originAddress: _currentCourse!.adresseDepart,
        destAddress: _currentCourse!.destination,
      ));

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw "❌ Impossible d'ouvrir Google Maps: $e";
    }
  }

  // Tracer la route jusqu'au point de ramassage
  Future<void> _drawRouteToPickup() async {
    print(
        "drawRouteToPickup appelé 1: $_currentPosition, $_currentCourse, ${_currentCourse!.depLat}, ${_currentCourse!.depLong}");
    if (_currentPosition == null ||
        _currentCourse == null ||
        _currentCourse!.depLat == null ||
        _currentCourse!.depLong == null) {
      return;
    }

    print('drawRouteToPickup appelé 2');
    try {
      _polylines.clear();
      _markers.removeWhere((marker) =>
          marker.markerId.value == 'pickup_point' ||
          marker.markerId.value == 'destination_point');

      final pickupLatLng =
          LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!);

      // ✅ Utiliser l'API Google Directions
      PolylinePoints polylinePoints = PolylinePoints(apiKey: _googleApiKey);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
              _currentPosition!.latitude!, _currentPosition!.longitude!),
          destination:
              PointLatLng(_currentCourse!.depLat!, _currentCourse!.depLong!),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_pickup'),
            color: kcPrimaryColor,
            width: 4,
            points: routePoints,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );

        print('✅ Route vers pickup calculée: ${routePoints.length} points');
      } else {
        // Fallback vers ligne droite si l'API échoue
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_pickup'),
            color: kcPrimaryColor,
            width: 4,
            points: [
              LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
              pickupLatLng,
            ],
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
        print('⚠️ Fallback: ligne droite vers pickup');
      }

      // Ajouter marqueur pickup
      final pickupIcon = await MarkerIconService.getPickupMarker();
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickupLatLng,
          icon: pickupIcon,
          infoWindow: InfoWindow(
            title: 'Point de ramassage',
            snippet: _currentCourse!.name,
          ),
        ),
      );

      // Ajuster la caméra
      if (_mapController != null) {
        final bounds = _calculateBounds([
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
          pickupLatLng,
        ]);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      print('❌ Erreur calcul route pickup: $e');
      // Fallback vers ligne droite
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_pickup'),
          color: kcPrimaryColor,
          width: 4,
          points: [
            LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
            LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!),
          ],
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    notifyListeners();
  }

  // 4. Méthode corrigée pour tracer la route jusqu'à la destination
  Future<void> _drawRouteToDestination() async {
    if (_currentCourse == null ||
        _currentCourse!.depLat == null ||
        _currentCourse!.depLong == null ||
        _currentCourse!.destLat == null ||
        _currentCourse!.destLong == null) {
      return;
    }

    try {
      _polylines.clear();
      _markers.removeWhere((marker) =>
          marker.markerId.value == 'pickup_point' ||
          marker.markerId.value == 'destination_point');

      final pickupLatLng =
          LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!);
      final destinationLatLng =
          LatLng(_currentCourse!.destLat!, _currentCourse!.destLong!);

      // ✅ Utiliser l'API Google Directions
      PolylinePoints polylinePoints = PolylinePoints(apiKey: _googleApiKey);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin:
              PointLatLng(_currentCourse!.depLat!, _currentCourse!.depLong!),
          destination:
              PointLatLng(_currentCourse!.destLat!, _currentCourse!.destLong!),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_destination'),
            color: Colors.black,
            width: 4,
            points: routePoints,
          ),
        );

        print(
            '✅ Route vers destination calculée: ${routePoints.length} points');
      } else {
        // Fallback vers ligne droite
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_destination'),
            color: Colors.black,
            width: 4,
            points: [pickupLatLng, destinationLatLng],
          ),
        );
        print('⚠️ Fallback: ligne droite vers destination');
      }

      // Ajouter les marqueurs
      final pickupIcon = await MarkerIconService.getPickupMarker();
      final destinationIcon = await MarkerIconService.getDestinationMarker();
      _markers.addAll([
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickupLatLng,
          icon: pickupIcon,
          infoWindow: const InfoWindow(title: 'Point de ramassage'),
        ),
        Marker(
          markerId: const MarkerId('destination_point'),
          position: destinationLatLng,
          icon: destinationIcon,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      ]);

      // Ajuster la caméra
      if (_mapController != null) {
        final bounds = _calculateBounds([pickupLatLng, destinationLatLng]);
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      print('❌ Erreur calcul route destination: $e');
      // Fallback vers ligne droite
      final pickupLatLng =
          LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!);
      final destinationLatLng =
          LatLng(_currentCourse!.destLat!, _currentCourse!.destLong!);

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_destination'),
          color: Colors.black,
          width: 4,
          points: [pickupLatLng, destinationLatLng],
        ),
      );
    }

    notifyListeners();
  }

  // Calculer les limites pour afficher plusieurs points sur la carte
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (var point in points) {
      minLat =
          (minLat == null || point.latitude < minLat) ? point.latitude : minLat;
      maxLat =
          (maxLat == null || point.latitude > maxLat) ? point.latitude : maxLat;
      minLng = (minLng == null || point.longitude < minLng)
          ? point.longitude
          : minLng;
      maxLng = (maxLng == null || point.longitude > maxLng)
          ? point.longitude
          : maxLng;
    }

    // Ajouter une marge autour des points
    const padding = 0.01;
    return LatLngBounds(
      northeast: LatLng((maxLat ?? 0) + padding, (maxLng ?? 0) + padding),
      southwest: LatLng((minLat ?? 0) - padding, (minLng ?? 0) - padding),
    );
  }

  // Méthode à appeler lorsque le chauffeur démarre la course
  Future<void> startTrip() async {
    if (_currentCourse == null) return;

    _isGoingToPickup = false;
    _isOnTrip = true;

    // Sauvegarder l'état de la course
    await _saveRideState('picked_up');

    // Tracer la route jusqu'à la destination
    _drawRouteToDestination();

    notifyListeners();
  }

  // Méthode à appeler lorsque la course est terminée
  Future<void> completeTrip() async {
    if (_currentCourse == null) return;

    _isOnTrip = false;
    _isGoingToPickup = false;

    // 🌐 Disable backend location updates
    _locationService.disableBackendUpdates();
    print('🌐 Backend location updates disabled (trip completed)');

    // Sauvegarder l'état de la course
    await _saveRideState('completed');

    // Nettoyer l'état de la course
    _currentCourse = null;
    _polylines.clear();
    _markers.clear();
    await _addUserLocationMarker();

    // Nettoyer le stockage local
    await _clearRideState();

    // Cacher le bottom sheet
    hideBottomSheet();

    notifyListeners();
  }

  // ✨ Démarrer une course
  Future<void> startCourse() async {
    if (_currentCourse != null) {
      try {
        setBusy(true);

        // Mettre à jour l'état
        _isGoingToPickup = false;
        _isOnTrip = true;

        // Sauvegarder l'état de la course
        await _saveRideState('in_progress');

        final courseId = int.parse(_currentCourse!.courseId!);
        final isPickup = _currentCourse!.isPickupCourse;

        // ⚡ Appeler l'API appropriée selon le type de course
        if (isPickup) {
          print('⚡ [PICKUP] Starting pickup course $courseId');
          await driverservice.startPickupCourse(courseId);
        } else {
          print('🚗 [REGULAR] Starting regular course $courseId');
          await driverservice.startCourse(courseId);
        }

        // Afficher la notification de démarrage
        await LocalNotificationService.showCourseStartedNotification(
          courseId: _currentCourse!.courseId!,
        );

        print('🚗 Course démarrée: ${_currentCourse!.courseId}');
      } catch (e) {
        print('❌ Erreur lors du démarrage de la course: $e');
        // Revenir à l'état précédent en cas d'erreur
        _isGoingToPickup = true;
        _isOnTrip = false;
        rethrow;
      } finally {
        setBusy(false);
        notifyListeners();
      }
    }
  }

  // ✨ Terminer une course
  Future<void> completeCourse() async {
    if (_currentCourse != null) {
      try {
        setBusy(true);
        final courseId = _currentCourse!.courseId!;
        final isPickup = _currentCourse!.isPickupCourse;

        // ⚡ Appeler l'API appropriée selon le type de course
        if (isPickup) {
          print('⚡ [PICKUP] Terminating pickup course $courseId');
          await driverservice.completePickupCourse(int.parse(courseId));
        } else {
          print('🚗 [REGULAR] Terminating regular course $courseId');
          await driverservice.completeCourse(int.parse(courseId));
        }

        // Afficher la notification de fin de course
        await LocalNotificationService.showCourseFinishedNotification(
          courseId: courseId,
          amount: _currentCourse!.prix!,
        );

        // Supprimer la course du cache
        await CourseNotificationStorage.removeNotification(courseId);
        print('🗑️ Course supprimée du cache: $courseId');

        // Sauvegarder l'état de la course comme terminée
        await _saveRideState('completed');

        // Réinitialiser l'état
        await _resetCourseState();
      } catch (e) {
        print('❌ Erreur lors de la fin de la course: $e');
        rethrow;
      } finally {
        setBusy(false);
        notifyListeners();
      }
    }
  }

  // ✨ Annuler une course
  Future<void> rejectCourse({String? reason}) async {
    if (_currentCourse != null) {
      try {
        setBusy(true);
        final courseId = _currentCourse!.courseId!;

        // Appeler l'API pour annuler la course
        await driverservice.rejectCourse(
          int.parse(courseId),
        );

        // Afficher la notification d'annulation
        await LocalNotificationService.showCourseAbortedNotification(
          courseId: courseId,
        );

        // Supprimer la course du cache
        await CourseNotificationStorage.removeNotification(courseId);
        print('🗑️ Course rejetée supprimée du cache: $courseId');

        // Sauvegarder l'état de la course comme rejetée
        await _saveRideState('rejected');

        // Réinitialiser l'état
        await _resetCourseState();
      } catch (e) {
        print('❌ Erreur lors de l\'annulation de la course: $e');
        rethrow;
      } finally {
        setBusy(false);
        notifyListeners();
      }
    }
  }

  // ✨ Refuser une course (uniquement si statut = chauffeur_en_route)
  Future<Map<String, dynamic>?> denyCourse() async {
    if (_currentCourse != null) {
      try {
        setBusy(true);
        final courseId = _currentCourse!.courseId!;

        // Appeler l'API pour refuser la course
        // Cette méthode vérifie automatiquement le statut et retourne les données
        final responseData = await driverservice.denyCourse(int.parse(courseId));

        // Afficher la notification de refus
        await LocalNotificationService.showCourseAbortedNotification(
          courseId: courseId,
        );

        // Supprimer la course du cache
        await CourseNotificationStorage.removeNotification(courseId);
        print('🗑️ Course refusée supprimée du cache: $courseId');

        // Sauvegarder l'état de la course comme refusée
        await _saveRideState('denied');

        // Réinitialiser l'état
        await _resetCourseState();

        // Retourner les données de la réponse (message, pénalité, course)
        return responseData;
      } catch (e) {
        print('❌ Erreur lors du refus de la course: $e');
        rethrow;
      } finally {
        setBusy(false);
        notifyListeners();
      }
    }
    return null;
  }

  // ✨ Réinitialiser l'état de la course
  /// Called by PickupRecapView after successful completion
  Future<void> onPickupCourseCompleted(int courseId) async {
    debugPrint('⚡ [PICKUP] Cleaning up after course completion: $courseId');

    // Disable backend location updates
    _locationService.disableBackendUpdates();
    debugPrint('🌐 Backend location updates disabled (pickup course completed)');

    // Remove from cache
    await CourseNotificationStorage.removeNotification(courseId.toString());
    debugPrint('🗑️ Course supprimée du cache: $courseId');

    // Save state as completed
    await _saveRideState('completed');

    // Reset state
    await _resetCourseState();
  }

  Future<void> _resetCourseState() async {
    // Sauvegarder l'ID de la course avant de la supprimer
    final currentCourseId = _currentCourse?.courseId;

    // 🌐 CRITICAL: Disable backend location updates FIRST
    _locationService.disableBackendUpdates();
    debugPrint('🌐 [_resetCourseState] Backend location updates DISABLED');
    debugPrint('🌐 [_resetCourseState] Previous course ID: $currentCourseId');

    _currentCourse = null;
    _isGoingToPickup = false;
    _isOnTrip = false;
    _isLoadingLocation = false;
    _isLoading = false;
    _error = null;
    _isLoadingCourses = false;
    _availableCourses.clear();
    _markers.clear();
    _polylines.clear();
    _currentLocation = null;
    _currentLocationName = null;
    _destinationName = null;
    _currentBottomSheetType = BottomSheetAppType.none;
    _isLoadingLocation = false;
    _isLoading = false;
    _error = null;

    // Mettre à jour le compteur de courses en attente
    _updatePendingCoursesCount();

    // Réinitialiser l'état de la course dans le stockage
    await RidePersistenceService.clearRideState();

    // Supprimer la course du cache si elle existe
    if (currentCourseId != null) {
      await CourseNotificationStorage.removeNotification(currentCourseId);
      print(
          '🗑️ Course supprimée du cache lors de la réinitialisation: $currentCourseId');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _driversRefreshTimer?.cancel();
    _newCourseSubscription?.cancel();
    _courseUpdateSubscription?.cancel();
    _locationStreamSubscription?.cancel();
    _locationService.stopTracking();
    _trackingService.dispose(); // Stop general position tracking
    super.dispose();
  }

  // Vérifier et restaurer l'état de la course au démarrage
  Future<void> checkAndRestoreRideState() async {
    try {
      _isRestoringState = true;
      notifyListeners();
      print('🔄 Vérification de l\'état de la course...');
      final rideState = await RidePersistenceService.getRideState();
      final status = await RidePersistenceService.getRideStatus();

      if (rideState != null && status != null) {
        print(
            '🔍 Tentative de restauration de la course avec le statut: $status');

        // Créer un ClientData avec les données sauvegardées
        _currentCourse = ClientData(
          name: rideState['name']?.toString() ?? 'Client inconnu',
          timeInfo: rideState['timeInfo']?.toString() ?? 'Maintenant',
          destination:
              rideState['destination']?.toString() ?? 'Destination inconnue',
          initials: rideState['initials']?.toString() ?? 'CI',
          courseId: rideState['courseId']?.toString(),
          prix: rideState['prix'] is double
              ? rideState['prix']
              : (rideState['prix'] is int
                  ? (rideState['prix'] as int).toDouble()
                  : null),
          distance: rideState['distance'] is double
              ? rideState['distance']
              : (rideState['distance'] is int
                  ? (rideState['distance'] as int).toDouble()
                  : null),
          duree: rideState['duree'] is double
              ? rideState['duree']
              : (rideState['duree'] is int
                  ? (rideState['duree'] as int).toDouble()
                  : null),
          adresseDepart: rideState['adresseDepart']?.toString(),
          isNight: rideState['isNight'] as bool?,
          etaMinutes: rideState['etaMinutes'] is int
              ? rideState['etaMinutes']
              : (rideState['etaMinutes'] is double
                  ? (rideState['etaMinutes'] as double).toInt()
                  : null),
          destLong: rideState['destLong'] is double
              ? rideState['destLong']
              : (rideState['destLong'] is int
                  ? (rideState['destLong'] as int).toDouble()
                  : null),
          destLat: rideState['destLat'] is double
              ? rideState['destLat']
              : (rideState['destLat'] is int
                  ? (rideState['destLat'] as int).toDouble()
                  : null),
          depLong: rideState['depLong'] is double
              ? rideState['depLong']
              : (rideState['depLong'] is int
                  ? (rideState['depLong'] as int).toDouble()
                  : null),
          depLat: rideState['depLat'] is double
              ? rideState['depLat']
              : (rideState['depLat'] is int
                  ? (rideState['depLat'] as int).toDouble()
                  : null),
        );

        // Mettre à jour l'état en fonction du statut
        _updateRideStateFromStatus(status);

        // Si la course est en cours ou acceptée, on la retire de availableCourses
        if (status == 'in_progress' ||
            status == 'picked_up' ||
            status == 'accepted') {
          _availableCourses.removeWhere(
              (course) => course.courseId == _currentCourse?.courseId);
          _updatePendingCoursesCount();
          print(
              '✅ Course retirée de availableCourses car son statut est: $status');
        } else if (!_availableCourses
            .any((course) => course.courseId == _currentCourse?.courseId)) {
          // Sinon, on l'ajoute si elle n'existe pas déjà
          _availableCourses.add(_currentCourse!);
          _updatePendingCoursesCount();
          print('✅ Course ajoutée à availableCourses avec statut: $status');
        }

        // Rafraîchir l'interface
        notifyListeners();

        // Ajouter un délai pour s'assurer que l'UI est prête
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        print('ℹ️ Aucun état de course à restaurer ou statut manquant');
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification de l\'état de la course: $e');
    } finally {
      _isRestoringState = false;
      notifyListeners();
    }
  }

  // Méthode utilitaire pour mettre à jour l'état en fonction du statut
  void _updateRideStateFromStatus(String status) {
    // Normaliser le statut
    status = status.toLowerCase().trim();

    print('🔄 Mise à jour de l\'état avec le statut: $status');

    switch (status) {
      case 'pickup':
      case 'accepted':
        _isGoingToPickup = true;
        _isOnTrip = false;
        _currentBottomSheetType = BottomSheetAppType.pickup;
        break;

      case 'picked_up':
      case 'inprogress': // Gestion des deux formats possibles
      case 'in_progress':
        _isGoingToPickup = false;
        _isOnTrip = true;
        _currentBottomSheetType = BottomSheetAppType.inprogress;
        break;

      case 'completed':
      case 'rejected':
      case 'cancelled':
        _isGoingToPickup = false;
        _isOnTrip = false;
        _currentBottomSheetType = BottomSheetAppType.none;
        break;

      default:
        print('⚠️ Statut inconnu lors de la restauration: $status');
        _currentBottomSheetType = BottomSheetAppType.none;
    }

    print('🔍 État mis à jour - '
        'isGoingToPickup: $_isGoingToPickup, '
        'isOnTrip: $_isOnTrip, '
        'bottomSheetType: $_currentBottomSheetType');
  }

  // Méthode pour sauvegarder l'état de la course
  Future<void> _saveRideState(String status) async {
    if (_currentCourse == null) return;

    // Créer un Map avec toutes les propriétés de la course
    final rideData = {
      'courseId': _currentCourse!.courseId,
      'name': _currentCourse!.name,
      'timeInfo': _currentCourse!.timeInfo,
      'destination': _currentCourse!.destination,
      'initials': _currentCourse!.initials,
      'prix': _currentCourse!.prix,
      'distance': _currentCourse!.distance,
      'duree': _currentCourse!.duree,
      'adresseDepart': _currentCourse!.adresseDepart,
      'isNight': _currentCourse!.isNight,
      'etaMinutes': _currentCourse!.etaMinutes,
      'destLong': _currentCourse!.destLong,
      'destLat': _currentCourse!.destLat,
      'depLong': _currentCourse!.depLong,
      'depLat': _currentCourse!.depLat,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('💾 Sauvegarde de l\'état de la course: $rideData');
    await RidePersistenceService.saveRideState(rideData, status);
  }

  // Méthode pour effacer l'état de la course
  Future<void> _clearRideState() async {
    await RidePersistenceService.clearRideState();
  }

  // Récupérer les conducteurs en ligne
  Future<void> fetchOnlineDrivers() async {
    try {
      final newDrivers = await _driverService.getOnlineDrivers();

      if (_onlineDrivers.length != newDrivers.length) {
        _onlineDrivers = newDrivers;
        _updateDriverMarkers();
        notifyListeners();
        return;
      }

      bool hasChanges = false;
      for (int i = 0; i < _onlineDrivers.length; i++) {
        if (i >= newDrivers.length ||
            _onlineDrivers[i].id != newDrivers[i].id ||
            _onlineDrivers[i].latitude != newDrivers[i].latitude ||
            _onlineDrivers[i].longitude != newDrivers[i].longitude) {
          hasChanges = true;
          break;
        }
      }

      if (hasChanges) {
        _onlineDrivers = newDrivers;
        _updateDriverMarkers();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des conducteurs en ligne: $e');
    }
  }

  // Mettre à jour les marqueurs des conducteurs
  void _updateDriverMarkers() async {
    _markers
        .removeWhere((marker) => marker.markerId.value.startsWith('driver_'));

    final driverIcon = await MarkerIconService.getDriverMarker(vehicleType: _vehicleType);
    for (var driver in _onlineDrivers) {
      final markerId = 'driver_${driver.id}';
      final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(driver.latitude, driver.longitude),
        icon: driverIcon,
        infoWindow: InfoWindow(
          title: 'Conducteur #${driver.id}',
          snippet: 'Disponible',
        ),
      );
      _markers.add(marker);
    }
  }

  // Démarrer le rafraîchissement périodique des conducteurs
  void startDriversRefresh() {
    // Récupérer immédiatement
    fetchOnlineDrivers();

    // Puis toutes les 30 secondes
    _driversRefreshTimer?.cancel();
    _driversRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchOnlineDrivers();
    });
  }

  // Arrêter le rafraîchissement
  void stopDriversRefresh() {
    _driversRefreshTimer?.cancel();
  }

  // Méthode pour initialiser la position actuelle
  Future<void> initializeLocation() async {
    await RidePersistenceService.clearRideState();
  }

  /// Start continuous general position tracking if driver is online
  Future<void> _startGeneralPositionTracking() async {
    try {
      final isOnline = await _sharedPreferencesService.getOnlineStatus() ?? false;
      debugPrint('🎯 [CoursesView] Checking driver online status: $isOnline');

      if (isOnline) {
        debugPrint('🎯 [CoursesView] Driver is ONLINE - starting continuous position tracking');
        await _trackingService.startContinuousTracking(
          interval: const Duration(seconds: 30), // Send position every 30 seconds
        );
        debugPrint('✅ [CoursesView] General position tracking started');
      } else {
        debugPrint('ℹ️ [CoursesView] Driver is OFFLINE - position tracking not started');
      }
    } catch (e) {
      debugPrint('❌ [CoursesView] Error starting general position tracking: $e');
    }
  }

  /// Stop continuous general position tracking
  Future<void> _stopGeneralPositionTracking() async {
    try {
      debugPrint('🛑 [CoursesView] Stopping general position tracking...');
      await _trackingService.stopContinuousTracking();
      debugPrint('✅ [CoursesView] General position tracking stopped');
    } catch (e) {
      debugPrint('❌ [CoursesView] Error stopping general position tracking: $e');
    }
  }

  /// Called when driver's online status changes (from home view)
  Future<void> onDriverOnlineStatusChanged(bool isOnline) async {
    debugPrint('🔄 [CoursesView] Driver online status changed: $isOnline');

    if (isOnline) {
      await _startGeneralPositionTracking();
    } else {
      await _stopGeneralPositionTracking();
    }
  }

  /// Restore active course state when app resumes
  /// Called from main app lifecycle manager
  Future<void> restoreActiveCourse(Map<String, dynamic> courseDetails) async {
    try {
      debugPrint('🔄 [Restoration] Starting course restoration...');
      debugPrint('🔄 [Restoration] Full course details: $courseDetails');
      _isRestoringState = true;
      notifyListeners();

      // Parse course details from API response
      final courseId = (courseDetails['course_id'] ?? courseDetails['id'])?.toString();
      final status = courseDetails['statut'] as String?;

      debugPrint('🔄 [Restoration] Parsed - courseId: $courseId, status: $status');

      if (courseId == null || status == null) {
        debugPrint('❌ [Restoration] Invalid course data - missing courseId or status');
        _isRestoringState = false;
        notifyListeners();
        return;
      }

      // Parse client data
      final clientData = courseDetails['client'] as Map<String, dynamic>?;
      final clientName = clientData != null
          ? '${clientData['prenom'] ?? ''} ${clientData['nom'] ?? ''}'.trim()
          : 'Client';

      // Parse coordinates (handle both String and double types)
      final pointDepart = courseDetails['point_depart'] as Map<String, dynamic>?;
      final pointArrivee = courseDetails['point_arrivee'] as Map<String, dynamic>?;

      double? depLat;
      double? depLong;
      double? arrLat;
      double? arrLong;

      if (pointDepart != null) {
        depLat = pointDepart['lat'] is String
            ? double.tryParse(pointDepart['lat'])
            : (pointDepart['lat'] as num?)?.toDouble();
        depLong = pointDepart['lng'] is String
            ? double.tryParse(pointDepart['lng'])
            : (pointDepart['lng'] as num?)?.toDouble();
      }

      if (pointArrivee != null) {
        arrLat = pointArrivee['lat'] is String
            ? double.tryParse(pointArrivee['lat'])
            : (pointArrivee['lat'] as num?)?.toDouble();
        arrLong = pointArrivee['lng'] is String
            ? double.tryParse(pointArrivee['lng'])
            : (pointArrivee['lng'] as num?)?.toDouble();
      }

      // Extract service_id to identify pickup courses
      // Check both 'service_id' and 'is_pickup_course' fields
      final apiServiceId = courseDetails['service_id'] as int?;
      final isPickupFlag = courseDetails['is_pickup_course'] as bool?;

      // ⚡ CRITICAL: If is_pickup_course is true but service_id is null, set it to 3
      final serviceId = apiServiceId ?? (isPickupFlag == true ? 3 : null);
      final isPickup = (serviceId == 3) || (isPickupFlag == true);

      debugPrint('🔍🔍🔍 [Restoration] PICKUP DETECTION:');
      debugPrint('🔍 [Restoration] API service_id: $apiServiceId');
      debugPrint('🔍 [Restoration] API is_pickup_course: $isPickupFlag');
      debugPrint('🔍 [Restoration] Computed serviceId: $serviceId');
      debugPrint('🔍 [Restoration] isPickup: $isPickup');
      debugPrint('🔍🔍🔍 [Restoration] ================================================');

      // Create ClientData object
      final restoredCourse = ClientData(
        courseId: courseId,
        name: isPickup ? 'Course Pickup' : clientName,
        timeInfo: 'En cours',
        destination: pointArrivee?['adresse'] ?? 'Arrivée',
        initials: isPickup ? 'P' : (clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C'),
        adresseDepart: pointDepart?['adresse'] ?? 'Départ',
        depLat: depLat,
        depLong: depLong,
        destLat: arrLat,
        destLong: arrLong,
        distance: (courseDetails['distance_km'] as num?)?.toDouble(),
        prix: (courseDetails['montant'] as num?)?.toDouble(),
        serviceId: serviceId,  // ⚡ Now properly set to 3 for pickup courses
      );

      _currentCourse = restoredCourse;
      debugPrint('✅ [Restoration] Course object created: ${_currentCourse?.courseId}');
      debugPrint('🔍🔍🔍 [Restoration] DETAILED COURSE INFO:');
      debugPrint('🔍 [Restoration] _currentCourse.courseId: ${_currentCourse?.courseId}');
      debugPrint('🔍 [Restoration] _currentCourse.serviceId: ${_currentCourse?.serviceId}');
      debugPrint('🔍 [Restoration] _currentCourse.isPickupCourse: ${_currentCourse?.isPickupCourse}');
      debugPrint('🔍 [Restoration] serviceId variable: $serviceId');
      debugPrint('🔍 [Restoration] isPickupFlag variable: $isPickupFlag');
      debugPrint('🔍 [Restoration] isPickup variable: $isPickup');
      debugPrint('🔍🔍🔍 [Restoration] ================================================');

      // Set state based on course status
      // 🚀 For pickup courses, skip chauffeur_en_route and chauffeur_arrive
      debugPrint('🔄 [Restoration] Processing status: $status');
      switch (status) {
        case 'chauffeur_en_route':
        case 'en_route_vers_client':
          // ⚡ Skip for pickup courses - go directly to en_cours
          if (isPickup) {
            debugPrint('⚡ [Restoration] PICKUP: Skipping en_route state, treating as en_cours');
            _isGoingToPickup = false;
            _isOnTrip = true;
            setBottomSheetType(BottomSheetAppType.inprogress);

            // Draw route to destination
            if (_currentPosition != null && arrLat != null && arrLong != null) {
              debugPrint('🗺️ [Restoration] PICKUP: Drawing route to destination');
              await _drawRouteToDestination();
            }
          } else {
            debugPrint('🚗 [Restoration] Driver en route to pickup');
            _isGoingToPickup = true;
            _isOnTrip = false;
            setBottomSheetType(BottomSheetAppType.pickup);

            // Draw route to pickup
            if (_currentPosition != null && depLat != null && depLong != null) {
              debugPrint('🗺️ [Restoration] Drawing route to pickup');
              await _drawRouteToPickup();
            } else {
              debugPrint('⚠️ [Restoration] Cannot draw route - missing position or coordinates');
            }
          }
          break;

        case 'arrive_au_point_depart':
        case 'chauffeur_arrive':
          // ⚡ Skip for pickup courses - go directly to en_cours
          if (isPickup) {
            debugPrint('⚡ [Restoration] PICKUP: Skipping arrive state, treating as en_cours');
            _isGoingToPickup = false;
            _isOnTrip = true;
            setBottomSheetType(BottomSheetAppType.inprogress);

            // Draw route to destination
            if (_currentPosition != null && arrLat != null && arrLong != null) {
              debugPrint('🗺️ [Restoration] PICKUP: Drawing route to destination');
              await _drawRouteToDestination();
            }
          } else {
            debugPrint('📍 [Restoration] Driver arrived at pickup');
            _isGoingToPickup = true;
            _isOnTrip = false;
            setBottomSheetType(BottomSheetAppType.pickup);
          }
          break;

        case 'en_cours':
          debugPrint('🏁 [Restoration] Trip in progress');
          _isGoingToPickup = false;
          _isOnTrip = true;
          setBottomSheetType(BottomSheetAppType.inprogress);

          // Draw route to destination
          if (_currentPosition != null && arrLat != null && arrLong != null) {
            debugPrint('🗺️ [Restoration] Drawing route to destination');
            await _drawRouteToDestination();
          } else {
            debugPrint('⚠️ [Restoration] Cannot draw route - missing position or coordinates');
          }
          break;

        case 'en_pause':
          debugPrint('⏸️ [Restoration] Trip paused');
          _isGoingToPickup = false;
          _isOnTrip = true;
          setBottomSheetType(BottomSheetAppType.inprogress);
          break;

        case 'en_attente_paiement':
          debugPrint('💰 [Restoration] Waiting for payment');
          _isGoingToPickup = false;
          _isOnTrip = false;
          setBottomSheetType(BottomSheetAppType.inprogress);
          break;

        default:
          debugPrint('⚠️ [Restoration] Unknown status: $status');
      }

      // 🌐 Re-enable backend location updates for restored ride
      // ⚡ Skip for pickup courses (service_id = 3)
      if (_currentCourse != null) {
        final courseNumericId = int.tryParse(courseId);
        if (courseNumericId != null) {
          debugPrint('🔍🔍🔍 [Restoration] LOCATION TRACKING CHECK:');
          debugPrint('🔍 [Restoration] courseId: $courseId');
          debugPrint('🔍 [Restoration] courseNumericId: $courseNumericId');
          debugPrint('🔍 [Restoration] _currentCourse: $_currentCourse');
          debugPrint('🔍 [Restoration] _currentCourse.serviceId: ${_currentCourse!.serviceId}');
          debugPrint('🔍 [Restoration] _currentCourse.isPickupCourse: ${_currentCourse!.isPickupCourse}');
          debugPrint('🔍🔍🔍 [Restoration] ================================================');

          if (_currentCourse!.isPickupCourse) {
            debugPrint('⚡⚡⚡ [Restoration] PICKUP COURSE DETECTED: Skipping backend location updates');
            debugPrint('⚡ [Restoration] Pickup courses do not send real-time location to backend');
            debugPrint('⚡ [Restoration] Location tracking will NOT be enabled');
          } else {
            debugPrint('🌐🌐🌐 [Restoration] REGULAR COURSE: Enabling backend location updates');
            debugPrint('🌐 [Restoration] Course ID: $courseNumericId');
            _locationService.enableBackendUpdates(
            courseId: courseNumericId,
            onLocationUpdate: (locationData) {
              debugPrint('🔔 [RESTORATION CALLBACK] ========== LOCATION CALLBACK TRIGGERED ==========');
              debugPrint('🔔 [RESTORATION CALLBACK] Course ID: $courseNumericId');
              debugPrint('🔔 [RESTORATION CALLBACK] Latitude: ${locationData.latitude}');
              debugPrint('🔔 [RESTORATION CALLBACK] Longitude: ${locationData.longitude}');
              debugPrint('🔔 [RESTORATION CALLBACK] Accuracy: ${locationData.accuracy}');
              debugPrint('🔔 [RESTORATION CALLBACK] Heading: ${locationData.heading}');
              debugPrint('🔔 [RESTORATION CALLBACK] Speed: ${locationData.speed}');

              if (locationData.latitude != null && locationData.longitude != null) {
                // ✅ Additional safety check: Only send if course is still current
                if (_currentCourse?.courseId != courseId) {
                  debugPrint('⚠️ [RESTORATION CALLBACK] Course has changed or ended - skipping update');
                  debugPrint('⚠️ [RESTORATION CALLBACK] Expected: $courseId, Current: ${_currentCourse?.courseId}');
                  debugPrint('⚠️ [RESTORATION CALLBACK] Disabling backend updates...');
                  _locationService.disableBackendUpdates();
                  return;
                }

                debugPrint('✅ [RESTORATION CALLBACK] Calling sendLocationUpdate API...');
                driverservice.sendLocationUpdate(
                  courseId: courseNumericId,
                  latitude: locationData.latitude!,
                  longitude: locationData.longitude!,
                  heading: locationData.heading,
                  speed: locationData.speed,
                  accuracy: locationData.accuracy,
                ).then((success) {
                  if (success) {
                    debugPrint('✅ [RESTORATION CALLBACK] API call successful');
                  } else {
                    debugPrint('❌ [RESTORATION CALLBACK] API call FAILED');
                    debugPrint('❌ [RESTORATION CALLBACK] Course likely ended/changed - disabling updates');
                    _locationService.disableBackendUpdates();
                  }
                }).catchError((error) {
                  debugPrint('❌ [RESTORATION CALLBACK] API call threw exception: $error');
                  debugPrint('❌ [RESTORATION CALLBACK] Disabling backend updates...');
                  _locationService.disableBackendUpdates();
                });
              } else {
                debugPrint('⚠️ [RESTORATION CALLBACK] CRITICAL: Location data has NULL lat/lng!');
                debugPrint('⚠️ [RESTORATION CALLBACK] This means GPS is not providing coordinates');
              }
            },
          );
            debugPrint('✅ [Restoration] Backend location updates enabled for course $courseNumericId');
          }
        } else {
          debugPrint('⚠️ [Restoration] Cannot enable location updates - invalid courseId: $courseId');
        }
      } else {
        debugPrint('⚠️ [Restoration] Cannot enable location updates - _currentCourse is null');
      }

      debugPrint('✅ [Restoration] Active course restored: $courseId ($status)');
      debugPrint('✅ [Restoration] Bottom sheet type: $_currentBottomSheetType');
      debugPrint('✅ [Restoration] isGoingToPickup: $_isGoingToPickup, isOnTrip: $_isOnTrip');
      _isRestoringState = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Restoration] Error restoring active course: $e');
      debugPrint('❌ [Restoration] Stack trace: ${StackTrace.current}');
      _isRestoringState = false;
      notifyListeners();
    }
  }

  /// Fetch vehicle type directly from API dashboard endpoint
  Future<void> _fetchVehicleTypeFromAPI() async {
    try {
      debugPrint('🌐 [Vehicle] Fetching vehicle type from API...');
      final token = await _sharedPreferencesService.getToken();
      if (token == null) {
        debugPrint('❌ [Vehicle] No auth token available');
        return;
      }

      final url = Uri.parse('${ApiConstant.baseUrl}/conducteur/dashboard');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['vehicule'] != null && data['vehicule']['type'] != null) {
          final vehicleType = data['vehicule']['type'].toString();
          _vehicleType = vehicleType;

          // Save to SharedPreferences for future use
          await _sharedPreferencesService.saveActiveVehicleType(vehicleType);

          debugPrint('✅ [Vehicle] Fetched and saved vehicle type from API: $vehicleType');

          // Update marker if we have a position
          if (_currentPosition != null) {
            await _addUserLocationMarker();
            notifyListeners();
          }
        } else {
          debugPrint('⚠️ [Vehicle] No vehicle type in API response');
        }
      } else {
        debugPrint('❌ [Vehicle] API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [Vehicle] Error fetching vehicle type from API: $e');
    }
  }

  /// Reload vehicle type from SharedPreferences and update markers
  /// Call this method when vehicle data is updated
  Future<void> reloadVehicleType() async {
    final oldVehicleType = _vehicleType;
    _vehicleType = await _sharedPreferencesService.getActiveVehicleType();
    debugPrint('🚗 [Vehicle] Reloaded vehicle type: $_vehicleType (was: $oldVehicleType)');

    // If vehicle type changed, update the driver marker
    if (oldVehicleType != _vehicleType && _currentPosition != null) {
      debugPrint('🔄 [Vehicle] Vehicle type changed, updating marker...');
      await _addUserLocationMarker();
      notifyListeners();
    }
  }
}
