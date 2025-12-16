import 'dart:async';
import 'package:for_u_partners/app/app.locator.dart';
import 'package:for_u_partners/models/chat/chat_message_entity.dart';
import 'package:for_u_partners/models/chat/typing_status_entity.dart';
import 'package:for_u_partners/repositories/chat_repository.dart';

class ChatServiceApi {
  final ChatRepository _chatRepository = locator<ChatRepository>();
  Timer? _messagesPollingTimer;
  Timer? _typingPollingTimer;
  int? _currentCourseId;

  final StreamController<List<ChatMessageEntity>> _messagesController =
      StreamController<List<ChatMessageEntity>>.broadcast();

  final StreamController<TypingStatusEntity> _typingController =
      StreamController<TypingStatusEntity>.broadcast();

  ChatServiceApi();

  // Stream for listening to messages (with polling)
  Stream<List<ChatMessageEntity>> getMessagesStream(int courseId) {
    _currentCourseId = courseId;
    _startMessagesPolling(courseId);
    return _messagesController.stream;
  }

  // Stream for listening to typing status (with polling)
  Stream<TypingStatusEntity> getTypingStatusStream(int courseId) {
    _startTypingPolling(courseId);
    return _typingController.stream;
  }

  // Start polling messages every 10 seconds (reduced to avoid rate limits)
  void _startMessagesPolling(int courseId) {
    _messagesPollingTimer?.cancel();
    _fetchMessages(courseId);

    _messagesPollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchMessages(courseId),
    );
  }

  // Start polling typing status every 10 seconds (reduced to avoid rate limits)
  void _startTypingPolling(int courseId) {
    _typingPollingTimer?.cancel();
    _fetchTypingStatus(courseId);

    _typingPollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchTypingStatus(courseId),
    );
  }

  Future<void> _fetchMessages(int courseId) async {
    try {
      final messages = await _chatRepository.getMessages(courseId);
      _messagesController.add(messages);
    } catch (e) {
      print('❌ [CHAT_SERVICE_API] Error fetching messages: $e');
      _messagesController.addError(e);
    }
  }

  Future<void> _fetchTypingStatus(int courseId) async {
    try {
      final typingStatus = await _chatRepository.getTypingStatus(courseId);
      _typingController.add(typingStatus);
    } catch (e) {
      print('❌ [CHAT_SERVICE_API] Error fetching typing status: $e');
      _typingController.addError(e);
    }
  }

  // Send a message
  Future<ChatMessageEntity> sendMessage(int courseId, String message) async {
    try {
      final sentMessage = await _chatRepository.sendMessage(courseId, message);
      // Immediately fetch messages to update the UI
      await _fetchMessages(courseId);
      return sentMessage;
    } catch (e) {
      print('❌ [CHAT_SERVICE_API] Error sending message: $e');
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(int courseId) async {
    try {
      await _chatRepository.markMessagesAsRead(courseId);
    } catch (e) {
      print('❌ [CHAT_SERVICE_API] Error marking messages as read: $e');
      rethrow;
    }
  }

  // Set typing status
  Future<void> setTypingStatus(int courseId) async {
    try {
      await _chatRepository.setTypingStatus(courseId);
    } catch (e) {
      print('❌ [CHAT_SERVICE_API] Error setting typing status: $e');
      rethrow;
    }
  }

  // Stop polling for messages
  void stopMessagesPolling() {
    _messagesPollingTimer?.cancel();
    _messagesPollingTimer = null;
  }

  // Stop polling for typing status
  void stopTypingPolling() {
    _typingPollingTimer?.cancel();
    _typingPollingTimer = null;
  }

  // Dispose and cleanup
  void dispose() {
    print('🔄 [CHAT_SERVICE_API] Disposing chat service');
    _messagesPollingTimer?.cancel();
    _typingPollingTimer?.cancel();
    _messagesController.close();
    _typingController.close();
  }
}
