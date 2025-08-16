import 'dart:async';
import 'package:flutter/scheduler.dart';
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

class CoursesViewModel extends BaseViewModel {
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  LatLng _mapCenter = const LatLng(48.8566, 2.3522);
  LatLng get mapCenter => _mapCenter;

  double _mapZoom = 15.0;
  double get mapZoom => _mapZoom;

  final Set<Marker> _markers = <Marker>{};
  Set<Marker> get markers => _markers;

  final CourseEventService _courseEventService = CourseEventService();
  StreamSubscription<CourseNotificationData>? _newCourseSubscription;
  StreamSubscription<CourseNotificationData>? _courseUpdateSubscription;

  // Liste des courses disponibles
  final List<ClientData> _availableCourses = [];
  List<ClientData> get availableCourses => List.unmodifiable(_availableCourses);

  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  // ✨ État de chargement des notifications
  bool _isLoadingCourses = true;
  bool get isLoadingCourses => _isLoadingCourses;

  Position? _currentPosition;
  Position? get currentPosiction => _currentPosition;

  BottomSheetAppType _currentBottomSheetType = BottomSheetAppType.none;
  BottomSheetAppType get currentBottomSheetType => _currentBottomSheetType;

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  final driverservice = locator<DriverService>();
  final navigationService = locator<NavigationService>();

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
    if (_availableCourses.isNotEmpty) {
      setBottomSheetType(BottomSheetAppType.clients);
    }
  }

  // ✨ Charger les notifications stockées au démarrage
  Future<void> _loadStoredNotifications() async {
    try {
      _isLoadingCourses = true;
      notifyListeners();

      print('📱 Chargement des notifications stockées...');

      // Récupérer les notifications valides des dernières 24h (ou ajuste selon tes besoins)
      final storedNotifications =
          await CourseNotificationStorage.getValidNotifications(
        maxAge: const Duration(hours: 24),
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
        }
      }

      // Trier par timestamp (plus récent en premier) - si tu as besoin
      _availableCourses.sort((a, b) {
        // Supposant que tu ajoutes un timestamp à ClientData aussi
        // Sinon, tu peux trier par courseId ou autre critère
        return b.courseId!.compareTo(a.courseId!);
      });

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
    } else {
      _availableCourses[existingIndex] = clientData;
      print('🔄 Course mise à jour: ${clientData.name}');
    }

    if (_currentBottomSheetType != BottomSheetAppType.clients) {
      setBottomSheetType(BottomSheetAppType.clients);
    }

    notifyListeners();
  }

  void _onCourseUpdated(CourseNotificationData courseData) {
    final existingIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseData.courseId,
    );

    if (existingIndex != -1) {
      _availableCourses[existingIndex] = courseData.toClientData();
      notifyListeners();
      print('🔄 Course ${courseData.courseId} mise à jour');
    }
  }

  // ✨ Supprimer une course (et du storage aussi)
  void removeCourse(String courseId) async {
    _availableCourses.removeWhere((course) => course.courseId == courseId);

    // ✨ Supprimer aussi du storage
    await CourseNotificationStorage.removeNotification(courseId);

    if (_availableCourses.isEmpty) {
      hideBottomSheet();
    }

    notifyListeners();
  }

  void setBottomSheetType(BottomSheetAppType type) {
    _currentBottomSheetType = type;
    notifyListeners();
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
    setBottomSheetType(BottomSheetAppType.none);
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
      print('✅ Course acceptée: ${course.name} (ID: $courseId)');

      // NE PAS supprimer la course immédiatement - la garder pour pickup
      // _availableCourses.removeAt(courseIndex);

      // Supprimer du storage car course acceptée
      await CourseNotificationStorage.removeNotification(courseId);

      // Appeler le service
      await acceptCourseService(int.parse(courseId), context);
    }
  }

  // ✨ Refuser une course (et la supprimer du storage)
  void rejectCourse(String courseId) async {
    final courseIndex = _availableCourses.indexWhere(
      (course) => course.courseId == courseId,
    );

    if (courseIndex != -1) {
      final course = _availableCourses[courseIndex];
      print('❌ Course refusée: ${course.name} (ID: $courseId)');

      _availableCourses.removeAt(courseIndex);

      // ✨ Supprimer du storage car course refusée
      await CourseNotificationStorage.removeNotification(courseId);

      // TODO: Envoyer le refus au backend

      if (_availableCourses.isEmpty) {
        hideBottomSheet();
      }

      notifyListeners();
    }
  }

  // ✨ Nettoyer les notifications expirées (méthode utilitaire)
  Future<void> cleanExpiredNotifications() async {
    try {
      await CourseNotificationStorage.cleanExpiredNotifications();
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
    } finally {
      setBusy(false);
      print("🔄 setBusy(false) appelé");

      //(canAccept) ?
      setBottomSheetType(BottomSheetAppType.pickup);
      //:
      //hideBottomSheet();
    }
  }

  @override
  void dispose() {
    _newCourseSubscription?.cancel();
    _courseUpdateSubscription?.cancel();
    super.dispose();
  }
}
