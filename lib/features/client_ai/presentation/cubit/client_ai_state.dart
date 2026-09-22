abstract class ClientAiState {}

class ClientAiInitial extends ClientAiState {}

class ClientAiLoading extends ClientAiState {}

class ClientAiLoaded extends ClientAiState {
  final int timestamp;
  ClientAiLoaded({int? timestamp}) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
}

class ClientAiError extends ClientAiState {
  final String message;
  ClientAiError(this.message);
}
