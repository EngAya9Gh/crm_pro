import 'package:equatable/equatable.dart';
import '../../domain/entities/whatsapp_thread.dart';

abstract class WhatsappThreadsState extends Equatable {
  const WhatsappThreadsState();

  @override
  List<Object?> get props => [];
}

class WhatsappThreadsInitial extends WhatsappThreadsState {}

class WhatsappThreadsLoading extends WhatsappThreadsState {}

class WhatsappThreadsLoaded extends WhatsappThreadsState {
  final List<WhatsappThread> threads;
  final bool hasReachedMax;
  final int currentPage;

  const WhatsappThreadsLoaded({
    required this.threads,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  WhatsappThreadsLoaded copyWith({
    List<WhatsappThread>? threads,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WhatsappThreadsLoaded(
      threads: threads ?? this.threads,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [threads, hasReachedMax, currentPage];
}

class WhatsappThreadsError extends WhatsappThreadsState {
  final String message;

  const WhatsappThreadsError(this.message);

  @override
  List<Object?> get props => [message];
}
