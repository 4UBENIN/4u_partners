import 'typing_status_entity.dart';

class TypingStatusModel extends TypingStatusEntity {
  TypingStatusModel({
    required super.isTyping,
  });

  factory TypingStatusModel.fromJson(Map<String, dynamic> json) {
    return TypingStatusModel(
      isTyping: json['is_typing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_typing': isTyping,
    };
  }
}
