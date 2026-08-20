part of 'client_procedures_cubit.dart';

abstract class ClientProceduresState extends Equatable {
  const ClientProceduresState();

  @override
  List<Object> get props => [];
}

class ClientProceduresInitial extends ClientProceduresState {}

class ClientProceduresLoading extends ClientProceduresState {}

class ClientProceduresLoaded extends ClientProceduresState {
  final List<ClientProcedure> procedures;

  const ClientProceduresLoaded(this.procedures);

  @override
  List<Object> get props => [procedures];
}

class ClientProceduresError extends ClientProceduresState {
  final String message;

  const ClientProceduresError(this.message);

  @override
  List<Object> get props => [message];
}
