import '../../domain/repositories/system_ai_repository.dart';
import '../datasources/system_ai_remote_datasource.dart';
import '../../../../core/common/entities/ai_session.dart';

class SystemAiRepositoryImpl implements SystemAiRepository {
  final SystemAiRemoteDataSource remoteDataSource;

  SystemAiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AiSession> askQuestion(String question, {String? type, int? sessionId}) async {
    return await remoteDataSource.askQuestion(question, type: type, sessionId: sessionId);
  }

  @override
  Future<List<AiSession>> getHistory() async {
    return await remoteDataSource.getHistory();
  }

  @override
  Future<AiSession> getSession(int sessionId) async {
    return await remoteDataSource.getSession(sessionId);
  }
}
