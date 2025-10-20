// document_service.dart
import 'package:dio/dio.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://foryou.cilassocies.com/api';

  DocumentService() {
    // Ajouter un interceptor pour logger les requêtes et réponses
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('===== REQUEST =====');
          print('URL: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('===== RESPONSE =====');
          print('Status: ${response.statusCode}');
          print('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('===== ERROR =====');
          print('Status: ${error.response?.statusCode}');
          print('Response: ${error.response?.data}');
          print('Message: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // Récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Récupérer tous les documents
  Future<List<Document>> getUserDocuments(String userId) async {
    try {
      final token = await _getAuthToken();
      
      final response = await _dio.get(
        '$_baseUrl/conducteur/documents',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData.containsKey('conducteur')) {
          final conducteur = responseData['conducteur'];
          if (conducteur is List) {
            return List<Document>.from(
              conducteur.map((doc) => Document.fromJson(doc)),
            );
          }
        } else if (responseData is List) {
          return List<Document>.from(
            responseData.map((doc) => Document.fromJson(doc)),
          );
        } else if (responseData is Map && responseData.containsKey('data')) {
          List<dynamic> data = responseData['data'];
          return List<Document>.from(
            data.map((doc) => Document.fromJson(doc)),
          );
        }
        
        throw Exception('Format de réponse inattendu');
      }
      throw Exception('Erreur ${response.statusCode}');
    } catch (e) {
      print('Erreur lors de la récupération des documents: $e');
      throw Exception('Impossible de récupérer les documents: $e');
    }
  }

  // Récupérer un document spécifique
  Future<Document?> getDocument(String documentId) async {
    try {
      final token = await _getAuthToken();
      
      final response = await _dio.get(
        '$_baseUrl/conducteur/documents/$documentId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(response.data['data'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du document: $e');
      return null;
    }
  }

  // Ajouter un nouveau document
  Future<bool> addDocument({
    required String userId,
    required String type,
    required String category,
    required File file,
    DateTime? expirationDate,
  }) async {
    try {
      final token = await _getAuthToken();
      
      // Vérifier que le fichier existe
      if (!file.existsSync()) {
        print('Erreur: Le fichier n\'existe pas');
        return false;
      }

      print('=== AJOUT DOCUMENT ===');
      print('Fichier: ${file.path}');
      print('Taille: ${await file.length() / 1024 / 1024}MB');
      print('Type: $type');
      print('Catégorie: $category');
      print('UserId: $userId');
      print('Date expiration: ${expirationDate?.toIso8601String()}');

      // Créer FormData avec les champs
      FormData formData = FormData.fromMap({
        'userId': userId,
        'type': type,
        'category': category,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String(),
      });

      final response = await _dio.post(
        '$_baseUrl/conducteur/documents',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            // Ne pas définir Content-Type, Dio le fera automatiquement pour FormData
          },
        ),
      );

      print('Réponse status: ${response.statusCode}');
      print('Réponse data: ${response.data}');
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de l\'ajout du document: $e');
      return false;
    }
  }

  // Mettre à jour un document
  Future<bool> updateDocument({
    required String documentId,
    File? newFile,
    DateTime? expirationDate,
    String? status,
  }) async {
    try {
      final token = await _getAuthToken();
      
      FormData formData = FormData.fromMap({
        if (newFile != null)
          'file': await MultipartFile.fromFile(
            newFile.path,
            filename: newFile.path.split('/').last,
          ),
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String(),
        if (status != null) 'status': status,
      });

      final response = await _dio.put(
        '$_baseUrl/conducteur/documents/$documentId',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la mise à jour du document: $e');
      return false;
    }
  }

  // Supprimer un document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final token = await _getAuthToken();
      
      final response = await _dio.delete(
        '$_baseUrl/conducteur/documents/$documentId',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la suppression du document: $e');
      return false;
    }
  }

  // Télécharger un document
  Future<bool> downloadDocument(Document doc) async {
    try {
      if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
        return false;
      }

      final token = await _getAuthToken();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${doc.fileName ?? 'document.pdf'}';

      await _dio.download(
        doc.fileUrl!,
        filePath,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return true;
    } catch (e) {
      print('Erreur lors du téléchargement: $e');
      return false;
    }
  }

  // Stream pour écouter les changements
  Stream<List<Document>> getUserDocumentsStream(String userId) async* {
    while (true) {
      try {
        final documents = await getUserDocuments(userId);
        yield documents;
        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        print('Erreur dans le stream: $e');
        yield [];
      }
    }
  }
}