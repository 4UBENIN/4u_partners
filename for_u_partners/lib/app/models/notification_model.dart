// models/notification_model.dart
class NotificationModel {
  final int id;
  final String titre;
  final String message;
  final String type;
  final String? image;
  final bool isRead;
  final String sentAt;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    this.image,
    this.isRead = false,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      image: json['image'],
      isRead: json['is_read'] ?? false,
      sentAt: json['sent_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'message': message,
      'type': type,
      'image': image,
      'is_read': isRead,
      'sent_at': sentAt,
    };
  }
}