import '../../../../core/common/entities/ai_session.dart';

abstract class SystemAiRepository {
  Future<AiSession> askQuestion(String question, {String? type, int? sessionId});
  Future<List<AiSession>> getHistory();
  Future<AiSession> getSession(int sessionId);
}
