import 'dart:io';
import 'package:dio/dio.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  final Dio _dio = Dio();
  final SharedpreferencesService _prefs = SharedpreferencesService();
  final String _baseUrl = 'https://foryou.cilassocies.com/api'; // 🔹 Ton URL backend

  /// 🔹 1. Upload d’un document (fichier image ou PDF)
  Future<String> uploadDocument(XFile file) async {
    try {
      final String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final token = await _prefs.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.post(
        '$_baseUrl/conducteur/documents',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final fileUrl = response.data?['file_url']?.toString();
        if (fileUrl == null || fileUrl.isEmpty) {
          throw Exception('URL du document manquante dans la réponse du serveur');
        }
        return fileUrl;
      } else {
        throw Exception('Échec du téléchargement du fichier: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur uploadDocument: $e');
      throw Exception('Erreur lors du téléchargement du document: ${e.toString()}');
    }
  }

  /// 🔹 2. Création d’un document (après upload)
  Future<Document> createDocument({
    required String type,
    required String fileUrl,
    required DateTime expirationDate,
  }) async {
    try {
      final token = await _prefs.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.post(
        '$_baseUrl/conducteur/documents',
        data: {
          'document': {
            'type': type,
            'file_url': fileUrl,
            'expiration_date': expirationDate.toIso8601String(),
          }
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Document.fromJson(response.data['document'] ?? response.data);
      } else {
        throw Exception('Échec de la création du document');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du document: ${e.toString()}');
    }
  }

  /// 🔹 3. Récupération de tous les documents du conducteur
  Future<List<Document>> getDriverDocuments() async {
    try {
      final token = await _prefs.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.get(
        '$_baseUrl/conducteur/documents', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500, 
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List).map((doc) => Document.fromJson(doc)).toList();
        } else if (response.data['data'] != null) {
          return (response.data['data'] as List).map((doc) => Document.fromJson(doc)).toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 404) {
        
        return [];
      } else {
        throw Exception('Échec du chargement des documents: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
       
        return [];
      }
      throw Exception('Erreur lors de la récupération des documents: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// 🔹 4. Suppression d’un document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final token = await _prefs.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await _dio.delete(
        '$_baseUrl/conducteur/documents/$documentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la suppression du document: ${e.toString()}');
      return false;
    }
  }

  /// 🔹 5. Téléchargement d’un document sur le téléphone (pour affichage ou stockage local)
  Future<bool> downloadDocument(Document doc) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/${doc.type.toLowerCase().replaceAll(' ', '_')}.pdf";

      await _dio.download(doc.fileUrl, filePath);
      print("✅ Document téléchargé à : $filePath");
      return true;
    } catch (e) {
      print("❌ Erreur lors du téléchargement du document : $e");
      return false;
    }
  }

  /// 🔹 6. Mise à jour d’un document expiré ou rejeté
  Future<bool> updateDocument({
    required String documentId,
    required XFile newFile,
    required DateTime newExpirationDate,
  }) async {
    try {
      final token = await _prefs.getToken();
      if (token == null) throw Exception('Non authentifié');

      final fileName = newFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(newFile.path, filename: fileName),
        'expiration_date': newExpirationDate.toIso8601String(),
      });

      final response = await _dio.post(
        '$_baseUrl/conducteur/documents/$documentId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erreur updateDocument: $e");
      return false;
    }
  }
}
