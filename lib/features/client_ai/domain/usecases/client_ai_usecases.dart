import '../repositories/client_ai_repository.dart';
import '../entities/ai_insights.dart';
import 'package:crm_wakeel/core/common/entities/ai_session.dart';
import 'package:crm_wakeel/core/common/entities/ai_suggestions.dart';

class GetClientAiInsightsUseCase {
  final ClientAiRepository repository;

  GetClientAiInsightsUseCase(this.repository);

  Future<AiInsights> call(String clientId) {
    return repository.getInsights(clientId);
  }
}

class AskClientAiUseCase {
  final ClientAiRepository repository;

  AskClientAiUseCase(this.repository);

  Future<AiSession> call(String clientId, String question, {String? type, int? sessionId}) {
    return repository.askQuestion(clientId, question, type: type, sessionId: sessionId);
  }
}

class GetClientAiHistoryUseCase {
  final ClientAiRepository repository;

  GetClientAiHistoryUseCase(this.repository);

  Future<List<AiSession>> call(String clientId) {
    return repository.getHistory(clientId);
  }
}

class GetClientAiSessionUseCase {
  final ClientAiRepository repository;

  GetClientAiSessionUseCase(this.repository);

  Future<AiSession> call(String clientId, int sessionId) {
    return repository.getSession(clientId, sessionId);
  }
}

class GetClientAiSuggestionsUseCase {
  final ClientAiRepository repository;

  GetClientAiSuggestionsUseCase(this.repository);

  Future<AiSuggestions> call() {
    return repository.getSuggestions();
  }
}
