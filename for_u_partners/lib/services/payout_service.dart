import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/payout_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/app/api_constant.dart';

class PayoutService {
  final _authService = locator<AuthService>();

  /// Check if response contains authentication error and logout if necessary
  void _checkAuthenticationError(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      if (responseData is Map && responseData['error'] == 'Unauthenticated.') {
        debugPrint('⚠️ [PayoutService] Unauthenticated error detected - logging out user');
        _authService.logOut();
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
  }

  //* CREATE PAYOUT
  // Créer et lancer un payout (retrait) vers un destinataire via FedaPay
  Future<PayoutCreateResponse> createPayout({
    required int utilisateurId,
    required String password,
    required double amount,
    required String provider,
    required String recipientType,
  }) async {
    try {
      final url = Uri.parse(createPayoutUrl);
      final request = PayoutCreateRequest(
        utilisateurId: utilisateurId,
        password: password,
        amount: amount,
        provider: provider,
        recipientType: recipientType,
      );

      final response = await http.post(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📤 Create Payout Status: ${response.statusCode}');
      debugPrint('📤 Create Payout Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayoutCreateResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Requête invalide');
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur introuvable');
      } else if (response.statusCode == 422) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Erreur de validation');
      } else if (response.statusCode == 500) {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Erreur serveur / impossible de créer le payout');
      } else {
        throw Exception('Erreur lors de la création du payout');
      }
    } catch (e) {
      debugPrint("❌ Erreur create payout: $e");
      rethrow;
    }
  }

  //* LIST PAYOUTS
  // Liste des demandes de retrait du conducteur connecté
  Future<PayoutListResponse> listPayouts({
    int page = 1,
    int perPage = 20,
    String? status,
    bool live = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        'live': live.toString(),
      };

      final uri = Uri.parse(listPayoutsUrl).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      debugPrint('📋 List Payouts Status: ${response.statusCode}');
      debugPrint('📋 List Payouts Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayoutListResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        throw Exception('Erreur lors du chargement des payouts');
      }
    } catch (e) {
      debugPrint("❌ Erreur list payouts: $e");
      rethrow;
    }
  }

  //* GET PAYOUT DETAILS
  // Détail d'une demande de retrait
  Future<PayoutModel> getPayoutDetails({
    required int payoutId,
    bool live = false,
  }) async {
    try {
      final queryParams = {
        'live': live.toString(),
      };

      final uri = Uri.parse(payoutDetailsUrl(payoutId)).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      debugPrint('📄 Payout Details Status: ${response.statusCode}');
      debugPrint('📄 Payout Details Body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PayoutModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        throw Exception('Payout introuvable');
      } else {
        throw Exception('Erreur lors du chargement du payout');
      }
    } catch (e) {
      debugPrint("❌ Erreur get payout details: $e");
      rethrow;
    }
  }
}
