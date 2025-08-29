import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_detail.dart';
import 'package:for_u_partners/app/models/ramasseur_models/ramasseur_demand_model.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:stacked_services/stacked_services.dart';

class PickersService {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  //* GET TOKEN HEADERS
  Future<Map<String, String>> getAuthenticatedHeaders() async {
    final token = await _sharedPreferencesService.getToken();

    // Créer une copie des headers de base et ajouter le token
    final authenticatedHeaders = Map<String, String>.from(headers);

    if (token != null && token.isNotEmpty) {
      // Remove any existing quotes from the token
      final cleanToken = token.replaceAll('"', '').trim();
      authenticatedHeaders['Authorization'] = 'Bearer $cleanToken';
    }
    print("AUTH HEADERS : ");
    print(authenticatedHeaders);

    return authenticatedHeaders;
  }

  //* Récupérer la liste des demandes de ramassage
  Future<RamasseurDemand> getRamassageList() async {
    final url = Uri.parse('$baseUrl/conducteur/demandes-ramassage');

    final response =
        await http.get(url, headers: await getAuthenticatedHeaders());

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return RamasseurDemand.fromJson(responseData);

      //* Non authentifié
    } else if (response.statusCode == 401) {
      await _authService.logOut();
      throw Exception('Session expirée');

      //* erreur
    } else {
      throw Exception('Erreur lors du chargement des demandes de ramassages');
    }
  }

  Future<RamasseurDemand> getActivityList() async {
    final url = Uri.parse('$baseUrl/conducteur/demandes-ramassage-terminer');

    final response =
        await http.get(url, headers: await getAuthenticatedHeaders());

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return RamasseurDemand.fromJson(responseData);

      //* Non authentifié
    } else if (response.statusCode == 401) {
      await _authService.logOut();
      throw Exception('Session expirée');

      //* erreur
    } else {
      throw Exception('Erreur lors du chargement des demandes de ramassages');
    }
  }

  //* Accepter une demande de ramassage
  Future<void> acceptRamassage(int id, BuildContext context) async {
    final url = Uri.parse(
        'https://foryou.cilassocies.com/api/conducteur/demandes-ramassage/$id/accept');

    print('🔵 Appel API - URL: $url');
    print('🆔 ID de la demande: $id');

    try {
      final headers = await getAuthenticatedHeaders();
      print('🔑 En-têtes d\'authentification: $headers');

      final response = await http.post(
        url,
        headers: headers,
      );

      print('🟢 Réponse du serveur - Status: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Demande acceptée avec succès: $responseData');
        return;
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        //* Erreur serveur
        final errorMsg =
            '❌ Erreur ${response.statusCode} lors de l\'acceptation de la demande';
        print('$errorMsg: ${response.body}');
        throw Exception('$errorMsg: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'acceptation de la demande: $e');
      rethrow;
    }
  }

  //* Voir les détails d'une demande de ramassage
  Future<RamasseurDemandDetail> getCurrentRamassageDetails(
      int id, BuildContext context) async {
    final url = Uri.parse(
        'https://foryou.cilassocies.com/api/conducteur/demandes-ramassage/$id/preview');

    print('🔍 Récupération des détails de la demande $id...');

    try {
      final headers = await getAuthenticatedHeaders();
      print('🔑 En-têtes: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('🟢 Réponse - Status: ${response.statusCode}');
      print('📄 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('✅ Détails de la demande récupérés avec succès');
          return RamasseurDemandDetail.fromJson(responseData);
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception(
              'Erreur lors de la lecture des données de la demande');
        }
      } else if (response.statusCode == 401) {
        //* Non authentifié
        print('🔐 Session expirée, déconnexion...');
        await _authService.logOut();
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      } else {
        //* Autre erreur
        final errorMsg =
            'Erreur ${response.statusCode} lors de la récupération des détails';
        print('❌ $errorMsg');
        print('Réponse complète: ${response.body}');
        throw Exception('$errorMsg. Veuillez réessayer plus tard.');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des détails: $e');
      rethrow;
    }
  }
}
