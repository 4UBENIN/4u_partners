import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/models/chat/chat_message_entity.dart';
import 'package:for_u_partners/models/chat/chat_message_model.dart';
import 'package:for_u_partners/models/chat/typing_status_entity.dart';
import 'package:for_u_partners/models/chat/typing_status_model.dart';
import 'package:for_u_partners/repositories/chat_repository.dart';
import 'package:for_u_partners/services/sharedpreferences_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRepositoryImpl implements ChatRepository {
  final http.Client _client = http.Client();
  final _sharedPreferencesService = locator<SharedpreferencesService>();

  ChatRepositoryImpl();

  String get _baseUrl => dotenv.env['API_ENDPOINT']!;

  Future<Map<String, String>> get _headers async {
    final token = await _sharedPreferencesService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/api/courses/$courseId/messages';

      final response = await _client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé à cette course');
      } else if (response.statusCode == 404) {
        throw Exception('Course introuvable');
      } else {
        throw Exception('Erreur lors de la récupération des messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<ChatMessageEntity> sendMessage(int courseId, String message) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/api/courses/$courseId/messages';

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ChatMessageModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        throw Exception('Chat non autorisé ou accès refusé');
      } else if (response.statusCode == 404) {
        throw Exception('Course introuvable');
      } else if (response.statusCode == 422) {
        throw Exception('Erreur de validation');
      } else {
        throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/api/courses/$courseId/messages/read';

      final response = await _client.post(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthenticated');
        } else if (response.statusCode == 403) {
          throw Exception('Accès refusé');
        } else if (response.statusCode == 404) {
          throw Exception('Course introuvable');
        } else {
          throw Exception('Erreur lors du marquage des messages: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<TypingStatusEntity> getTypingStatus(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/api/courses/$courseId/typing';

      final response = await _client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TypingStatusModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé à la discussion');
      } else if (response.statusCode == 404) {
        throw Exception('Course introuvable');
      } else {
        throw Exception('Erreur lors de la récupération du statut typing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<void> setTypingStatus(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/api/courses/$courseId/typing';

      final response = await _client.post(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthenticated');
        } else if (response.statusCode == 403) {
          throw Exception('Accès refusé ou discussion non autorisée');
        } else if (response.statusCode == 404) {
          throw Exception('Course introuvable');
        } else {
          throw Exception('Erreur lors de la mise à jour du statut typing: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
