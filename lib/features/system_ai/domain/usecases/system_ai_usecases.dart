import '../repositories/system_ai_repository.dart';
import '../../../../core/common/entities/ai_session.dart';

class AskSystemAiUseCase {
  final SystemAiRepository repository;

  AskSystemAiUseCase(this.repository);

  Future<AiSession> call(String question, {String? type, int? sessionId}) {
    return repository.askQuestion(question, type: type, sessionId: sessionId);
  }
}

class GetSystemAiHistoryUseCase {
  final SystemAiRepository repository;

  GetSystemAiHistoryUseCase(this.repository);

  Future<List<AiSession>> call() {
    return repository.getHistory();
  }
}

class GetSystemAiSessionUseCase {
  final SystemAiRepository repository;

  GetSystemAiSessionUseCase(this.repository);

  Future<AiSession> call(int sessionId) {
    return repository.getSession(sessionId);
  }
}
