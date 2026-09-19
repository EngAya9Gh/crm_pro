import '../../domain/entities/ai_insights.dart';
import '../../domain/entities/ai_session.dart';

abstract class ClientAiRepository {
  Future<AiInsights> getInsights(String clientId);
  Future<AiSession> askQuestion(String clientId, String question, {String? type, int? sessionId});
  Future<List<AiSession>> getHistory(String clientId);
  Future<AiSession> getSession(String clientId, int sessionId);
}
