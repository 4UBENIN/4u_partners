// document_service.dart
import 'package:dio/dio.dart';
import 'package:for_u_partners/models/document_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/app/api_constant.dart';

class DocumentService {
  final Dio _dio = Dio();
  String get _baseUrl => baseUrl;
  
  final _sharedPreferencesServices = locator<SharedpreferencesService>();

  DocumentService() {
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

  Future<String?> _getAuthToken() async {
    try {
      final token = await _sharedPreferencesServices.getToken();

      if (token == null || token.isEmpty) {
        print('❌ Aucun token trouvé');
        return null;
      }

      final cleanToken = token.replaceAll('"', '').trim();
      
      if (cleanToken.isEmpty) {
        print('❌ Token vide après nettoyage');
        return null;
      }

      print('🔑 Token récupéré avec succès (${cleanToken.length} caractères)');
      return cleanToken;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }


  Future<void> debugCheckToken() async {
    try {
      final token = await _sharedPreferencesServices.getToken();
      
      print('═══════════════════════════════════');
      print('🔍 DEBUG TOKEN VERIFICATION (DOCUMENTS)');
      print('═══════════════════════════════════');
      print('Token présent: ${token != null}');
      print('Token non vide: ${token?.isNotEmpty ?? false}');
      if (token != null) {
        final cleanToken = token.replaceAll('"', '').trim();
        print('Token (premiers 20 char): ${cleanToken.length > 20 ? cleanToken.substring(0, 20) : cleanToken}...');
        print('Token length: ${cleanToken.length}');
      }
      print('═══════════════════════════════════');
    } catch (e) {
      print('❌ Erreur lors du debug du token: $e');
    }
  }

  // ✅ VERSION CORRIGÉE POUR TA STRUCTURE API
  Future<List<Document>> getUserDocuments(String userId) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ Impossible de récupérer les documents : utilisateur non authentifié.');
        return [];
      }

      final response = await _dio.get(
        '$_baseUrl/conducteur/documents',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('===== RESPONSE =====');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data.containsKey('conducteur')) {
          final conducteur = data['conducteur'];
          List<Document> documents = [];

          if (conducteur['document_identite'] != null) {
            documents.add(Document(
              type: 'Document d\'identité',
              category: 'Conducteur',
              fileUrl: conducteur['document_identite'],
              status: DocumentStatus.valide, // Document existant = valide
            ));
          }

          if (conducteur['permis_conduire'] != null) {
            final expirationDate = conducteur['date_expiration_permis'] != null 
                ? DateTime.tryParse(conducteur['date_expiration_permis'])
                : null;
            
            // Vérifier si le permis est expiré
            final isExpired = expirationDate != null && DateTime.now().isAfter(expirationDate);
            
            documents.add(Document(
              type: 'Permis de conduire',
              category: 'Conducteur',
              fileUrl: conducteur['permis_conduire'],
              expirationDate: expirationDate,
              status: isExpired ? DocumentStatus.expire : DocumentStatus.valide,
            ));
          }

          if (conducteur['vehicule'] != null) {
            final vehicule = conducteur['vehicule'];
            if (vehicule['carte_grise'] != null) {
              documents.add(Document(
                type: 'Carte grise',
                category: 'Véhicule',
                fileUrl: vehicule['carte_grise'],
                status: DocumentStatus.valide, // Document existant = valide
              ));
            }

            if (vehicule['assurance'] != null) {
              final expirationDate = vehicule['expiration_assurance'] != null
                  ? DateTime.tryParse(vehicule['expiration_assurance'])
                  : null;
              
              // Vérifier si l'assurance est expirée
              final isExpired = expirationDate != null && DateTime.now().isAfter(expirationDate);
              
              documents.add(Document(
                type: 'Assurance',
                category: 'Véhicule',
                fileUrl: vehicule['assurance'],
                expirationDate: expirationDate,
                status: isExpired ? DocumentStatus.expire : DocumentStatus.valide,
              ));
            }
          }

          print('✅ ${documents.length} documents trouvés');
          return documents;
        } else {
          throw Exception('Format de réponse inattendu');
        }
      }

      throw Exception('Erreur ${response.statusCode}');
    } catch (e, stack) {
      print('Erreur lors de la récupération des documents: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return [];
    }
  }

  Future<Document?> getDocument(String documentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }
      
      final response = await _dio.get(
        '$_baseUrl/conducteur/documents/$documentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
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

  Future<bool> addDocument({
    required String userId,
    required String type,
    required String category,
    required File file,
    DateTime? expirationDate,
  }) async {
    try {
      await debugCheckToken();
      
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      }
      
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

      FormData formData = FormData.fromMap({
        'userId': userId,
        'type': type,
        'category': category,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String().split('T')[0],
      });

      print('📤 Envoi de la requête pour ajouter le document...');

      final response = await _dio
          .post(
            '$_baseUrl/conducteur/documents',
            data: formData,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      print('Réponse status: ${response.statusCode}');
      print('Réponse data: ${response.data}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Document ajouté avec succès');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      print('❌ Erreur lors de l\'ajout du document: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return false;
    }
  }

  Future<bool> updateDocument({
    required String documentId,
    File? newFile,
    DateTime? expirationDate,
    String? status,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }
      
      FormData formData = FormData.fromMap({
        if (newFile != null)
          'file': await MultipartFile.fromFile(
            newFile.path,
            filename: newFile.path.split('/').last,
          ),
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String().split('T')[0],
        if (status != null) 'status': status,
      });

      print('📤 Mise à jour du document $documentId...');

      final response = await _dio.put(
        '$_baseUrl/conducteur/documents/$documentId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Document mis à jour avec succès');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      print('❌ Erreur lors de la mise à jour du document: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }
      
      print('📤 Suppression du document $documentId...');

      final response = await _dio.delete(
        '$_baseUrl/conducteur/documents/$documentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Document supprimé avec succès');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      print('❌ Erreur lors de la suppression du document: $e');
      if (e is DioException) {
        print('Détails de l\'erreur Dio: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
      }
      print(stack);
      return false;
    }
  }

  Future<bool> downloadDocument(Document doc) async {
    try {
      if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
        return false;
      }

      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Utilisateur non authentifié.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${doc.fileName ?? 'document.pdf'}';

      await _dio.download(
        doc.fileUrl!,
        filePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Document téléchargé avec succès: $filePath');
      return true;
    } catch (e) {
      print('❌ Erreur lors du téléchargement: $e');
      return false;
    }
  }

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
