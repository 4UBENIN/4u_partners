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
    print('🔍 [ChatMessageModel] Parsing JSON: $json');

    return ChatMessageModel(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['course_id']),
      senderId: _parseInt(json['sender_id']),
      senderType: json['sender_type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: _parseBool(json['is_read']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper method to safely parse integer values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method to safely parse boolean values
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
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
