import 'dart:async';
import 'package:for_u_partners/app/models/deliveryModels/delivery_request.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/delivery_service.dart'; // Assure-toi que ce service existe
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/delivery/courses_delivery/model/client_model.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'dart:io' show Platform;

class CoursesDeliveryViewModel extends BaseViewModel {
  BuildContext? _currentContext;
  // Contrôleur de carte
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;
  final deliveryService = locator<DeliveryService>();
  final navigationService = locator<NavigationService>();

  // Position initiale de la carte
  LatLng _mapCenter =
      const LatLng(6.3586, 2.3912); // Position par défaut (Cotonou)
  LatLng get mapCenter => _mapCenter;

  // Niveau de zoom initial
  double _mapZoom = 15.0;
  double get mapZoom => _mapZoom;

  // Liste des marqueurs
  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  // Liste des demandes de livraison disponibles
  final List<DeliveryRequestData> _availableDeliveries = [];
  List<DeliveryRequestData> get availableDeliveries =>
      List.unmodifiable(_availableDeliveries);

  // Demande de livraison actuellement sélectionnée
  DeliveryRequestData? _currentDelivery;
  DeliveryRequestData? get currentDelivery => _currentDelivery;

  // États de chargement
  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  bool _isLoadingDeliveries = true;
  bool get isLoadingDeliveries => _isLoadingDeliveries;

  // Position actuelle de l'utilisateur
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // État du bottom sheet
  BottomSheetAppType _currentBottomSheetType = BottomSheetAppType.none;
  BottomSheetAppType get currentBottomSheetType => _currentBottomSheetType;

  // États du trajet
  bool _isGoingToPickup = false;
  bool get isGoingToPickup => _isGoingToPickup;

  bool _isOnDelivery = false;
  bool get isOnDelivery => _isOnDelivery;

  // Platform checks
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  CoursesDeliveryViewModel();

  // ✨ Initialisation complète du ViewModel
  Future<void> initialize() async {
    // Attendre que le contexte soit défini
    while (_currentContext == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Lancer les tâches en parallèle
    await Future.wait([
      _getCurrentLocation(),
      _loadAvailableDeliveries(),
    ]);
    if (_availableDeliveries.isNotEmpty) {
      setBottomSheetType(BottomSheetAppType.clients);
    }
  }

  // ✨ Charger les demandes de livraison depuis l'API
  void setContext(BuildContext context) {
    _currentContext = context;
  }

  Future<void> _loadAvailableDeliveries() async {
    if (_currentContext == null) {
      print('⚠️ Context is not set. Call setContext() first.');
      return;
    }

    try {
      _isLoadingDeliveries = true;
      notifyListeners();

      print('📦 Chargement des demandes de livraison...');

      // Appeler l'API pour récupérer les demandes de livraison
      final response =
          await deliveryService.getAvailableDeliveries(_currentContext!);

      // Parser la réponse
      final deliveryResponse = DeliveryRequestResponse.fromJson(response);

      // Vider la liste actuelle et ajouter les nouvelles demandes
      _availableDeliveries.clear();
      _availableDeliveries.addAll(deliveryResponse.data);

      print('✅ ${_availableDeliveries.length} demandes de livraison chargées');

      // Toujours afficher le bottom sheet, même s'il n'y a pas de livraisons
      setBottomSheetType(BottomSheetAppType.clients);

      _isLoadingDeliveries = false;
      notifyListeners();
    } catch (e) {
      print('❌ Erreur chargement demandes de livraison: $e');
      _isLoadingDeliveries = false;
      notifyListeners();
    }
  }

  // ✨ Rafraîchir les demandes de livraison
  Future<void> refreshDeliveries() async {
    await _loadAvailableDeliveries();

    // Réafficher le bottom sheet si nécessaire
    if (_availableDeliveries.isNotEmpty &&
        _currentBottomSheetType == BottomSheetAppType.none) {
      setBottomSheetType(BottomSheetAppType.clients);
    } else if (_availableDeliveries.isEmpty) {
      hideBottomSheet();
    }
  }

  // Obtenir la position actuelle de l'utilisateur
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
      _mapController.move(_mapCenter, _mapZoom);
      _addUserLocationMarker();

      _isLoadingLocation = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // Ajouter un marqueur pour la position actuelle de l'utilisateur
  void _addUserLocationMarker() {
    _markers.removeWhere((marker) =>
        marker.point ==
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude));

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );
    }
  }

  // ✨ Convertir DeliveryRequestData en DeliveryClientData pour l'affichage
  List<DeliveryClientData> getClientsList() {
    return _availableDeliveries
        .map((delivery) => delivery.toDeliveryClientData())
        .toList();
  }

  // ✨ Accepter une demande de livraison
  Future<void> acceptDelivery(String deliveryId, BuildContext context) async {
    final deliveryIndex = _availableDeliveries.indexWhere(
      (delivery) => delivery.livraisonId == deliveryId,
    );

    if (deliveryIndex != -1) {
      final delivery = _availableDeliveries[deliveryIndex];
      _currentDelivery = delivery;
      _isGoingToPickup = true;
      _isOnDelivery = false;

      print('✅ Livraison acceptée: ${delivery.fullName} (ID: $deliveryId)');

      // Tracer la route vers le point de départ si possible
      if (_currentPosition != null &&
          delivery.departLat != null &&
          delivery.departLng != null) {
        await _drawRouteToPickup();
      }

      // Supprimer de la liste des demandes disponibles
      _availableDeliveries.removeAt(deliveryIndex);

      // Appeler le service
      await acceptDeliveryService(int.parse(deliveryId), context);
    }
  }

  // ✨ Refuser une demande de livraison
  Future<void> rejectDeliveryById(String deliveryId) async {
    final deliveryIndex = _availableDeliveries.indexWhere(
      (delivery) => delivery.livraisonId == deliveryId,
    );

    if (deliveryIndex != -1) {
      final delivery = _availableDeliveries[deliveryIndex];
      print('❌ Livraison refusée: ${delivery.fullName} (ID: $deliveryId)');

      _availableDeliveries.removeAt(deliveryIndex);

      // TODO: Appeler l'API pour envoyer le refus

      if (_availableDeliveries.isEmpty) {
        hideBottomSheet();
      }

      notifyListeners();
    }
  }

  // ✨ Supprimer une livraison de la liste
  void removeDelivery(String deliveryId) {
    _availableDeliveries
        .removeWhere((delivery) => delivery.livraisonId == deliveryId);

    if (_availableDeliveries.isEmpty) {
      hideBottomSheet();
    }

    notifyListeners();
  }

  // Services API calls
  Future<void> acceptDeliveryService(
      int deliveryId, BuildContext context) async {
    bool canAccept = false;
    try {
      setBusy(true);
      print("🔄 Début acceptation livraison...");

      // TODO: Remplace par la vraie méthode de ton service
      // await deliveryService.acceptDelivery(deliveryId);

      canAccept = true;
      print("✅ Livraison acceptée avec succès");
    } catch (e) {
      print('❌ Erreur acceptation livraison: $e');
      canAccept = false;
      CustomToast.showError(context, message: e.toString());

      // Réinitialiser en cas d'erreur
      _isGoingToPickup = false;
      _currentDelivery = null;
      _markers.clear();
      _addUserLocationMarker();
    } finally {
      setBusy(false);

      if (canAccept) {
        setBottomSheetType(BottomSheetAppType.pickup);

        // Recentrer sur le point de ramassage
        if (_currentDelivery != null &&
            _currentDelivery!.departLat != null &&
            _currentDelivery!.departLng != null) {
          final pickupLatLng = LatLng(
              _currentDelivery!.departLat!, _currentDelivery!.departLng!);
          _mapController.move(pickupLatLng, 15.0);
        }
      } else {
        hideBottomSheet();
      }
    }
  }

  Future<void> startDeliveryService(
      int deliveryId, BuildContext context) async {
    bool canStart = false;
    try {
      setBusy(true);
      print("🔄 Début démarrage livraison...");

      // TODO: Appeler ton service de livraison
      // await deliveryService.startDelivery(deliveryId);

      canStart = true;
      print("✅ Livraison démarrée avec succès");
    } catch (e) {
      print('❌ Erreur démarrage livraison: $e');
      canStart = false;
      CustomToast.showError(context, message: e.toString());
    } finally {
      setBusy(false);

      if (canStart) {
        setBottomSheetType(BottomSheetAppType.inprogress);
      }
    }
  }

  // ✨ Tracer la route vers le point de ramassage
  Future<void> _drawRouteToPickup() async {
    if (_currentPosition == null ||
        _currentDelivery == null ||
        _currentDelivery!.departLat == null ||
        _currentDelivery!.departLng == null) {
      return;
    }

    try {
      final pickupLatLng =
          LatLng(_currentDelivery!.departLat!, _currentDelivery!.departLng!);

      // Ajouter marqueur pickup
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: pickupLatLng,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );

      // Ajuster la caméra pour voir les deux points
      _adjustCameraToShowBothPoints(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        pickupLatLng,
      );

      print('✅ Route vers pickup ajoutée');
    } catch (e) {
      print('❌ Erreur calcul route pickup: $e');
    }

    notifyListeners();
  }

  // ✨ Ajuster la caméra pour afficher plusieurs points
  void _adjustCameraToShowBothPoints(LatLng point1, LatLng point2) {
    // Calculer les limites
    final minLat =
        [point1.latitude, point2.latitude].reduce((a, b) => a < b ? a : b);
    final maxLat =
        [point1.latitude, point2.latitude].reduce((a, b) => a > b ? a : b);
    final minLng =
        [point1.longitude, point2.longitude].reduce((a, b) => a < b ? a : b);
    final maxLng =
        [point1.longitude, point2.longitude].reduce((a, b) => a > b ? a : b);

    // Calculer le centre et le zoom approprié
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final center = LatLng(centerLat, centerLng);

    // Calculer la distance pour ajuster le zoom
    final distance = Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );

    // Ajuster le zoom selon la distance
    double zoom = 15.0;
    if (distance > 5000) {
      zoom = 12.0;
    } else if (distance > 2000)
      zoom = 13.0;
    else if (distance > 1000) zoom = 14.0;

    _mapController.move(center, zoom);
  }

  // Gestion des bottom sheets
  void setBottomSheetType(BottomSheetAppType type) {
    _currentBottomSheetType = type;
    notifyListeners();
  }

  void onNewDeliveryRequest() {
    setBottomSheetType(BottomSheetAppType.clients);
  }

  void hideBottomSheet() {
    setBottomSheetType(BottomSheetAppType.none);
  }

  // Démarrer la livraison
  void startDelivery() {
    if (_currentDelivery == null) return;

    _isGoingToPickup = false;
    _isOnDelivery = true;

    // TODO: Tracer la route vers la destination si tu as cette info
    // _drawRouteToDestination();

    notifyListeners();
  }

  // Terminer la livraison
  void completeDelivery() {
    _isOnDelivery = false;
    _isGoingToPickup = false;
    _currentDelivery = null;
    _markers.clear();
    _addUserLocationMarker();

    notifyListeners();
  }

  // Recentrer sur la position actuelle
  Future<void> recenterOnUserLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _mapZoom,
      );
    } else {
      await _getCurrentLocation();
    }
  }

  void onMapTapped(LatLng point) {
    addMarker(point);
  }

  // Ajouter un marqueur
  void addMarker(LatLng position) {
    final newMarker = Marker(
      width: 80.0,
      height: 80.0,
      point: position,
      child: Container(
        child: const Icon(
          Icons.place,
          color: Colors.red,
          size: 40,
        ),
      ),
    );

    _markers.add(newMarker);
    notifyListeners();
  }

  // Changer la position centrale de la carte
  void changeMapCenter(LatLng newCenter) {
    _mapCenter = newCenter;
    _mapController.move(newCenter, _mapZoom);
    notifyListeners();
  }

  // Changer le niveau de zoom
  void changeZoom(double newZoom) {
    _mapZoom = newZoom;
    _mapController.move(_mapCenter, newZoom);
    notifyListeners();
  }
}
