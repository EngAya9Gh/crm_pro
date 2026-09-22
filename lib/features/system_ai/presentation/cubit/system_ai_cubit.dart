import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/entities/ai_session.dart';
import 'package:crm_wakeel/core/common/entities/ai_message.dart';
import 'package:crm_wakeel/core/common/models/ai_message_model.dart';
import 'package:crm_wakeel/core/common/entities/ai_suggestions.dart';
import 'package:crm_wakeel/features/client_ai/domain/usecases/client_ai_usecases.dart';
import 'package:crm_wakeel/features/system_ai/domain/usecases/system_ai_usecases.dart';
import 'system_ai_state.dart';

class SystemAiCubit extends Cubit<SystemAiState> {
  final AskSystemAiUseCase askQuestionUseCase;
  final GetSystemAiHistoryUseCase getHistoryUseCase;
  final GetSystemAiSessionUseCase getSessionUseCase;
  final GetClientAiSuggestionsUseCase getSuggestionsUseCase;

  AiSession? currentSession;
  List<AiSession> history = [];
  AiSuggestions? suggestions;
  int? get currentSessionId => currentSession?.id;
  bool isAsking = false;

  List<AiMessage> get currentMessages => currentSession?.messages ?? [];

  SystemAiCubit({
    required this.askQuestionUseCase,
    required this.getHistoryUseCase,
    required this.getSessionUseCase,
    required this.getSuggestionsUseCase,
  }) : super(SystemAiInitial());

  Future<void> init() async {
    emit(SystemAiLoading());
    final historyFuture = getHistoryUseCase();
    final suggestionsFuture = getSuggestionsUseCase();

    try {
      history = await historyFuture;
      if (history.isNotEmpty) {
        final lastSession = await getSessionUseCase(history.first.id);
        currentSession = lastSession;
      }
    } catch (e) {
      history = [];
    }

    try {
      suggestions = await suggestionsFuture;
    } catch (e) {
      suggestions = AiSuggestions(clientSpecific: [], general: []);
    }

    emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> askQuestion(String question, {String? type}) async {
    if (question.trim().isEmpty) return;

    if (currentSession == null) {
      currentSession = AiSession(
        id: -1,
        title: question,
        messages: [],
        createdAt: DateTime.now(),
      );
    }
    
    currentSession!.messages!.add(
      AiMessageModel(
        role: 'user',
        content: question,
      ),
    );

    isAsking = true;
    emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));

    try {
      final session = await askQuestionUseCase(
        question,
        type: type,
        sessionId: currentSessionId != -1 ? currentSessionId : null,
      );
      
      currentSession = session;
      
      if (currentSessionId != -1) {
        final existingIndex = history.indexWhere((s) => s.id == session.id);
        if (existingIndex != -1) {
          history[existingIndex] = session;
        } else {
          history.insert(0, session);
        }
      }
      
      
      isAsking = false;
      emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      isAsking = false;
      emit(SystemAiError(e.toString()));
      emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));
    }
  }

  Future<void> loadSession(int sessionId) async {
    emit(SystemAiLoading());
    try {
      final session = await getSessionUseCase(sessionId);
      currentSession = session;
      emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      emit(SystemAiError(e.toString()));
    }
  }

  void startNewSession() {
    currentSession = null;
    emit(SystemAiLoaded(timestamp: DateTime.now().millisecondsSinceEpoch));
  }
}
