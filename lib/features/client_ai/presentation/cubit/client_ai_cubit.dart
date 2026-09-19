import 'package:flutter_bloc/flutter_bloc.dart';
import 'client_ai_state.dart';
import '../../domain/usecases/client_ai_usecases.dart';
import '../../domain/entities/ai_insights.dart';
import '../../domain/entities/ai_session.dart';
import '../../domain/entities/ai_message.dart';
import '../../../../core/error/api_exception.dart';

class ClientAiCubit extends Cubit<ClientAiState> {
  final GetClientAiInsightsUseCase getInsightsUseCase;
  final AskClientAiUseCase askQuestionUseCase;
  final GetClientAiHistoryUseCase getHistoryUseCase;
  final GetClientAiSessionUseCase getSessionUseCase;

  AiInsights? insights;
  List<AiSession> history = [];
  
  // Current Chat Session State
  int? currentSessionId;
  List<AiMessage> currentMessages = [];
  bool isAsking = false;

  ClientAiCubit({
    required this.getInsightsUseCase,
    required this.askQuestionUseCase,
    required this.getHistoryUseCase,
    required this.getSessionUseCase,
  }) : super(ClientAiInitial());

  Future<void> loadInsightsAndHistory(String clientId) async {
    emit(ClientAiLoading());
    try {
      final results = await Future.wait([
        getInsightsUseCase(clientId),
        getHistoryUseCase(clientId),
      ]);
      insights = results[0] as AiInsights;
      history = results[1] as List<AiSession>;
      emit(ClientAiLoaded());
    } catch (e) {
      String errorMessage = e.toString();
      if (e is ServerException || (e is ApiException && e.statusCode == 500)) {
        errorMessage = 'فشل في الاتصال بخدمة الذكاء الاصطناعي';
      }
      emit(ClientAiError(errorMessage));
    }
  }

  Future<void> askQuestion(String clientId, String question, {String? type}) async {
    if (question.trim().isEmpty) return;
    
    // Add user message locally for immediate UI update
    currentMessages.add(AiMessage(role: 'user', content: question));
    isAsking = true;
    emit(ClientAiLoaded());

    try {
      final session = await askQuestionUseCase(
        clientId, 
        question, 
        type: type, 
        sessionId: currentSessionId,
      );
      
      currentSessionId = session.id;
      if (session.messages != null && session.messages!.isNotEmpty) {
        currentMessages = List.from(session.messages!);
      } else if (session.answer != null) {
        // Fallback if API only returns answer without full messages array
        currentMessages.add(AiMessage(role: 'assistant', content: session.answer!));
      }
      
      // Refresh history silently
      getHistoryUseCase(clientId).then((value) {
        history = value;
        emit(ClientAiLoaded());
      });

    } catch (e) {
      String errorMessage = e.toString();
      if (e is ServerException || (e is ApiException && e.statusCode == 500)) {
        errorMessage = 'فشل في الاتصال بخدمة الذكاء الاصطناعي';
      }
      
      // We can add it as a message or just emit error for snackbar. 
      // Emitting error for SnackBar is preferred per user instruction.
      emit(ClientAiError(errorMessage));
      
      // Keep it in chat as well or let user retry.
      currentMessages.add(AiMessage(role: 'assistant', content: 'عذراً، $errorMessage'));
    } finally {
      isAsking = false;
      emit(ClientAiLoaded());
    }
  }

  Future<void> loadSession(String clientId, int sessionId) async {
    emit(ClientAiLoading());
    try {
      final session = await getSessionUseCase(clientId, sessionId);
      currentSessionId = session.id;
      currentMessages = session.messages ?? [];
      emit(ClientAiLoaded());
    } catch (e) {
      String errorMessage = e.toString();
      if (e is ServerException || (e is ApiException && e.statusCode == 500)) {
        errorMessage = 'فشل في الاتصال بخدمة الذكاء الاصطناعي';
      }
      emit(ClientAiError(errorMessage));
    }
  }

  void startNewSession() {
    currentSessionId = null;
    currentMessages = [];
    emit(ClientAiLoaded());
  }
}
