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
  List<Vehicle> get vehicules => _vehicules; // Ajout : retourner tous les véhicules
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
              courseHeure: false,
              clim: false,
            );
            
            print('ℹ️ Catégorie du véhicule: ${vehicle.categorie}'); // Pour le débogage
            
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
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      // TODO: Appel API pour mettre à jour
    }
  }

  void addNewVehicle() {
    // TODO: Navigation vers la page d'ajout de véhicule
    print('Ajouter un nouveau véhicule');
  }
}