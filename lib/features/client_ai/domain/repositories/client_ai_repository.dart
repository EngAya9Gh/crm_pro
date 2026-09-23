import '../../domain/entities/ai_insights.dart';
import 'package:crm_wakeel/core/common/entities/ai_session.dart';
import 'package:crm_wakeel/core/common/entities/ai_suggestions.dart';

abstract class ClientAiRepository {
  Future<AiInsights> getInsights(String clientId);
  Future<AiSession> askQuestion(String clientId, String question, {String? type, int? sessionId});
  Future<List<AiSession>> getHistory(String clientId);
  Future<AiSession> getSession(String clientId, int sessionId);
  Future<AiSuggestions> getSuggestions([String? clientId]);
  Future<AiSession> summarizeWhatsappChat(String clientId, String threadId, {int? sessionId});
}
