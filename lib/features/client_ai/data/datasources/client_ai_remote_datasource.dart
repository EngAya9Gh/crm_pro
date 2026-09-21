import '../models/ai_insights_model.dart';
import 'package:crm_wakeel/core/common/models/ai_session_model.dart';
import 'package:crm_wakeel/core/common/models/ai_suggestions_model.dart';

abstract class ClientAiRemoteDataSource {
  Future<AiInsightsModel> getInsights(String clientId);
  Future<AiSessionModel> askQuestion(String clientId, String question, {String? type, int? sessionId});
  Future<List<AiSessionModel>> getHistory(String clientId);
  Future<AiSessionModel> getSession(String clientId, int sessionId);
  Future<AiSuggestionsModel> getSuggestions();
}
