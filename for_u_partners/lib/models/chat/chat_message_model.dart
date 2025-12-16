import 'chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.id,
    required super.courseId,
    required super.senderId,
    required super.senderType,
    required super.message,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      senderId: json['sender_id'] as int,
      senderType: json['sender_type'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'sender_id': senderId,
      'sender_type': senderType,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
