// models/notification_model.dart
class NotificationModel {
  final String id;
  final String date;
  final String message;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.date,
    required this.message,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? json['created_at'] ?? '',
      message: json['message'] ?? json['text'] ?? json['content'] ?? '',
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'message': message,
      'is_read': isRead,
    };
  }
}