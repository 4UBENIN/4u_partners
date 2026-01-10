import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/models/rating_model.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/auth_service.dart';
import 'package:for_u_partners/app/api_constant.dart';

class RatingService {
  final _authService = locator<AuthService>();

  /// Check if response contains authentication error and logout if necessary
  void _checkAuthenticationError(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      if (responseData is Map && responseData['error'] == 'Unauthenticated.') {
        debugPrint('⚠️ [RatingService] Unauthenticated error detected - logging out user');
        _authService.logOut();
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }
  }

  /// Create a rating for a client after completing a ride
  ///
  /// [serviceId] - Service type (3 for course/ride)
  /// [serviceObjectId] - The course ID
  /// [note] - Rating from 1 to 5
  /// [commentaire] - Optional comment about the client
  Future<RatingModel> createRating({
    required int serviceId,
    required int serviceObjectId,
    required int note,
    String? commentaire,
  }) async {
    try {
      debugPrint('⭐ [RatingService] Creating rating - Course ID: $serviceObjectId, Note: $note');

      final url = Uri.parse(createRatingUrl);
      final payload = {
        'service_id': serviceId,
        'service_object_id': serviceObjectId,
        'note': note,
        if (commentaire != null && commentaire.isNotEmpty) 'commentaire': commentaire,
      };

      debugPrint('⭐ [RatingService] Request payload: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
        body: jsonEncode(payload),
      );

      debugPrint('⭐ [RatingService] Response status: ${response.statusCode}');
      debugPrint('⭐ [RatingService] Response body: ${response.body}');

      // Check for authentication errors
      _checkAuthenticationError(response);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        final avisData = jsonData['avis'] ?? jsonData;
        debugPrint('✅ [RatingService] Rating created successfully');
        return RatingModel.fromJson(avisData);
      } else if (response.statusCode == 401) {
        debugPrint('⚠️ [RatingService] Unauthorized (401) - Session expired, logging out');
        await _authService.logOut();
        throw Exception('Session expirée');
      } else if (response.statusCode == 403) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Accès refusé - Vous n\'êtes pas lié à cette course';
        debugPrint('❌ [RatingService] Forbidden (403): $errorMsg');
        throw Exception(errorMsg);
      } else if (response.statusCode == 422) {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Données invalides';
        debugPrint('❌ [RatingService] Validation error (422): $errorMsg');
        throw Exception(errorMsg);
      } else {
        final jsonData = jsonDecode(response.body);
        final errorMsg = jsonData['message'] ?? 'Une erreur est survenue';
        debugPrint('❌ [RatingService] Error (${response.statusCode}): $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ [RatingService] Exception while creating rating: $e');
      rethrow;
    }
  }

  /// Get list of ratings created by the driver
  Future<List<RatingModel>> getMyRatings() async {
    try {
      debugPrint('⭐ [RatingService] Fetching my ratings');

      final url = Uri.parse(myRatingsUrl);
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      debugPrint('⭐ [RatingService] Response status: ${response.statusCode}');

      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> ratingsJson = jsonData['data'] ?? [];
        debugPrint('✅ [RatingService] Fetched ${ratingsJson.length} ratings');
        return ratingsJson.map((json) => RatingModel.fromJson(json)).toList();
      } else {
        throw Exception('Impossible de récupérer les avis');
      }
    } catch (e) {
      debugPrint('❌ [RatingService] Exception while fetching ratings: $e');
      rethrow;
    }
  }

  /// Get list of ratings received by the driver
  Future<List<RatingModel>> getReceivedRatings() async {
    try {
      debugPrint('⭐ [RatingService] Fetching received ratings');

      final url = Uri.parse(receivedRatingsUrl);
      final response = await http.get(
        url,
        headers: await _authService.getAuthenticatedHeaders(),
      );

      debugPrint('⭐ [RatingService] Response status: ${response.statusCode}');

      _checkAuthenticationError(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> ratingsJson = jsonData['data'] ?? [];
        debugPrint('✅ [RatingService] Fetched ${ratingsJson.length} received ratings');
        return ratingsJson.map((json) => RatingModel.fromJson(json)).toList();
      } else {
        throw Exception('Impossible de récupérer les avis reçus');
      }
    } catch (e) {
      debugPrint('❌ [RatingService] Exception while fetching received ratings: $e');
      rethrow;
    }
  }
}
