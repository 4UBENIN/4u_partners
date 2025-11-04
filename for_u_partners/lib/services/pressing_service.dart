import 'dart:convert';
import 'package:for_u_partners/app/models/pressing_depot_models/depot_detail_model.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/depot_model.dart';
import 'package:for_u_partners/app/models/pressing_depot_models/planned_depot_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_detail_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_model.dart';
import 'package:for_u_partners/app/models/pressing_ramassage_models/ramassage_statut_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';
import 'package:for_u_partners/app/api_constant.dart';

class PressingService {
  final _authService = locator<AuthService>();

  //* GET PRESSING INFO
  Future<PressingResponse?> getPressingInfo() async {
    final url = Uri.parse("$baseUrl/pressing/dashboard");

    try {
      final response = await http.get(url,
          headers: await _authService.getAuthenticatedHeaders());

      print("GET PRESSING INFO HEADERS");
      print(await _authService.getAuthenticatedHeaders());

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PressingResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        print("Token expiré - redirection vers login");
        // await _authService.logout();
        throw Exception('Session expirée, reconnexion nécessaire');
      } else if (response.statusCode == 404) {
        print("Pressing non trouvé");
        throw Exception('Pressing non trouvé');
      } else {
        print("Erreur serveur : ${response.statusCode}");
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      print("Erreur lors de la récupération des infos pressing : $e");
      rethrow; // Relancer l'erreur pour que le ViewModel puisse la gérer
    }
  }

  //! RAMASSAGE SERVICE

  //* GET PRESSING RAMASSAGE LIST
  // Récupérer la liste des ramassages assignés au pressing
  Future<List<Ramassage>> getRamassagesList() async {
    try {
      final url =
          Uri.parse("$baseUrl/pressing/ramassages");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Ramassages Status: ${response.statusCode}');
      print('Ramassages Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ramassageList = RamassageDemandModel.fromJson(jsonData);
        return ramassageList.ramassages ?? [];

        //* Non authentifié
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');

        //* erreur
      } else {
        throw Exception('Erreur lors du chargement des ramassages');
      }
    } catch (e) {
      print("Erreur ramassages: $e");
      rethrow;
    }
  }

  //* GET PRESSING RAMASSAGE DETAILS COMPLET
  // Récupérer le détail complet d'un ramassage avec toutes les infos
  Future<RamassageDetail> getRamassageDetailComplet(int id) async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/ramassages/$id");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Detail Status: ${response.statusCode}');
      print('Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RamassageDetail.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('Ramassage non trouvé');
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      print("Erreur détail ramassage complet: $e");
      rethrow;
    }
  }

  //* RAMASSAGE TERMINE
  // Marquer une demande comme terminée
  Future<RamassageStatutModel> updateRamassageStatut(int id) async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/ramassages/$id/complete");
      final response = await http.post(
        url,
        headers: {
          ...await _authService.getAuthenticatedHeaders(),
          'Content-Type': 'application/json',
        },
      );

      print('Update Status Code: ${response.statusCode}');
      print('Update Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RamassageStatutModel.fromJson(jsonData);
      } else if (response.statusCode == 204) {
        // Return a default RamassageStatutModel when there's no content
        return RamassageStatutModel();
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      print("Erreur update statut: $e");
      rethrow;
    }
  }

  //* GET FINISHED RAMASSAGE DEMAND LIST
  // Récupérer la liste des ramassages finis du pressing
  Future<List<Ramassage>> getFinishedRamassageList() async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/ramassages/finish");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Ramassages Finis Status: ${response.statusCode}');
      print('Ramassages Finis Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ramassageList = RamassageDemandModel.fromJson(jsonData);
        return ramassageList.ramassages ?? [];

        //* Non authentifié
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');

        //* erreur
      } else {
        throw Exception('Erreur lors du chargement des ramassages finis');
      }
    } catch (e) {
      print("Erreur ramassages finis: $e");
      rethrow;
    }
  }

  //! DEPOT PRESSING SERVICE

  //* GET DEPOT DEMAND LIST
  // Récupérer la liste des dépot assignés au pressing
  Future<List<Depot>> getDepotList() async {
    try {
      final url =
          Uri.parse("$baseUrl/pressing/rendezvous");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Dépot Status: ${response.statusCode}');
      print('Dépot Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final depotList = DepotDemandModel.fromJson(jsonData);
        return depotList.data ?? [];

        //* Non authentifié
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');

        //* erreur
      } else {
        throw Exception('Erreur lors du chargement des ramassages');
      }
    } catch (e) {
      print("Erreur ramassages: $e");
      rethrow;
    }
  }

  //* GET PRESSING DEPOT DETAILS COMPLET
  // Récupérer le détail complet d'un dépot avec toutes les infos
  Future<Rdv> getDepotDetailComplet(int id) async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/rendezvous/$id");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Detail depot Status: ${response.statusCode}');
      print('Detail depot Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Rdv.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('depot non trouvé');
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      print("Erreur détail depot complet: $e");
      rethrow;
    }
  }

  //* PLANIFIER UN DEPOT
  // Planifier un rendez-vous pour un dépot
  Future<PlannedDepotModel> planifierDepot(int id) async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/rendezvous/$id/valider");
      final response = await http.post(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('planifier depot Status: ${response.statusCode}');
      print('planifier depot Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PlannedDepotModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('depot non trouvé');
      } else {
        throw Exception('Erreur lors de la planification du rendez-vous');
      }
    } catch (e) {
      print("Erreur dépôt planifié: $e");
      rethrow;
    }
  }

  //* GET DEPOT PLANIFIED LIST
  // Récupérer la liste des dépôts planifiés assignés au pressing
  Future<List<Depot>> getPlanifiedDepotList() async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/rendezvous/planifier");

      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Dépôts planifiés Status: ${response.statusCode}');
      print('Dépôts planifiés Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final depotList = DepotDemandModel.fromJson(jsonData);
        return depotList.data ?? [];
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors du chargement des dépôts planifiés');
      }
    } catch (e) {
      print("Erreur dépôts planifiés: $e");

      return [];
    }
  }

  //* GET FINISHED DEPOT DEMAND LIST
  // Récupérer la liste des dépot assignés au pressing
  Future<List<Depot>> getFinishedDepotList() async {
    try {
      final url = Uri.parse(
          "$baseUrl/pressing/rendezvous/finish");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Dépot Finis Status: ${response.statusCode}');
      print('Dépot Finis Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final depotList = DepotDemandModel.fromJson(jsonData);
        return depotList.data ?? [];

        //* Non authentifié
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');

        //* erreur
      } else {
        throw Exception('Erreur lors du chargement des depots finis');
      }
    } catch (e) {
      print("Erreur depots finis: $e");
      rethrow;
    }
  }

  //! ACTIVITY PART

  Future<dynamic> getActivityDetails({
    required String type,
    required int id,
  }) async {
    final url =
        Uri.parse("$baseUrl/pressing/$type/$id");
    final response = await http.get(
      url,
      headers: await _authService.getAuthenticatedHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (type == 'ramassages') {
        return RamassageDetail.fromJson(data);
      } else {
        return Rdv.fromJson(data);
      }
    } else {
      throw Exception("Erreur lors de la récupération des détails");
    }
  }
}
