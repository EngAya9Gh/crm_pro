import 'client_ai_remote_datasource.dart';
import '../models/ai_insights_model.dart';
import 'package:crm_wakeel/core/common/models/ai_session_model.dart';
import 'package:crm_wakeel/core/common/models/ai_suggestions_model.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';

class ClientAiRemoteDataSourceImpl implements ClientAiRemoteDataSource {
  final ApiClient apiClient;

  ClientAiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AiInsightsModel> getInsights(String clientId) async {
    final response = await apiClient.get<AiInsightsModel>(
      EndPoints.clientAiInsights(clientId),
      fromJson: (json) => AiInsightsModel.fromJson((json as Map<String, dynamic>)['insights']),
    );
    return response.data!;
  }

  @override
  Future<AiSessionModel> askQuestion(String clientId, String question, {String? type, int? sessionId}) async {
    final response = await apiClient.post<AiSessionModel>(
      EndPoints.clientAiAsk(clientId),
      data: {
        'question': question,
        if (type != null) 'type': type,
        if (sessionId != null) 'session_id': sessionId,
      },
      fromJson: (json) => AiSessionModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<List<AiSessionModel>> getHistory(String clientId) async {
    final response = await apiClient.get<List<AiSessionModel>>(
      EndPoints.clientAiHistory(clientId),
      fromJson: (json) {
        final List sessions = (json as Map<String, dynamic>)['sessions'] ?? [];
        return sessions.map((e) => AiSessionModel.fromJson(e)).toList();
      },
    );
    return response.data!;
  }

  @override
  Future<AiSessionModel> getSession(String clientId, int sessionId) async {
    final response = await apiClient.get<AiSessionModel>(
      EndPoints.clientAiSession(clientId, sessionId),
      fromJson: (json) => AiSessionModel.fromJson((json as Map<String, dynamic>)['session']),
    );
    return response.data!;
  }

  @override
  Future<AiSuggestionsModel> getSuggestions([String? clientId]) async {
    final url = clientId != null 
        ? '${EndPoints.clientAiSuggestions}?client_id=$clientId'
        : EndPoints.clientAiSuggestions;
    final response = await apiClient.get<AiSuggestionsModel>(
      url,
      fromJson: (json) => AiSuggestionsModel.fromJson((json as Map<String, dynamic>)['suggestions']),
    );
    return response.data!;
  }

  @override
  Future<AiSessionModel> summarizeWhatsappChat(String clientId, String threadId, {int? sessionId}) async {
    final response = await apiClient.post<AiSessionModel>(
      EndPoints.clientAiSummarizeWhatsapp(clientId),
      data: {
        'thread_id': threadId,
        if (sessionId != null) 'session_id': sessionId,
      },
      fromJson: (json) => AiSessionModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
