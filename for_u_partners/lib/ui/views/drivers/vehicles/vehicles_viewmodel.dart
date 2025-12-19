// mes_vehicules_viewmodel.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/ui/views/drivers/vehicles/add_vehicles.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/models/vehicle_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart' as api;

class MesVehiculesViewModel extends BaseViewModel {
  Vehicle? _vehiculeActif;
  List<Vehicle> _vehicules = [];
  List<Vehicle> _vehiculesApprouves = [];
  List<Vehicle> _vehiculesEnAttente = [];
  bool _isApprovedExpanded = true;
  bool _isPendingExpanded = true;
  String? _errorMessage;

  static String get baseUrl => api.baseUrl.replaceAll('/api', '');

  Vehicle? get vehiculeActif => _vehiculeActif;
  List<Vehicle> get vehicules => _vehicules;
  List<Vehicle> get vehiculesApprouves => _vehiculesApprouves;
  List<Vehicle> get vehiculesEnAttente => _vehiculesEnAttente;
  bool get isApprovedExpanded => _isApprovedExpanded;
  bool get isPendingExpanded => _isPendingExpanded;
  String? get errorMessage => _errorMessage;

  Future<void> initialise() async {
    setBusy(true);
    _errorMessage = null;
    
    try {
      await fetchDashboardData();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: $e';
      print('❌ Erreur initialisation: $e');
    }
    
    setBusy(false);
  }

  Future<void> fetchDashboardData() async {
    try {
      final token = await _getAuthToken();
      print('✅ Token récupéré: ${token.substring(0, 10)}...');
      
      final url = Uri.parse('$baseUrl/api/conducteur/dashboard');
      print('🌐 URL de l\'API: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('🔍 Données décodées: $data');

          // Log success message if present
          if (data['message'] != null) {
            print('ℹ️ Message du serveur: ${data['message']}');
          }

          // Handle new API structure with vehicules (plural) containing actifs and en_attente arrays
          if (data['vehicules'] != null) {
            final vehiculesData = data['vehicules'];
            final List<dynamic> actifs = vehiculesData['actifs'] ?? [];
            final List<dynamic> enAttente = vehiculesData['en_attente'] ?? [];

            print('📊 Véhicules actifs: ${actifs.length}, En attente: ${enAttente.length}');

            _vehiculesApprouves = [];
            _vehiculesEnAttente = [];
            _vehicules = [];

            // Process active vehicles
            for (var vehicleData in actifs) {
              final vehicle = _parseVehicle(vehicleData);
              _vehiculesApprouves.add(vehicle);
              _vehicules.add(vehicle);

              // Set first active vehicle as active vehicle
              if (_vehiculeActif == null) {
                _vehiculeActif = vehicle;
                if (vehicle.type != null) {
                  await _saveVehicleType(vehicle.type!);
                }
              }
            }

            // Process pending vehicles
            for (var vehicleData in enAttente) {
              final vehicle = _parseVehicle(vehicleData);
              _vehiculesEnAttente.add(vehicle);
              _vehicules.add(vehicle);
            }

            if (_vehicules.isEmpty) {
              _errorMessage = 'Aucun véhicule trouvé';
              print('⚠️ Aucun véhicule trouvé dans la réponse');
            } else {
              print('✅ ${_vehicules.length} véhicule(s) récupéré(s): ${_vehiculesApprouves.length} actif(s), ${_vehiculesEnAttente.length} en attente');
            }
          } else {
            _errorMessage = 'Aucun véhicule trouvé';
            print('⚠️ Pas de données véhicules dans la réponse');
            _vehicules = [];
            _vehiculesApprouves = [];
            _vehiculesEnAttente = [];
          }
        } catch (e, stackTrace) {
          print('❌ Erreur lors du décodage de la réponse: $e');
          print('📍 Stack trace: $stackTrace');
          _errorMessage = 'Erreur lors du traitement des données: $e';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Non autorisé - Token invalide ou expiré';
        print('❌ Erreur 401: Token invalide');
      } else {
        _errorMessage = 'Erreur ${response.statusCode}';
        print('❌ Erreur HTTP ${response.statusCode}: ${response.body}');
      }
      
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Erreur fetchDashboardData: $e');
      print('📍 Stack trace: $stackTrace');
      _errorMessage = 'Erreur de connexion: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<String> _getAuthToken() async {
    try {
      final SharedpreferencesService prefsService = locator<SharedpreferencesService>();
      final token = await prefsService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Aucun token d\'authentification trouvé');
      }
      return token;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      rethrow;
    }
  }

  Vehicle _parseVehicle(Map<String, dynamic> vehicleData) {
    final categorie = (vehicleData['categorie']?.toString() ?? 'standard').toLowerCase();

    // Déterminer les valeurs des switches en fonction de la catégorie
    bool basicValue = false;
    bool premiumValue = false;

    if (categorie == 'standard') {
      basicValue = true;
      premiumValue = false;
    } else if (categorie == 'premium') {
      basicValue = false;
      premiumValue = true;
    } else if (categorie == 'vip') {
      basicValue = false;
      premiumValue = true; // VIP est considéré comme Premium+
    }

    final vehicle = Vehicle(
      id: vehicleData['id']?.toString() ?? '',
      model: vehicleData['modele']?.toString() ?? 'Modèle non spécifié',
      marque: vehicleData['marque']?.toString() ?? 'Marque inconnue',
      immatriculation: vehicleData['immatriculation']?.toString() ?? '',
      statut: vehicleData['statut']?.toString(),
      categorie: categorie,
      couleur: vehicleData['couleur']?.toString() ?? 'Noire',
      type: vehicleData['type']?.toString(),
      nombrePlaces: vehicleData['nombre_places'] as int?,
      courseHeure: vehicleData['course_heure'] == true || vehicleData['course_heure'] == 1,
      clim: vehicleData['clim'] == true || vehicleData['clim'] == 1,
      basic: basicValue,
      premium: premiumValue,
    );

    print('✅ Véhicule parsé: ID=${vehicle.id}, Modèle=${vehicle.model}, Statut="${vehicle.statut}", Catégorie=${vehicle.categorie}');
    return vehicle;
  }

  void toggleApprovedExpanded() {
    _isApprovedExpanded = !_isApprovedExpanded;
    notifyListeners();
  }

  void togglePendingExpanded() {
    _isPendingExpanded = !_isPendingExpanded;
    notifyListeners();
  }

  void toggleCourseHeure(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.courseHeure = value;
      notifyListeners();
      _updateVehicleService('course_heure', value);
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      _updateVehicleService('clim', value);
    }
  }

  // 🔥 NOUVELLE LOGIQUE: Toggle Basic = Passer en catégorie Standard
  void toggleBasic(bool value) {
    if (_vehiculeActif == null) return;
    
    final categorieActuelle = _vehiculeActif!.categorie?.toLowerCase();
    
    // Si on active Basic, on passe en catégorie Standard
    if (value) {
      if (categorieActuelle == 'standard') {
        print('ℹ️ Le véhicule est déjà en catégorie Standard');
        return;
      }
      print('🔄 Changement de catégorie vers Standard...');
      _changerCategorie('standard');
    } else {
      // Si on désactive Basic depuis Standard, on ne fait rien
      // (ou vous pouvez définir un comportement spécifique)
      print('⚠️ Désactivation de Basic depuis la catégorie $categorieActuelle');
    }
  }

  // 🔥 NOUVELLE LOGIQUE: Toggle Premium = Passer en catégorie Premium
  void togglePremium(bool value) {
    if (_vehiculeActif == null) return;
    
    final categorieActuelle = _vehiculeActif!.categorie?.toLowerCase();
    
    // Si on active Premium, on passe en catégorie Premium
    if (value) {
      if (categorieActuelle == 'premium' || categorieActuelle == 'vip') {
        print('ℹ️ Le véhicule est déjà en catégorie $categorieActuelle');
        _errorMessage = 'Le véhicule est déjà en catégorie ${categorieActuelle?.toUpperCase()}';
        notifyListeners();
        return;
      }
      print('🔄 Changement de catégorie vers Premium...');
      _changerCategorie('premium');
    } else {
      // Si on désactive Premium, on peut revenir à Standard
      if (categorieActuelle == 'premium') {
        print('🔄 Retour à la catégorie Standard...');
        _changerCategorie('standard');
      } else if (categorieActuelle == 'vip') {
        print('⚠️ Impossible de désactiver Premium depuis VIP');
        _errorMessage = 'Impossible de modifier la catégorie VIP';
        // Restaurer l'état du switch
        _vehiculeActif!.premium = true;
        notifyListeners();
      }
    }
  }

  // 🆕 NOUVELLE MÉTHODE: Changer la catégorie du véhicule via l'API
  Future<void> _changerCategorie(String nouvelleCategorie) async {
    if (_vehiculeActif == null) return;
    
    final categorieActuelle = _vehiculeActif!.categorie;
    print('📊 Catégorie actuelle: $categorieActuelle → Nouvelle: $nouvelleCategorie');
    
    try {
      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/api/conducteur/changer-categorie');
      
      print('🔄 Changement de catégorie vers: $nouvelleCategorie');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vehicule_id': _vehiculeActif!.id,
          'nouvelle_categorie': nouvelleCategorie,
        }),
      );

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Catégorie changée avec succès vers $nouvelleCategorie');
        
        // Mettre à jour la catégorie locale
        _vehiculeActif!.categorie = nouvelleCategorie;
        
        // Mettre à jour les switches en fonction de la nouvelle catégorie
        final catLower = nouvelleCategorie.toLowerCase();
        if (catLower == 'standard') {
          _vehiculeActif!.basic = true;
          _vehiculeActif!.premium = false;
        } else if (catLower == 'premium' || catLower == 'vip') {
          _vehiculeActif!.basic = false;
          _vehiculeActif!.premium = true;
        }
        
        notifyListeners();
        
        // Rafraîchir les données pour être sûr
        await fetchDashboardData();
      } else {
        print('❌ Erreur lors du changement de catégorie: ${response.statusCode}');
        print('📦 Réponse: ${response.body}');
        
        // Parser le message d'erreur de l'API
        String errorMsg = 'Erreur lors du changement de catégorie';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (e) {
          print('⚠️ Impossible de parser le message d\'erreur');
        }
        
        _errorMessage = errorMsg;
        
        // Restaurer l'état des switches à leur valeur d'origine
        final catLower = categorieActuelle?.toLowerCase();
        if (catLower == 'standard') {
          _vehiculeActif!.basic = true;
          _vehiculeActif!.premium = false;
        } else if (catLower == 'premium' || catLower == 'vip') {
          _vehiculeActif!.basic = false;
          _vehiculeActif!.premium = true;
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erreur lors du changement de catégorie: $e');
      _errorMessage = 'Erreur de connexion lors du changement de catégorie';
      
      // Restaurer l'état des switches
      final catLower = categorieActuelle?.toLowerCase();
      if (catLower == 'standard') {
        _vehiculeActif!.basic = true;
        _vehiculeActif!.premium = false;
      } else if (catLower == 'premium' || catLower == 'vip') {
        _vehiculeActif!.basic = false;
        _vehiculeActif!.premium = true;
      }
      
      notifyListeners();
    }
  }

  // Méthode privée pour mettre à jour un service du véhicule via l'API
  Future<void> _updateVehicleService(String serviceName, bool value) async {
    if (_vehiculeActif == null) return;
    
    try {
      final token = await _getAuthToken();
      final url = Uri.parse('$baseUrl/api/conducteur/vehicules/${_vehiculeActif!.id}/services');
      
      print('🔄 Mise à jour du service $serviceName vers ${value ? "activé" : "désactivé"}');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          serviceName: value,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Service $serviceName mis à jour avec succès');
      } else {
        print('❌ Erreur lors de la mise à jour du service: ${response.statusCode}');
        print('📦 Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du service $serviceName: $e');
    }
  }

  final NavigationService _navigationService = locator<NavigationService>();

  Future<void> addNewVehicle() async {
    final BuildContext? context = _navigationService.navigatorKey?.currentContext;
    if (context == null) return;
    
    final result = await Navigator.of(context).push<Vehicle?>(
      MaterialPageRoute(builder: (context) => AddVehiclesView()),
    );
    
    if (result != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      await fetchDashboardData();
    }
  }

  /// Save vehicle type to SharedPreferences for marker selection in CoursesView
  Future<void> _saveVehicleType(String vehicleType) async {
    try {
      print('💾 [Vehicle] Tentative de sauvegarde du type de véhicule: "$vehicleType"');
      final sharedPrefs = locator<SharedpreferencesService>();
      await sharedPrefs.saveActiveVehicleType(vehicleType);

      // Verify it was saved
      final saved = await sharedPrefs.getActiveVehicleType();
      print('✅ [Vehicle] Type de véhicule sauvegardé: "$vehicleType", vérification: "$saved"');
    } catch (e) {
      print('❌ [Vehicle] Erreur lors de la sauvegarde du type de véhicule: $e');
    }
  }
}