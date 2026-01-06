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
      debugPrint('💰 [PayoutService] Creating payout - User ID: $utilisateurId, Amount: $amount FCFA, Provider: $provider');

      final url = Uri.parse(createPayoutUrl);
      final request = PayoutCreateRequest(
        utilisateurId: utilisateurId,
        password: password,
        amount: amount,
        provider: provider,
        recipientType: recipientType,
      );

      final payload = request.toJson();
      // Log payload without password for security
      final safePayload = Map<String, dynamic>.from(payload);
      safePayload['password'] = '***';
      debugPrint('💰 [PayoutService] Request payload: ${jsonEncode(safePayload)}');

      final response = await http.post(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('💰 [PayoutService] Response status: ${response.statusCode}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ [PayoutService] Payout created successfully');
        return PayoutCreateResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Requête invalide';
        debugPrint('❌ [PayoutService] Bad request (400): $errorMsg');
        throw Exception(errorMsg);
      } else if (response.statusCode == 401) {
        debugPrint('⚠️ [PayoutService] Unauthorized (401) - Session expired, logging out');
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Utilisateur introuvable';
        debugPrint('❌ [PayoutService] Not found (404): $errorMsg - User ID: $utilisateurId');
        throw Exception(errorMsg);
      } else if (response.statusCode == 422) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Erreur de validation';
        debugPrint('❌ [PayoutService] Validation error (422): $errorMsg');
        throw Exception(errorMsg);
      } else if (response.statusCode == 500) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Erreur serveur / impossible de créer le payout';
        debugPrint('❌ [PayoutService] Server error (500): $errorMsg');
        throw Exception(errorMsg);
      } else {
        debugPrint('❌ [PayoutService] Unexpected error (${response.statusCode}): ${response.body}');
        throw Exception('Erreur lors de la création du payout');
      }
    } catch (e) {
      debugPrint('❌ [PayoutService] Failed to create payout: $e');
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
      debugPrint('📋 [PayoutService] Fetching payouts list - Page: $page, PerPage: $perPage${status != null ? ', Status: $status' : ''}');

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

      debugPrint('📋 [PayoutService] Response status: ${response.statusCode}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = PayoutListResponse.fromJson(jsonData);
        debugPrint('✅ [PayoutService] Successfully fetched ${result.data.length} payouts');
        return result;
      } else if (response.statusCode == 401) {
        debugPrint('⚠️ [PayoutService] Unauthorized (401) - Session expired, logging out');
        await _authService.logOut();
        throw Exception('Session expirée');
      } else {
        debugPrint('❌ [PayoutService] Unexpected error (${response.statusCode}): ${response.body}');
        throw Exception('Erreur lors du chargement des payouts');
      }
    } catch (e) {
      debugPrint('❌ [PayoutService] Failed to fetch payouts list: $e');
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
      debugPrint('📄 [PayoutService] Fetching payout details - Payout ID: $payoutId');

      final queryParams = {
        'live': live.toString(),
      };

      final uri = Uri.parse(payoutDetailsUrl(payoutId)).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      debugPrint('📄 [PayoutService] Response status: ${response.statusCode}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('✅ [PayoutService] Successfully fetched payout details');
        return PayoutModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        debugPrint('⚠️ [PayoutService] Unauthorized (401) - Session expired, logging out');
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 404) {
        debugPrint('❌ [PayoutService] Not found (404) - Payout ID: $payoutId');
        throw Exception('Payout introuvable');
      } else {
        debugPrint('❌ [PayoutService] Unexpected error (${response.statusCode}): ${response.body}');
        throw Exception('Erreur lors du chargement du payout');
      }
    } catch (e) {
      debugPrint('❌ [PayoutService] Failed to fetch payout details: $e');
      rethrow;
    }
  }
}
