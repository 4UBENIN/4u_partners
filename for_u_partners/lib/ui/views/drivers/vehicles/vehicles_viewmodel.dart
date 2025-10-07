// mes_vehicules_viewmodel.dart
import 'dart:convert';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/models/vehicle_model.dart';
// Importez seulement ce qui est nécessaire du fichier vehicles_view.dart
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class MesVehiculesViewModel extends BaseViewModel {
  Vehicle? _vehiculeActif;
  List<Vehicle> _vehicules = [];
  List<Vehicle> _vehiculesApprouves = [];
  bool _isApprovedExpanded = true;
  String? _errorMessage;

  // Remplacez par votre URL d'API
  static const String baseUrl = 'https://foryou.cilassocies.com/api'; // ex: 'https://api.example.com'

  Vehicle? get vehiculeActif => _vehiculeActif;
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
      print('Erreur initialisation: $e');
    }
    
    setBusy(false);
  }

  Future<void> fetchDashboardData() async {
    try {
      // Récupérez le token depuis votre système d'authentification
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/conducteur/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Réponse de l\'API: $data'); // Debug
        if (data['success'] == true) {
          final List<dynamic> vehiculesData = data['data'] ?? [];
          _vehicules = vehiculesData
              .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          
          print('Nombre total de véhicules: ${_vehicules.length}'); // Debug
          
          _vehiculesApprouves = _vehicules
              .where((vehicule) {
                print('Véhicule: ${vehicule.id} - Statut: ${vehicule.statut}');
                return vehicule.statut == 'approuve';
              })
              .toList();
          print('Nombre de véhicules approuvés: ${_vehiculesApprouves.length}'); // Debug
        } else {
          _errorMessage = data['message'] ?? 'Erreur lors de la récupération des véhicules';
        }
        
        notifyListeners();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur fetchDashboardData: $e');
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
      print('Erreur lors de la récupération du token: $e');
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
      // Appel API pour mettre à jour
    }
  }

  void toggleClim(bool value) {
    if (_vehiculeActif != null) {
      _vehiculeActif!.clim = value;
      notifyListeners();
      // Appel API pour mettre à jour
    }
  }

  void addNewVehicle() {
    // Navigation vers la page d'ajout de véhicule
    print('Ajouter un nouveau véhicule');
  }
}
