import '../../domain/entities/ai_message.dart';

class AiMessageModel extends AiMessage {
  AiMessageModel({
    required super.role,
    required super.content,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
