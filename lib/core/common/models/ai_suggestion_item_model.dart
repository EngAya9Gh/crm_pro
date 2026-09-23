import 'package:crm_wakeel/core/common/entities/ai_suggestion_item.dart';

class AiSuggestionItemModel extends AiSuggestionItem {
  AiSuggestionItemModel({
    required super.id,
    required super.question,
    required super.prompt,
    required super.icon,
    super.action,
    super.threadId,
  });

  factory AiSuggestionItemModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionItemModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      prompt: json['prompt'] ?? '',
      icon: json['icon'] ?? '',
      action: json['action'],
      threadId: json['thread_id'],
    );
  }
}
