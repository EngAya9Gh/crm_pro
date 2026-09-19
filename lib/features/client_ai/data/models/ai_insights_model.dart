import '../../domain/entities/ai_insights.dart';

class AiInsightsModel extends AiInsights {
  AiInsightsModel({
    required super.leadScore,
    required super.reason,
    required super.summary,
    required super.warning,
  });

  factory AiInsightsModel.fromJson(Map<String, dynamic> json) {
    return AiInsightsModel(
      leadScore: json['lead_score'] ?? 0,
      reason: json['reason'] ?? '',
      summary: json['summary'] ?? '',
      warning: json['warning'] ?? '',
    );
  }
}
