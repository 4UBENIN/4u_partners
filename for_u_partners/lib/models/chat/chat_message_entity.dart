class ChatMessageEntity {
  final int id;
  final int courseId;
  final int senderId;
  final String senderType; // "client" or "conducteur"
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessageEntity({
    required this.id,
    required this.courseId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFromClient => senderType == 'client';
  bool get isFromDriver => senderType == 'conducteur';
}
