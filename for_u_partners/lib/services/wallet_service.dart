import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/wallet_model.dart';
import 'package:for_u_partners/app/models/parrainage_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/app/api_constant.dart';

class WalletService {
  final _authService = locator<AuthService>();

  /// Check if response contains authentication error and logout if necessary
  void _checkAuthenticationError(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      if (responseData is Map && responseData['error'] == 'Unauthenticated.') {
        debugPrint('⚠️ [WalletService] Unauthenticated error detected - logging out user');
        _authService.logOut();
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
  }

  //* GET WALLET BALANCE
  // Récupérer le solde du portefeuille
  Future<WalletModel> getWalletSold() async {
    try {
      final url = Uri.parse("$baseUrl/wallet_solde/");
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Wallet Status: ${response.statusCode}');
      print('Wallet Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // The API returns 'balance' as the correct wallet balance field
        // 'solde' is a legacy/incorrect field and should be ignored
        // Ensure we always use 'balance' - fallback to 'solde' only if 'balance' doesn't exist
        if (jsonData['balance'] == null && jsonData['solde'] != null) {
          jsonData['balance'] = jsonData['solde'];
        }
        return WalletModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('Wallet non trouvé');
      } else {
        throw Exception('Erreur lors du chargement de la balance');
      }
    } catch (e) {
      print("Erreur wallet: $e");
      rethrow;
    }
  }

  //* GET UNCOLLECTED BONUSES
  // Récupérer les bonus non remboursés
  // TODO: Update this endpoint when the correct API route is provided
  // Current route "/api/conducteur/parrainage/non-rembourses" returns 404
  Future<List<ParrainageModel>> getUncollectedBonuses() async {
    try {
      // Temporarily return empty list until correct endpoint is provided
      // The API documentation only shows POST /api/conducteur/parrainage/remboursement/{id}
      // but no GET endpoint for listing uncollected bonuses
      debugPrint('⚠️ [WalletService] Uncollected bonuses endpoint not available - returning empty list');
      return [];

      /* COMMENTED OUT UNTIL CORRECT ENDPOINT IS PROVIDED
      final url = Uri.parse(getUncollectedBonusesUrl);
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Uncollected Bonuses Status: ${response.statusCode}');
      print('Uncollected Bonuses Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['parrainages'] != null) {
          List<ParrainageModel> bonuses = [];
          for (var item in jsonData['parrainages']) {
            bonuses.add(ParrainageModel.fromJson(item));
          }
          return bonuses;
        }
        return [];
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors du chargement des bonus');
      }
      */
    } catch (e) {
      print("Erreur uncollected bonuses: $e");
      // Return empty list instead of rethrowing to prevent app crashes
      return [];
    }
  }

  //* COLLECT BONUS
  // Collecter un bonus de parrainage
  Future<Map<String, dynamic>> collectBonus(int parrainageId) async {
    try {
      final url = Uri.parse(collectBonusUrl(parrainageId));
      final response = await http.post(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('Collect Bonus Status: ${response.statusCode}');
      print('Collect Bonus Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          'success': jsonData['success'] ?? true,
          'message': jsonData['message'] ?? 'Remboursement effectué avec succès',
          'montant': jsonData['montant'] ?? 0,
        };
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Erreur de remboursement');
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 403) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Accès refusé');
      } else if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Parrainage introuvable');
      } else {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Erreur lors du remboursement');
      }
    } catch (e) {
      print("Erreur collect bonus: $e");
      rethrow;
    }
  }
}
