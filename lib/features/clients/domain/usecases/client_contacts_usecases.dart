import '../entities/client_contact.dart';
import '../repositories/client_contacts_repository.dart';

class GetClientContactsUseCase {
  final ClientContactsRepository repository;

  GetClientContactsUseCase(this.repository);

  Future<List<ClientContact>> call(String clientId) async {
    return await repository.getContacts(clientId);
  }
}

class AddClientContactUseCase {
  final ClientContactsRepository repository;

  AddClientContactUseCase(this.repository);

  Future<ClientContact> call(String clientId, Map<String, dynamic> data) async {
    return await repository.addContact(clientId, data);
  }
}

class UpdateClientContactUseCase {
  final ClientContactsRepository repository;

  UpdateClientContactUseCase(this.repository);

  Future<ClientContact> call(String clientId, int contactId, Map<String, dynamic> data) async {
    return await repository.updateContact(clientId, contactId, data);
  }
}

class DeleteClientContactUseCase {
  final ClientContactsRepository repository;

  DeleteClientContactUseCase(this.repository);

  Future<void> call(String clientId, int contactId) async {
    return await repository.deleteContact(clientId, contactId);
  }
}

class MergeClientContactUseCase {
  final ClientContactsRepository repository;

  MergeClientContactUseCase(this.repository);

  Future<void> call(String sourceClientId, String targetClientId, int contactId) async {
    return await repository.mergeContact(sourceClientId, targetClientId, contactId);
  }
}
