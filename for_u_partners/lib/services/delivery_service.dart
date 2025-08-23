import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/api_constant.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/ui/common/toast.dart';
import 'package:http/http.dart' as http;

class DeliveryService {
  final _authService = locator<AuthService>();

  /// Récupérer les demandes de livraison disponibles
  Future<Map<String, dynamic>> getAvailableDeliveries(BuildContext context) async {
    try {
      print('📦 Récupération des demandes de livraison...');

      final response = await http.get(
        Uri.parse('$baseUrl/conducteur/livraisons'),
        headers: await _authService.getAuthenticatedHeaders(),
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Demandes de livraison récupérées avec succès');
        return data;
      } else {
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          final errorMessage = errorData['error'] ?? response.body;
          
          CustomToast.showError(
            context,
            message: errorMessage.toString(),
          );
          throw Exception('Erreur API: ${response.statusCode} - $errorMessage');
        } catch (e) {
          // En cas d'erreur de parsing du JSON, afficher la réponse brute
          CustomToast.showError(
            context,
            message: response.body,
          );
          throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des livraisons: $e');
      rethrow;
    }
  }

  /// Accepter une demande de livraison
  Future<Map<String, dynamic>> acceptDelivery(int deliveryId) async {
    try {
      print('✅ Acceptation de la livraison $deliveryId...');

      final response = await http.patch(
        Uri.parse('$baseUrl/conducteur/livraisons/$deliveryId/accept'),
        headers: await _authService.getAuthenticatedHeaders(),
        body: json.encode({
          'delivery_id': deliveryId,
          'status': 'accepted',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Livraison acceptée avec succès');
        return data;
      } else {
        throw Exception(
            'Erreur lors de l\'acceptation: ${response.statusCode} ========================= ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur acceptation livraison: $e');
      rethrow;
    }
  }

  /// Refuser une demande de livraison
  Future<Map<String, dynamic>> rejectDelivery(int deliveryId) async {
    try {
      print('❌ Refus de la livraison $deliveryId...');

      final response = await http.patch(
        Uri.parse('$baseUrl/conducteur/livraisons/$deliveryId/deny'),
        headers: await _authService.getAuthenticatedHeaders(),
        body: json.encode({
          'delivery_id': deliveryId,
          'status': 'rejected',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Livraison refusée avec succès');
        return data;
      } else {
        throw Exception(
            'Erreur lors du refus: ${response.statusCode} ================== ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur refus livraison: $e');
      rethrow;
    }
  }

  /// Démarrer une livraison
  Future<Map<String, dynamic>> startDelivery(int deliveryId) async {
    try {
      print('🚚 Démarrage de la livraison $deliveryId...');

      final response = await http.patch(
        Uri.parse('$baseUrl/conducteur/livraisons/$deliveryId/start'),
        headers: await _authService.getAuthenticatedHeaders(),
        body: json.encode({
          'delivery_id': deliveryId,
          'status': 'in_progress',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Livraison démarrée avec succès');
        return data;
      } else {
        throw Exception(
            'Erreur lors du démarrage: ${response.statusCode} ==================== ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur démarrage livraison: $e');
      rethrow;
    }
  }

  /// Terminer une livraison
  Future<Map<String, dynamic>> completeDelivery(int deliveryId) async {
    try {
      print('✅ Finalisation de la livraison $deliveryId...');

      final response = await http.patch(
        Uri.parse('$baseUrl/conducteur/livraisons/$deliveryId/finish'),
        headers: await _authService.getAuthenticatedHeaders(),
        body: json.encode({
          'delivery_id': deliveryId,
          'status': 'completed',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Livraison terminée avec succès');
        return data;
      } else {
        throw Exception(
            'Erreur lors de la finalisation: ${response.statusCode} =============== ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur finalisation livraison: $e');
      rethrow;
    }
  }

  /// Annuler une livraison
  // Future<Map<String, dynamic>> cancelDelivery(int deliveryId, {String? reason}) async {
  //   try {
  //     print('🚫 Annulation de la livraison $deliveryId...');

  //     final response = await http.post(
  //       Uri.parse('$baseUrl/deliveries/$deliveryId/cancel'),
  //       headers: _headers,
  //       body: json.encode({
  //         'delivery_id': deliveryId,
  //         'status': 'cancelled',
  //         'reason': reason,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body) as Map<String, dynamic>;
  //       print('✅ Livraison annulée avec succès');
  //       return data;
  //     } else {
  //       throw Exception('Erreur lors de l\'annulation: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Erreur annulation livraison: $e');
  //     rethrow;
  //   }
  // }

  /// Mettre à jour la position du livreur
  // Future<void> updateDeliveryPosition(int deliveryId, double lat, double lng) async {
  //   try {
  //     await http.post(
  //       Uri.parse('$baseUrl/deliveries/$deliveryId/position'),
  //       headers: _headers,
  //       body: json.encode({
  //         'delivery_id': deliveryId,
  //         'latitude': lat,
  //         'longitude': lng,
  //         'timestamp': DateTime.now().toIso8601String(),
  //       }),
  //     );
  //   } catch (e) {
  //     print('❌ Erreur mise à jour position: $e');
  //     // Ne pas faire rethrow car ce n'est pas critique
  //   }
  // }
}
