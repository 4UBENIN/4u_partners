import 'package:stacked/stacked.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:for_u_partners/app/app.bottomsheets.dart';
import 'package:for_u_partners/ui/common/enum/bottom_enum.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';

class CoursesViewModel extends BaseViewModel {
  // Contrôleur de carte
  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  // Position initiale de la carte (sera mise à jour avec la position utilisateur)
  LatLng _mapCenter = LatLng(48.8566, 2.3522); // Position par défaut
  LatLng get mapCenter => _mapCenter;

  // Niveau de zoom initial
  double _mapZoom = 15.0; // Zoom plus proche pour la position utilisateur
  double get mapZoom => _mapZoom;

  // Liste des marqueurs
  List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  // État du chargement de la position
  bool _isLoadingLocation = true;
  bool get isLoadingLocation => _isLoadingLocation;

  // Position actuelle de l'utilisateur
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  BottomSheetAppType _currentBottomSheetType = BottomSheetAppType.none;

  BottomSheetAppType get currentBottomSheetType => _currentBottomSheetType;

  List<ClientData> getClientsList() {
    return [
      ClientData(
        name: 'Teddy TOSSOU',
        timeInfo: 'A 3 minute de vous',
        destination: 'Se rend à Erevan Fidjrosse Cotonou',
        initials: 'T',
      ),
      ClientData(
        name: 'Teddy TOSSOU',
        timeInfo: 'A 3 minute de vous',
        destination: 'Se rend à Erevan Fidjrosse Cotonou',
        initials: 'T',
      ),
      ClientData(
        name: 'Teddy TOSSOU',
        timeInfo: 'A 3 minute de vous',
        destination: 'Se rend à Erevan Fidjrosse Cotonou',
        initials: 'T',
      ),
    ];
  }

  CoursesViewModel() {
    _getCurrentLocation();
    onNewClientRequest();
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      // Vérifier les permissions
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

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Mettre à jour la position de la carte
      _mapCenter =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      // Déplacer la carte vers la position actuelle
      _mapController.move(_mapCenter, _mapZoom);

      // Ajouter un marqueur pour la position actuelle
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
    _markers.clear(); // Supprimer les anciens marqueurs

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          builder: (ctx) => Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              Icons.my_location,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );
    }
  }

  void setBottomSheetType(BottomSheetAppType type) {
    _currentBottomSheetType = type;
    notifyListeners();
  }

  void onNewClientRequest() {
    setBottomSheetType(BottomSheetAppType.clients);
  }

  // Exemple : fermer tous les bottom sheets
  void hideBottomSheet() {
    setBottomSheetType(BottomSheetAppType.none);
  }

  // Recentrer sur la position actuelle
  Future<void> recenterOnUserLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _mapZoom);
    } else {
      // Si pas de position actuelle, essayer de l'obtenir
      await _getCurrentLocation();
    }
  }

  void onMapTapped(LatLng point) {
    // Ajouter un nouveau marqueur à la position tappée
    addMarker(point);
  }

  // Ajouter un marqueur
  void addMarker(LatLng position) {
    final newMarker = Marker(
      width: 80.0,
      height: 80.0,
      point: position,
      builder: (ctx) => Container(
        child: Icon(
          Icons.place,
          color: Colors.blue,
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

  // Nettoyer les ressources
  @override
  void dispose() {
    // Nettoyer le contrôleur si nécessaire
    super.dispose();
  }
}
