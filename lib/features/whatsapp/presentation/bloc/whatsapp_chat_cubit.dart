import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/network/pusher_service.dart';
import '../../domain/usecases/get_thread_messages_usecase.dart';
import '../../domain/usecases/reply_to_thread_usecase.dart';
import '../../domain/entities/whatsapp_message.dart';
import '../../data/models/whatsapp_message_model.dart';
import 'whatsapp_chat_state.dart';

class WhatsappChatCubit extends Cubit<WhatsappChatState> {
  final GetThreadMessagesUseCase getThreadMessagesUseCase;
  final ReplyToThreadUseCase replyToThreadUseCase;
  final PusherService pusherService;
  StreamSubscription? _pusherSubscription;
  String? _currentThreadId;
  bool _isFetching = false;

  WhatsappChatCubit({
    required this.getThreadMessagesUseCase,
    required this.replyToThreadUseCase,
    required this.pusherService,
  }) : super(WhatsappChatInitial());

  Future<void> loadMessages(String threadId, {bool refresh = false}) async {
    _currentThreadId = threadId;
    _subscribeToPusher(threadId);

    if (_isFetching || state is WhatsappChatLoading) return;
    _isFetching = true;

    int page = 1;
    List<WhatsappMessage> currentMessages = [];

    if (!refresh && state is WhatsappChatLoaded) {
      final currentState = state as WhatsappChatLoaded;
      if (currentState.hasReachedMax) return;
      page = currentState.currentPage + 1;
      currentMessages = currentState.messages;
    } else {
      emit(WhatsappChatLoading());
    }

    final result = await getThreadMessagesUseCase(threadId, page: page);
    _isFetching = false;

    result.fold(
      (failure) => emit(WhatsappChatError(failure.message)),
      (messages) {
        if (messages.isEmpty) {
          emit(WhatsappChatLoaded(
            messages: List.from(currentMessages),
            hasReachedMax: true,
            currentPage: page,
          ));
        } else {
          emit(WhatsappChatLoaded(
            // Append new messages (typically older messages when paginating)
            messages: List.from(currentMessages)..addAll(messages),
            hasReachedMax: messages.length < 50,
            currentPage: page,
          ));
        }
      },
    );
  }

  Future<void> reply({
    required String type,
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    if (_currentThreadId == null) return;
    
    // Optional: Optimistic UI update could be added here
    
    final result = await replyToThreadUseCase(
      threadId: _currentThreadId!,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
    );

    result.fold(
      (failure) => emit(WhatsappChatError(failure.message)),
      (_) {
        loadMessages(_currentThreadId!, refresh: true);
      },
    );
  }

  void _subscribeToPusher(String threadId) {
    _pusherSubscription?.cancel();
    pusherService.subscribeToChannel('private-chat.$threadId');
    _pusherSubscription = pusherService.onMessageReceived.listen((eventData) {
      // Check if event is for this thread
      if (eventData['channel'] == 'private-chat.$threadId' && eventData['event'] == 'NewMessageReceived') {
        final data = eventData['data'];
        // Parse incoming message and add to state
        try {
          final incomingMessage = WhatsappMessageModel.fromJson(data['message'] ?? data);
          if (state is WhatsappChatLoaded) {
            final currentState = state as WhatsappChatLoaded;
            // Prevent duplicates
            if (!currentState.messages.any((m) => m.id == incomingMessage.id)) {
              emit(currentState.copyWith(
                messages: [incomingMessage, ...currentState.messages],
              ));
            }
          }
        } catch (e) {
          print("Error parsing incoming message via Pusher: $e");
        }
      }
    });
  }

  @override
  Future<void> close() {
    if (_currentThreadId != null) {
      pusherService.unsubscribeFromChannel('private-chat.$_currentThreadId!');
    }
    _pusherSubscription?.cancel();
    return super.close();
  }
}
