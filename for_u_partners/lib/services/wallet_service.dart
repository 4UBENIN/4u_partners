import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/wallet_model.dart';
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
        // Vérifier si la réponse contient 'balance' ou 'solde'
        if (jsonData['balance'] == null && jsonData['solde'] != null) {
          // Si 'balance' n'existe pas mais 'solde' existe, créer un nouvel objet avec 'balance'
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
}
