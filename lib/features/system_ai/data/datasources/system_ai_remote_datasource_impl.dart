import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../../../../core/common/entities/ai_session.dart';
import '../../../../core/common/models/ai_session_model.dart';
import 'system_ai_remote_datasource.dart';

class SystemAiRemoteDataSourceImpl implements SystemAiRemoteDataSource {
  final ApiClient apiClient;

  SystemAiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AiSession> askQuestion(String question, {String? type, int? sessionId}) async {
    final response = await apiClient.post<AiSessionModel>(
      EndPoints.systemAiAsk,
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
  Future<List<AiSession>> getHistory() async {
    final response = await apiClient.get<List<AiSessionModel>>(
      EndPoints.systemAiHistory,
      fromJson: (json) {
        final List sessions = (json as Map<String, dynamic>)['sessions'] ?? [];
        return sessions.map((e) => AiSessionModel.fromJson(e)).toList();
      },
    );
    return response.data!;
  }

  @override
  Future<AiSession> getSession(int sessionId) async {
    final response = await apiClient.get<AiSessionModel>(
      EndPoints.systemAiSession(sessionId),
      fromJson: (json) => AiSessionModel.fromJson((json as Map<String, dynamic>)['session']),
    );
    return response.data!;
  }
}
