abstract class ClientAiState {}

class ClientAiInitial extends ClientAiState {}

class ClientAiLoading extends ClientAiState {}

class ClientAiLoaded extends ClientAiState {}

class ClientAiError extends ClientAiState {
  final String message;
  ClientAiError(this.message);
}
