// mes_vehicules_viewmodel.dart
import 'dart:convert';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/models/vehicle_model.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class MesVehiculesViewModel extends BaseViewModel {
  Vehicle? _vehiculeActif;
  List<Vehicle> _vehicules = [];
  List<Vehicle> _vehiculesApprouves = [];
  bool _isApprovedExpanded = true;
  String? _errorMessage;

  // URL de base corrigée (sans /api à la fin)
  static const String baseUrl = 'https://foryou.cilassocies.com';

  Vehicle? get vehiculeActif => _vehiculeActif;
  List<Vehicle> get vehicules => _vehicules;
  List<Vehicle> get vehiculesApprouves => _vehiculesApprouves;
  bool get isApprovedExpanded => _isApprovedExpanded;
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
      // Récupération du token
      final token = await _getAuthToken();
      print('✅ Token récupéré: ${token.substring(0, 10)}...');
      
      // URL corrigée
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
          
          // Le champ 'vehicule' contient les données du véhicule
          if (data['vehicule'] != null) {
            // Créer un véhicule à partir de l'objet vehicule
            final vehicleData = Map<String, dynamic>.from(data['vehicule']);
            final vehicle = Vehicle(
              id: vehicleData['id']?.toString() ?? '',
              model: vehicleData['modele']?.toString() ?? 'Modèle non spécifié',
              marque: vehicleData['marque']?.toString() ?? 'Marque inconnue',
              immatriculation: vehicleData['immatriculation']?.toString() ?? '',
              statut: vehicleData['statut']?.toString(),
              categorie: vehicleData['categorie']?.toString() ?? 'standard',
              couleur: vehicleData['couleur']?.toString() ?? 'Noire',
              courseHeure: vehicleData['course_heure'] == true || vehicleData['course_heure'] == 1,
              clim: vehicleData['clim'] == true || vehicleData['clim'] == 1,
              basic: vehicleData['basic'] == true || vehicleData['basic'] == 1,
              premium: vehicleData['premium'] == true || vehicleData['premium'] == 1,
            );
            
            print('ℹ️ Catégorie du véhicule: ${vehicle.categorie}');
            print('ℹ️ Services - Course à l\'heure: ${vehicle.courseHeure}, Clim: ${vehicle.clim}, Basic: ${vehicle.basic}, Premium: ${vehicle.premium}');
            
            _vehicules = [vehicle];
            // Définir le véhicule actif
            _vehiculeActif = vehicle;
            print('✅ Véhicule récupéré: ID=${vehicle.id}, Modèle=${vehicle.model}, Statut="${vehicle.statut}"');
            
            // On affiche le véhicule dans les deux sections, peu importe son statut
            _vehiculesApprouves = List<Vehicle>.from(_vehicules);
            
            // Si le véhicule est en attente, on l'affiche avec un statut spécial
            if (vehicle.statut?.toLowerCase() == 'en_attente') {
              print('ℹ️ Le véhicule est en attente de validation mais sera affiché');
            }
          } else if (data['message'] != null) {
            // Si pas de véhicule mais un message est présent
            _errorMessage = data['message'];
            print('ℹ️ Message du serveur: $_errorMessage');
            _vehicules = [];
            _vehiculesApprouves = [];
          } else {
            // Aucun véhicule et pas de message d'erreur
            _errorMessage = 'Aucun véhicule trouvé';
            _vehicules = [];
            _vehiculesApprouves = [];
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

  void toggleApprovedExpanded() {
    _isApprovedExpanded = !_isApprovedExpanded;
    notifyListeners();
  }

  void toggleCourseHeure(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.courseHeure = value;
      notifyListeners();
      // TODO: Appel API pour mettre à jour
      _updateVehicleService('course_heure', value);
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      // TODO: Appel API pour mettre à jour
      _updateVehicleService('clim', value);
    }
  }

  void toggleBasic(bool value) {
    if (_vehiculeActif != null) {
      final categorie = _vehiculeActif!.categorie?.toLowerCase();
      
      // Vérifier que ce n'est pas un véhicule VIP (Basic est verrouillé pour VIP)
      if (categorie == 'vip') {
        print('⚠️ Basic est verrouillé pour les véhicules VIP');
        return;
      }
      
      _vehiculeActif!.basic = value;
      notifyListeners();
      print('🔄 Basic ${value ? "activé" : "désactivé"}');
      // TODO: Appel API pour mettre à jour
      _updateVehicleService('basic', value);
    }
  }

  void togglePremium(bool value) {
    if (_vehiculeActif != null) {
      final categorie = _vehiculeActif!.categorie?.toLowerCase();
      
      // Vérifier que c'est bien un véhicule VIP
      if (categorie != 'vip') {
        print('⚠️ Premium est disponible uniquement pour les véhicules VIP');
        return;
      }
      
      _vehiculeActif!.premium = value;
      notifyListeners();
      print('🔄 Premium ${value ? "activé" : "désactivé"}');
      // TODO: Appel API pour mettre à jour
      _updateVehicleService('premium', value);
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
        // Optionnel: Rétablir l'état précédent en cas d'erreur
        // await fetchDashboardData();
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du service $serviceName: $e');
      // Optionnel: Rétablir l'état précédent en cas d'erreur
      // await fetchDashboardData();
    }
  }

  void addNewVehicle() {
    // TODO: Navigation vers la page d'ajout de véhicule
    print('Ajouter un nouveau véhicule');
  }
}