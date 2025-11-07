import 'package:dio/dio.dart';
import 'package:for_u_partners/app/models/notification_model.dart';

class NotificationService {
  final Dio _dio;
  
  NotificationService(this._dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      print('🔍 Récupération des notifications...');
      
      final response = await _dio.get('/api/conducteur/notifications');
      
      print('✅ Statut: ${response.statusCode}');
      print('✅ Données: ${response.data}');
      
      if (response.statusCode == 200) {
        // Vérifier la structure des données
        if (response.data is Map && response.data.containsKey('data')) {
          final List<dynamic> data = response.data['data'];
          return data.map((json) => NotificationModel.fromJson(json)).toList();
        } else if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => NotificationModel.fromJson(json)).toList();
        } else {
          throw Exception('Format de réponse inattendu');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response != null) {
        // Erreur avec réponse du serveur
        final statusCode = e.response!.statusCode;
        
        switch (statusCode) {
          case 400:
            throw Exception('Requête invalide');
          case 401:
            throw Exception('Non authentifié. Veuillez vous reconnecter.');
          case 403:
            throw Exception('Accès refusé');
          case 404:
            throw Exception('Endpoint non trouvé');
          case 500:
            // Essayer de récupérer le message d'erreur du serveur
            final errorMessage = e.response?.data?['message'] ?? 
                                 e.response?.data?['error'] ?? 
                                 'Erreur serveur interne';
            throw Exception('Erreur serveur: $errorMessage');
          default:
            throw Exception('Erreur serveur: $statusCode');
        }
      } else {
        // Erreur sans réponse (connexion, timeout, etc.)
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            throw Exception('Délai de connexion dépassé');
          case DioExceptionType.sendTimeout:
            throw Exception('Délai d\'envoi dépassé');
          case DioExceptionType.receiveTimeout:
            throw Exception('Délai de réception dépassé');
          case DioExceptionType.connectionError:
            throw Exception('Erreur de connexion réseau');
          default:
            throw Exception('Erreur: ${e.message}');
        }
      }
      
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.put('/api/conducteur/notifications/$notificationId/read');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Non authentifié');
      }
      throw Exception('Erreur: ${e.message}');
    }
  }
}