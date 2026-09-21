import 'package:equatable/equatable.dart';

abstract class SystemAiState extends Equatable {
  const SystemAiState();

  @override
  List<Object?> get props => [];
}

class SystemAiInitial extends SystemAiState {}

class SystemAiLoading extends SystemAiState {}

class SystemAiLoaded extends SystemAiState {
  final int timestamp; // To force UI update on new messages
  
  const SystemAiLoaded({required this.timestamp});
  
  @override
  List<Object?> get props => [timestamp];
}

class SystemAiError extends SystemAiState {
  final String message;

  const SystemAiError(this.message);

  @override
  List<Object?> get props => [message];
}
