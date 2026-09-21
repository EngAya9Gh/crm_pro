import 'package:crm_wakeel/core/common/entities/ai_session.dart';
import 'ai_message_model.dart';

class AiSessionModel extends AiSession {
  AiSessionModel({
    required super.id,
    required super.title,
    super.type,
    required super.createdAt,
    super.user,
    super.messages,
    super.answer,
  });

  factory AiSessionModel.fromJson(Map<String, dynamic> json) {
    return AiSessionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      user: json['user'],
      answer: json['answer'],
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((e) => AiMessageModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
