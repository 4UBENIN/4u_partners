import 'dart:convert';
import 'dart:io';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:http/http.dart' as http;

class ProfilePhotoService {
  final String baseUrl = 'https://foryou.cilassocies.com';
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  Future<Map<String, dynamic>> updateProfilePhoto(File imageFile) async {
    try {
      final token = await _sharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('Token non disponible');
      }

      final uri = Uri.parse('$baseUrl/user/photo-profil');
      final request = http.MultipartRequest('POST', uri);

      // Ajouter les headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Ajouter le fichier image
      final multipartFile = await http.MultipartFile.fromPath(
        'photo_profil',
        imageFile.path,
      );
      request.files.add(multipartFile);

      print('📤 Envoi de la photo de profil...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Photo de profil mise à jour avec succès');
        print('📸 Nouvelle URL de la photo: ${data['photo_url']}');
        return data;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Erreur lors de la mise à jour de la photo');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la photo: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteProfilePhoto() async {
    try {
      final token = await _sharedPreferencesService.getToken();
      if (token == null) {
        throw Exception('Token non disponible');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/user/photo-profil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Statut de la réponse: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Photo de profil supprimée avec succès');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Erreur lors de la suppression de la photo');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression de la photo: $e');
      throw Exception('Erreur: $e');
    }
  }
}
