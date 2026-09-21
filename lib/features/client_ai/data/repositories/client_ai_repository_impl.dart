import '../../domain/repositories/client_ai_repository.dart';
import '../datasources/client_ai_remote_datasource.dart';
import '../../domain/entities/ai_insights.dart';
import '../../domain/entities/ai_session.dart';
import '../../domain/entities/ai_suggestions.dart';

class ClientAiRepositoryImpl implements ClientAiRepository {
  final ClientAiRemoteDataSource remoteDataSource;

  ClientAiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AiInsights> getInsights(String clientId) async {
    return await remoteDataSource.getInsights(clientId);
  }

  @override
  Future<AiSession> askQuestion(String clientId, String question, {String? type, int? sessionId}) async {
    return await remoteDataSource.askQuestion(clientId, question, type: type, sessionId: sessionId);
  }

  @override
  Future<List<AiSession>> getHistory(String clientId) async {
    return await remoteDataSource.getHistory(clientId);
  }

  @override
  Future<AiSession> getSession(String clientId, int sessionId) async {
    return await remoteDataSource.getSession(clientId, sessionId);
  }

  @override
  Future<AiSuggestions> getSuggestions() async {
    return await remoteDataSource.getSuggestions();
  }
}
