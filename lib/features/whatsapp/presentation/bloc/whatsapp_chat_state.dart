import 'package:equatable/equatable.dart';
import '../../domain/entities/whatsapp_message.dart';

abstract class WhatsappChatState extends Equatable {
  const WhatsappChatState();

  @override
  List<Object?> get props => [];
}

class WhatsappChatInitial extends WhatsappChatState {}

class WhatsappChatLoading extends WhatsappChatState {}

class WhatsappChatLoaded extends WhatsappChatState {
  final List<WhatsappMessage> messages;
  final bool hasReachedMax;
  final int currentPage;

  const WhatsappChatLoaded({
    required this.messages,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  WhatsappChatLoaded copyWith({
    List<WhatsappMessage>? messages,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WhatsappChatLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [messages, hasReachedMax, currentPage];
}

class WhatsappChatError extends WhatsappChatState {
  final String message;

  const WhatsappChatError(this.message);

  @override
  List<Object?> get props => [message];
}
