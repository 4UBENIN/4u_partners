import 'package:for_u_partners/models/chat/chat_message_entity.dart';
import 'package:for_u_partners/models/chat/typing_status_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(int courseId);
  Future<ChatMessageEntity> sendMessage(int courseId, String message);
  Future<void> markMessagesAsRead(int courseId);
  Future<TypingStatusEntity> getTypingStatus(int courseId);
  Future<void> setTypingStatus(int courseId);
}
