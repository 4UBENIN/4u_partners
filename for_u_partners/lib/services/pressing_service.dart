import 'dart:convert';
import 'package:for_u_partners/app/models/depot_models/depot_detail_model.dart';
import 'package:for_u_partners/app/models/depot_models/depot_model.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_detail_model.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_model.dart';
import 'package:for_u_partners/app/models/ramassage_models/ramassage_statut_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/app/models/pressing_model.dart';

class PressingService {
  final _authService = locator<AuthService>();

  //* GET PRESSING INFO
  Future<PressingResponse?> getPressingInfo() async {
    final url =
        Uri.parse("https://foryou.cilassocies.com/api/pressing/dashboard");

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
          Uri.parse("https://foryou.cilassocies.com/api/pressing/ramassages");
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
          "https://foryou.cilassocies.com/api/pressing/ramassages/$id");
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
          "https://foryou.cilassocies.com/api/pressing/ramassages/$id/complete");
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

  //! DEPOT PRESSING SERVICE

  //* GET DEPOT DEMAND LIST
  // Récupérer la liste des dépot assignés au pressing
  Future<List<Depot>> getDepotList() async {
    try {
      final url =
          Uri.parse("https://foryou.cilassocies.com/api/pressing/rendezvous");
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
          "https://foryou.cilassocies.com/api/pressing/rendezvous/$id");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Detail Status: ${response.statusCode}');
      print('Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Rdv.fromJson(jsonData);
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
}
