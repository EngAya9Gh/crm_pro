import '../../domain/entities/client_contact.dart';

abstract class ClientContactsState {}

class ClientContactsInitial extends ClientContactsState {}

class ClientContactsLoading extends ClientContactsState {}

class ClientContactsLoaded extends ClientContactsState {
  final List<ClientContact> contacts;

  ClientContactsLoaded(this.contacts);
}

class ClientContactsOperationInProgress extends ClientContactsState {}

class ClientContactsOperationSuccess extends ClientContactsState {
  final String message;

  ClientContactsOperationSuccess(this.message);
}

class ClientContactsError extends ClientContactsState {
  final String message;

  ClientContactsError(this.message);
}
