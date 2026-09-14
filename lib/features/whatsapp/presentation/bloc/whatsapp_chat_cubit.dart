import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/network/pusher_service.dart';
import '../../domain/usecases/get_thread_messages_usecase.dart';
import '../../domain/usecases/reply_to_thread_usecase.dart';
import '../../domain/entities/whatsapp_message.dart';
import '../../domain/entities/whatsapp_thread.dart';
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
      if (state is WhatsappChatLoaded) {
        currentMessages = List.from((state as WhatsappChatLoaded).messages);
        // Remove optimistic messages before merging real ones from API
        currentMessages.removeWhere((m) => m.id.startsWith('optimistic_'));
      } else {
        emit(WhatsappChatLoading());
      }
    }

    final result = await getThreadMessagesUseCase(threadId, page: page);
    _isFetching = false;

    result.fold((failure) => emit(WhatsappChatError(failure.message)), (
      messages,
    ) {
      if (messages.isEmpty) {
        emit(
          WhatsappChatLoaded(
            messages: currentMessages,
            hasReachedMax: true,
            currentPage: page,
          ),
        );
      } else {
        final newMessages = messages
            .where(
              (msg) =>
                  !currentMessages.any((existing) => existing.id == msg.id),
            )
            .toList();

        if (refresh && state is WhatsappChatLoaded) {
          final currentState = state as WhatsappChatLoaded;
          emit(
            WhatsappChatLoaded(
              messages: [...newMessages, ...currentMessages],
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage,
            ),
          );
        } else {
          emit(
            WhatsappChatLoaded(
              messages: [...currentMessages, ...newMessages],
              hasReachedMax: messages.length < 10, // Adjust per_page if needed
              currentPage: page,
            ),
          );
        }
      }
    });
  }

  Future<void> sendMedia({
    required WhatsappThread thread,
    required String mediaType,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    // Optimistic UI for media upload
    if (state is WhatsappChatLoaded) {
      final currentState = state as WhatsappChatLoaded;
      final optimisticMsg = WhatsappMessageModel(
        id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
        threadId: thread.id,
        direction: 'OUTBOUND',
        type: mediaType.toUpperCase(),
        content: fileName,
        mediaUrl: null,
        status: 'UPLOADING',
        createdAt: DateTime.now(),
      );

      emit(
        currentState.copyWith(
          messages: [optimisticMsg, ...currentState.messages],
        ),
      );
    }

    final result = await replyToThreadUseCase(
      threadId: thread.id,
      type: 'media',
      mediaType: mediaType,
      clientId: thread.clientId,
      clientPhone: thread.clientPhone,
      fileBytes: fileBytes,
      fileName: fileName,
      useSendEndpoint: true,
    );

    result.fold(
      (failure) => emit(WhatsappChatError(failure.message)),
      (_) => loadMessages(_currentThreadId!, refresh: true),
    );
  }

  Future<void> reply({
    required String type,
    String? mediaType,
    String? content,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    if (_currentThreadId == null) return;

    // Optimistic UI update
    if (state is WhatsappChatLoaded &&
        type == 'text' &&
        content != null &&
        content.isNotEmpty) {
      final currentState = state as WhatsappChatLoaded;
      final optimisticMsg = WhatsappMessageModel(
        id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
        threadId: _currentThreadId!,
        direction: 'OUTBOUND',
        type: 'TEXT',
        content: content,
        status: 'PENDING',
        createdAt: DateTime.now(),
      );

      emit(
        currentState.copyWith(
          messages: [optimisticMsg, ...currentState.messages],
        ),
      );
    }

    final result = await replyToThreadUseCase(
      threadId: _currentThreadId!,
      type: type,
      mediaType: mediaType,
      content: content,
      fileBytes: fileBytes,
      fileName: fileName,
    );

    result.fold((failure) => emit(WhatsappChatError(failure.message)), (_) {
      loadMessages(_currentThreadId!, refresh: true);
    });
  }

  void _subscribeToPusher(String threadId) {
    _pusherSubscription?.cancel();
    pusherService.subscribeToChannel('private-chat.$threadId');
    _pusherSubscription = pusherService.onMessageReceived.listen((eventData) {
      // Check if event is for this thread
      if (eventData['channel'] == 'private-chat.$threadId' &&
          eventData['event'] == 'NewMessageReceived') {
        final data = eventData['data'];
        // Parse incoming message and add to state
        try {
          final incomingMessage = WhatsappMessageModel.fromJson(
            data['message'] ?? data,
          );
          if (state is WhatsappChatLoaded) {
            final currentState = state as WhatsappChatLoaded;
            // Prevent duplicates
            if (!currentState.messages.any((m) => m.id == incomingMessage.id)) {
              emit(
                currentState.copyWith(
                  messages: [incomingMessage, ...currentState.messages],
                ),
              );
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
