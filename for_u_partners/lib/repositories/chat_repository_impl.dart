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
      final url = '$_baseUrl/courses/$courseId/messages';

      print('📡 [GET_MESSAGES] Calling endpoint: $url');
      print('📡 [GET_MESSAGES] Headers: ${headers.keys.join(", ")}');

      final response = await _client.get(Uri.parse(url), headers: headers);

      print('📡 [GET_MESSAGES] Response status: ${response.statusCode}');
      print('📡 [GET_MESSAGES] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('✅ [GET_MESSAGES] Retrieved ${jsonList.length} messages');
        return jsonList.map((json) => ChatMessageModel.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        print('⚠️ [GET_MESSAGES] Rate limited - returning empty list');
        // Return empty list when rate limited instead of throwing error
        return [];
      } else if (response.statusCode == 401) {
        print('❌ [GET_MESSAGES] Unauthenticated');
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        print('❌ [GET_MESSAGES] Access denied');
        throw Exception('Accès refusé à cette course');
      } else if (response.statusCode == 404) {
        print('❌ [GET_MESSAGES] Course not found');
        throw Exception('Course introuvable');
      } else {
        print('❌ [GET_MESSAGES] Unexpected status: ${response.statusCode}');
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ [GET_MESSAGES] Exception: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<ChatMessageEntity> sendMessage(int courseId, String message) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/courses/$courseId/messages';
      final payload = {'message': message};

      print('📡 [SEND_MESSAGE] Calling endpoint: $url');
      print('📡 [SEND_MESSAGE] Headers: ${headers.keys.join(", ")}');
      print('📡 [SEND_MESSAGE] Payload: ${json.encode(payload)}');

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(payload),
      );

      print('📡 [SEND_MESSAGE] Response status: ${response.statusCode}');
      print('📡 [SEND_MESSAGE] Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ [SEND_MESSAGE] Message sent successfully');
        try {
          final jsonResponse = json.decode(response.body);
          print('📦 [SEND_MESSAGE] Parsed JSON: $jsonResponse');
          final messageModel = ChatMessageModel.fromJson(jsonResponse);
          print('✅ [SEND_MESSAGE] Message model created: ${messageModel.id}');
          return messageModel;
        } catch (parseError) {
          print('❌ [SEND_MESSAGE] Parse error: $parseError');
          print('📦 [SEND_MESSAGE] Raw response: ${response.body}');
          rethrow;
        }
      } else if (response.statusCode == 401) {
        print('❌ [SEND_MESSAGE] Unauthenticated');
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        print('❌ [SEND_MESSAGE] Access denied');
        throw Exception('Chat non autorisé ou accès refusé');
      } else if (response.statusCode == 404) {
        print('❌ [SEND_MESSAGE] Course not found');
        throw Exception('Course introuvable');
      } else if (response.statusCode == 422) {
        print('❌ [SEND_MESSAGE] Validation error');
        throw Exception('Erreur de validation');
      } else {
        print('❌ [SEND_MESSAGE] Error: ${response.statusCode}');
        throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [SEND_MESSAGE] Exception: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/courses/$courseId/messages/read';

      print('📡 [MARK_READ] Calling endpoint: $url');
      print('📡 [MARK_READ] Headers: ${headers.keys.join(", ")}');

      final response = await _client.post(Uri.parse(url), headers: headers);

      print('📡 [MARK_READ] Response status: ${response.statusCode}');
      print('📡 [MARK_READ] Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [MARK_READ] Messages marked as read');
      } else if (response.statusCode == 429) {
        print('⚠️ [MARK_READ] Rate limited - silently ignoring');
        // Silently ignore rate limit errors
        return;
      } else if (response.statusCode == 401) {
        print('❌ [MARK_READ] Unauthenticated');
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        print('❌ [MARK_READ] Access denied');
        throw Exception('Accès refusé');
      } else if (response.statusCode == 404) {
        print('❌ [MARK_READ] Course not found');
        throw Exception('Course introuvable');
      } else {
        print('❌ [MARK_READ] Error: ${response.statusCode}');
        throw Exception('Erreur lors du marquage des messages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [MARK_READ] Exception: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<TypingStatusEntity> getTypingStatus(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/courses/$courseId/typing';

      print('📡 [GET_TYPING] Calling endpoint: $url');
      print('📡 [GET_TYPING] Headers: ${headers.keys.join(", ")}');

      final response = await _client.get(Uri.parse(url), headers: headers);

      print('📡 [GET_TYPING] Response status: ${response.statusCode}');
      print('📡 [GET_TYPING] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ [GET_TYPING] Typing status: ${jsonResponse['is_typing']}');
        return TypingStatusModel.fromJson(jsonResponse);
      } else if (response.statusCode == 429) {
        print('⚠️ [GET_TYPING] Rate limited - returning false');
        // Return false when rate limited instead of throwing error
        return TypingStatusModel(isTyping: false);
      } else if (response.statusCode == 401) {
        print('❌ [GET_TYPING] Unauthenticated');
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        print('❌ [GET_TYPING] Access denied');
        throw Exception('Accès refusé à la discussion');
      } else if (response.statusCode == 404) {
        print('❌ [GET_TYPING] Course not found');
        throw Exception('Course introuvable');
      } else {
        print('❌ [GET_TYPING] Error: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération du statut typing: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [GET_TYPING] Exception: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  @override
  Future<void> setTypingStatus(int courseId) async {
    try {
      final headers = await _headers;
      final url = '$_baseUrl/courses/$courseId/typing';

      print('📡 [SET_TYPING] Calling endpoint: $url');
      print('📡 [SET_TYPING] Headers: ${headers.keys.join(", ")}');

      final response = await _client.post(Uri.parse(url), headers: headers);

      print('📡 [SET_TYPING] Response status: ${response.statusCode}');
      print('📡 [SET_TYPING] Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [SET_TYPING] Typing status set');
      } else if (response.statusCode == 429) {
        print('⚠️ [SET_TYPING] Rate limited - silently ignoring');
        // Silently ignore rate limit errors for typing status
        return;
      } else if (response.statusCode == 401) {
        print('❌ [SET_TYPING] Unauthenticated');
        throw Exception('Unauthenticated');
      } else if (response.statusCode == 403) {
        print('❌ [SET_TYPING] Access denied');
        throw Exception('Accès refusé ou discussion non autorisée');
      } else if (response.statusCode == 404) {
        print('❌ [SET_TYPING] Course not found');
        throw Exception('Course introuvable');
      } else {
        print('❌ [SET_TYPING] Error: ${response.statusCode}');
        throw Exception('Erreur lors de la mise à jour du statut typing: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [SET_TYPING] Exception: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
}
