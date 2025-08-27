import 'dart:async';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/course_event_service.dart';
import 'package:for_u_partners/services/course_notificationstorage_service.dart';
import 'package:for_u_partners/services/driver_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:io' show Platform;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:for_u_partners/services/local_notif_service.dart';
import 'package:for_u_partners/services/ride/ride_persistence_service.dart';
import 'package:for_u_partners/ui/views/drivers/homemain/homemain_viewmodel.dart';

class CoursesViewModel extends BaseViewModel {
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  LatLng _mapCenter = const LatLng(48.8566, 2.3522);
  LatLng get mapCenter => _mapCenter;

  double _mapZoom = 15.0;
  double get mapZoom => _mapZoom;

  final Set<Marker> _markers = <Marker>{};
  Set<Marker> get markers => _markers;

  // Polylines pour les trajets
  final Set<Polyline> _polylines = <Polyline>{};
  Set<Polyline> get polylines => _polylines;

  // Course actuellement sélectionnée
  ClientData? _currentCourse;
  ClientData? get currentCourse => _currentCourse;
  set currentCourse(ClientData? course) => _currentCourse = course;

  // Current user location
  LatLng? _currentLocation;

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

  // Définir la référence au ViewModel principal
  Future<void> onModelReady() async {
    await checkAndRestoreRideState();
    print("currentBottomSheetType: $_currentBottomSheetType");
  }

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

  Position? _currentPosition;
  Position? get currentPosiction => _currentPosition;

  BottomSheetAppType _currentBottomSheetType = BottomSheetAppType.none;
  BottomSheetAppType get currentBottomSheetType => _currentBottomSheetType;

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  final driverservice = locator<DriverService>();
  final navigationService = locator<NavigationService>();

  static const String _googleApiKey = 'AIzaSyAVtrvygnbsdnL6VMEJS_DB0JfEa0piHqM';

  String? _error;

  CoursesViewModel() {
    _initializeViewModel();
  }

  // ✨ Initialisation complète du ViewModel
  Future<void> _initializeViewModel() async {
    // Lancer les tâches en parallèle
    await Future.wait([
      _getCurrentLocation(),
      _loadStoredNotifications(), // ✨ Charger les notifications stockées
    ]);

    _setupCourseListeners();

    // Afficher le bottom sheet s'il y a des courses
    print(
        '🔍 État après _loadStoredNotifications - availableCourses: ${_availableCourses.length}');
    print(
        '🔍 Contenu de availableCourses: ${_availableCourses.map((c) => '${c.courseId}: ${c.name}').toList()}');

    if (_availableCourses.isNotEmpty) {
      setBottomSheetType(BottomSheetAppType.clients);
    }
    print("currentBottomSheetType: $_currentBottomSheetType");
  }

  // ✨ Charger les notifications stockées au démarrage
  Future<void> _loadStoredNotifications() async {
    try {
      _isLoadingCourses = true;
      notifyListeners();

      print('📱 Chargement des notifications stockées...');

      // Nettoyer d'abord les notifications expirées
      await CourseNotificationStorage.cleanExpiredNotifications(
        maxAge: const Duration(minutes: 1), // Réduit à 1 minute
      );

      // Récupérer uniquement les notifications valides des dernières minutes
      final storedNotifications =
          await CourseNotificationStorage.getValidNotifications(
        maxAge: const Duration(minutes: 1), // Réduit à 1 minute
      );

      print(
          '📱 ${storedNotifications.length} notifications trouvées en storage');

      // Convertir les notifications en ClientData
      for (final notification in storedNotifications) {
        final clientData = notification.toClientData();

        // Vérifier si pas déjà dans la liste (éviter doublons)
        final existingIndex = _availableCourses.indexWhere(
          (course) => course.courseId == notification.courseId,
        );

        if (existingIndex == -1) {
          _availableCourses.add(clientData);
          print('✅ Course chargée depuis storage: ${clientData.name}');
          _updatePendingCoursesCount();
        }
      }

      // Trier par timestamp (plus récent en premier) - si tu as besoin
      _availableCourses.sort((a, b) {
        // Supposant que tu ajoutes un timestamp à ClientData aussi
        // Sinon, tu peux trier par courseId ou autre critère
        return b.courseId!.compareTo(a.courseId!);
      });

      // Mettre à jour le compteur de courses en attente
      _updatePendingCoursesCount();

      _isLoadingCourses = false;
      notifyListeners();

      print('✅ ${_availableCourses.length} courses chargées au total');
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
    } else if (_availableCourses.isEmpty) {
      hideBottomSheet();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _moveToPosition(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _mapCenter =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      if (_mapController != null) {
        _moveToPosition(_mapCenter);
      }

      _addUserLocationMarker();

      _isLoadingLocation = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void _moveToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, _mapZoom),
    );
  }

  void _addUserLocationMarker() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

    if (_availableCourses.isEmpty) {
      hideBottomSheet();
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
      _moveToPosition(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    } else {
      await _getCurrentLocation();
    }
  }

  void onMapTapped(LatLng point) {
    addMarker(point);
  }

  void addMarker(LatLng position) {
    final markerId = 'marker_${_markers.length}';
    final newMarker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Marqueur $markerId',
        snippet:
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
      ),
    );

    _markers.add(newMarker);
    notifyListeners();
  }

  void changeMapCenter(LatLng newCenter) {
    _mapCenter = newCenter;
    if (_mapController != null) {
      _moveToPosition(newCenter);
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

  // ✨ Accepter une course (et la supprimer du storage)
  void acceptCourse(String courseId, BuildContext context) async {
    final courseIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseId,
    );

    if (courseIndex != -1) {
      final course = _availableCourses[courseIndex];
      _currentCourse = course;
      _isGoingToPickup = true;
      _isOnTrip = false;

      print("acceptCourse appelé: ${course.depLat}, ${course.depLong}");
      print('✅ Course acceptée: ${course.name} (ID: $courseId)');

      // Afficher la notification d'acceptation
      await LocalNotificationService.showCourseAcceptedNotification(
        courseId: courseId,
      );

      // Afficher la notification d'attente de confirmation
      await LocalNotificationService.showWaitingForClientConfirmation(
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
      await acceptCourseService(int.parse(courseId), context);

      // Sauvegarder l'état de la course
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

        // 4. Cacher le bottom sheet si plus de courses
        if (_availableCourses.isEmpty) {
          hideBottomSheet();
        }

        // 5. Notifier les écouteurs
        notifyListeners();
        print('✅ Refus de la course $courseId traité avec succès');
      } else {
        print('⚠️ Course non trouvée dans la liste des courses disponibles: $courseId');
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

  Future<void> acceptCourseService(int courseId, BuildContext context) async {
    bool canAccept = false;
    try {
      setBusy(true);
      print("🔄 Début acceptation course...");
      await driverservice.acceptCourse(courseId);
      canAccept = true;
      print("✅ Course acceptée avec succès");
    } catch (e) {
      print('❌ Erreur acceptation course: $e');
      canAccept = false;
      CustomToast.showError(context, message: e.toString());

      // En cas d'erreur, réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      _addUserLocationMarker();
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canAccept) {
        setBottomSheetType(BottomSheetAppType.pickup);

        // Recentrer la carte sur le point de ramassage si possible
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
      await driverservice.rejectCourse(courseId);
      canReject = true;
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
      _addUserLocationMarker();
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
      await driverservice.startCourse(courseId);
      canStart = true;
      print("✅ Course démarrée avec succès");
    } catch (e) {
      print('❌ Erreur démarrage course: $e');
      canStart = false;
      CustomToast.showError(context, message: e.toString());

      // En cas d'erreur, réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      _addUserLocationMarker();
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
      await driverservice.completeCourse(courseId);
      canComplete = true;
      print("✅ Course terminée avec succès");
    } catch (e) {
      print('❌ Erreur fin course: $e');
      canComplete = false;
      CustomToast.showError(context, message: e.toString());

      // En cas d'erreur, réinitialiser l'état
      _isGoingToPickup = false;
      _currentCourse = null;
      _polylines.clear();
      _markers.clear();
      _addUserLocationMarker();
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      if (canComplete) {
        setBottomSheetType(BottomSheetAppType.none);
      }
    }
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
              _currentPosition!.latitude, _currentPosition!.longitude),
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
            color: Colors.blue,
            width: 5,
            points: routePoints, // ✅ Vrais points de route
          ),
        );

        print('✅ Route vers pickup calculée: ${routePoints.length} points');
      } else {
        // Fallback vers ligne droite si l'API échoue
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_pickup'),
            color: Colors.blue,
            width: 5,
            points: [
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              pickupLatLng,
            ],
          ),
        );
        print('⚠️ Fallback: ligne droite vers pickup');
      }

      // Ajouter marqueur pickup
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickupLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Point de ramassage',
            snippet: _currentCourse!.name,
          ),
        ),
      );

      // Ajuster la caméra
      if (_mapController != null) {
        final bounds = _calculateBounds([
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
          color: Colors.blue,
          width: 5,
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(_currentCourse!.depLat!, _currentCourse!.depLong!),
          ],
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
            color: Colors.green,
            width: 5,
            points: routePoints, // ✅ Vrais points de route
          ),
        );

        print(
            '✅ Route vers destination calculée: ${routePoints.length} points');
      } else {
        // Fallback vers ligne droite
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route_to_destination'),
            color: Colors.green,
            width: 5,
            points: [pickupLatLng, destinationLatLng],
          ),
        );
        print('⚠️ Fallback: ligne droite vers destination');
      }

      // Ajouter les marqueurs
      _markers.addAll([
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickupLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Point de ramassage'),
        ),
        Marker(
          markerId: const MarkerId('destination_point'),
          position: destinationLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
          color: Colors.green,
          width: 5,
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

    // Sauvegarder l'état de la course
    await _saveRideState('completed');

    // Nettoyer l'état de la course
    _currentCourse = null;
    _polylines.clear();
    _markers.clear();
    _addUserLocationMarker();

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

        // Appeler l'API pour démarrer la course
        await driverservice.startCourse(int.parse(_currentCourse!.courseId!));

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

        // Appeler l'API pour terminer la course
        final result = await driverservice
            .completeCourse(int.parse(_currentCourse!.courseId!));

        // Afficher la notification de fin de course
        await LocalNotificationService.showCourseFinishedNotification(
          courseId: _currentCourse!.courseId!,
          amount: _currentCourse!.prix!,
        );

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

        // Appeler l'API pour annuler la course
        await driverservice.rejectCourse(
          int.parse(_currentCourse!.courseId!),
        );

        // Afficher la notification d'annulation
        await LocalNotificationService.showCourseAbortedNotification(
          courseId: _currentCourse!.courseId!,
        );

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

  // ✨ Réinitialiser l'état de la course
  Future<void> _resetCourseState() async {
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
  }

  @override
  void dispose() {
    _newCourseSubscription?.cancel();
    _courseUpdateSubscription?.cancel();
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
}
