import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/api_constant.dart';

class ProfilePhotoService {
  String get _baseUrl => baseUrl.replaceAll('/api', '');
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  /// Met à jour la photo de profil de l'utilisateur
  ///
  /// [imageFile] Le fichier image à uploader
  /// [context] Le BuildContext pour gérer les erreurs d'authentification (optionnel)
  ///
  /// Retourne un Map contenant la réponse du serveur avec le message et l'URL de la nouvelle photo
  ///
  /// Lance une Exception en cas d'erreur
  Future<Map<String, dynamic>> updateProfilePhoto(
    File imageFile, {
    BuildContext? context,
  }) async {
    try {
      debugPrint('📤 [UPLOAD] Starting photo upload...');

      // 1. Récupérer et valider le token
      final token = await _sharedPreferencesService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [UPLOAD] Token not available');
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      }

      // 2. Construire l'URI de l'endpoint
      final uri = Uri.parse('$_baseUrl/user/photo-profil');
      debugPrint('📤 [UPLOAD] Upload URL: $uri');

      // 3. Créer une requête multipart
      final request = http.MultipartRequest('POST', uri);

      // 4. Nettoyer le token et ajouter les headers d'authentification
      final cleanToken = token.replaceAll('"', '').trim();
      request.headers.addAll({
        'Authorization': 'Bearer $cleanToken',
        'Accept': 'application/json',
      });
      debugPrint('📤 [UPLOAD] Headers added');

      // 5. Préparer le fichier image
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final filename = imageFile.path.split('/').last;
      debugPrint('📤 [UPLOAD] File: $filename, Size: $fileLength bytes (${(fileLength / 1024).toStringAsFixed(2)} KB)');

      // 6. Créer le MultipartFile
      final multipartFile = http.MultipartFile(
        'photo_profil', // IMPORTANT: Nom du champ attendu par l'API
        fileStream,
        fileLength,
        filename: filename,
      );
      request.files.add(multipartFile);
      debugPrint('📤 [UPLOAD] File added to request');

      // 7. Envoyer la requête avec timeout de 30 secondes
      debugPrint('📤 [UPLOAD] Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Le serveur met trop de temps à répondre');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📤 [UPLOAD] Response status: ${response.statusCode}');
      debugPrint('📤 [UPLOAD] Response body: ${response.body}');

      // 8. Traiter la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('✅ [UPLOAD] Upload successful!');
        debugPrint('📸 [UPLOAD] New photo URL: ${data['photo_url']}');
        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Session expirée - notification déjà gérée par le handler
        debugPrint('⚠️ [UPLOAD] Authentication error (${response.statusCode})');
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      } else if (response.statusCode == 422) {
        // Erreur de validation
        debugPrint('⚠️ [UPLOAD] Validation error (422)');
        final errors = json.decode(utf8.decode(response.bodyBytes));
        final errorMessages = errors['errors']?.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
        throw Exception(errorMessages ?? 'Fichier image invalide');
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('❌ [UPLOAD] Server error: ${data['message']}');
        throw Exception(data['message'] ?? 'Échec de la mise à jour de la photo de profil');
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ [UPLOAD] Timeout error: $e');
      throw Exception('Le serveur met trop de temps à répondre. Veuillez réessayer.');
    } on SocketException catch (e) {
      debugPrint('❌ [UPLOAD] Network error: $e');
      throw Exception('Erreur de connexion. Vérifiez votre connexion Internet.');
    } catch (e) {
      debugPrint('❌ [UPLOAD] Unexpected error: $e');
      if (e is Exception) rethrow;
      throw Exception('Une erreur est survenue lors de la mise à jour de votre photo de profil');
    }
  }

  /// Supprime la photo de profil de l'utilisateur
  ///
  /// Lance une Exception en cas d'erreur
  Future<void> deleteProfilePhoto() async {
    try {
      debugPrint('🗑️ [DELETE] Starting photo deletion...');

      // 1. Récupérer et valider le token
      final token = await _sharedPreferencesService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [DELETE] Token not available');
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      }

      // 2. Construire l'URI et nettoyer le token
      final uri = Uri.parse('$_baseUrl/user/photo-profil');
      final cleanToken = token.replaceAll('"', '').trim();
      debugPrint('🗑️ [DELETE] Delete URL: $uri');

      // 3. Envoyer la requête DELETE avec timeout
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $cleanToken',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Le serveur met trop de temps à répondre');
        },
      );

      debugPrint('🗑️ [DELETE] Response status: ${response.statusCode}');
      debugPrint('🗑️ [DELETE] Response body: ${response.body}');

      // 4. Traiter la réponse
      if (response.statusCode == 200) {
        debugPrint('✅ [DELETE] Photo deleted successfully');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('⚠️ [DELETE] Authentication error (${response.statusCode})');
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('❌ [DELETE] Server error: ${data['message']}');
        throw Exception(data['message'] ?? 'Erreur lors de la suppression de la photo');
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ [DELETE] Timeout error: $e');
      throw Exception('Le serveur met trop de temps à répondre. Veuillez réessayer.');
    } on SocketException catch (e) {
      debugPrint('❌ [DELETE] Network error: $e');
      throw Exception('Erreur de connexion. Vérifiez votre connexion Internet.');
    } catch (e) {
      debugPrint('❌ [DELETE] Unexpected error: $e');
      if (e is Exception) rethrow;
      throw Exception('Une erreur est survenue lors de la suppression de votre photo de profil');
    }
  }
}
