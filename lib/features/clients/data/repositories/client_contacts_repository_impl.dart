import '../../domain/entities/client_contact.dart';
import '../../domain/repositories/client_contacts_repository.dart';
import '../datasources/client_contacts_remote_datasource.dart';

class ClientContactsRepositoryImpl implements ClientContactsRepository {
  final ClientContactsRemoteDataSource remoteDataSource;

  ClientContactsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ClientContact>> getContacts(String clientId) async {
    return await remoteDataSource.getContacts(clientId);
  }

  @override
  Future<ClientContact> addContact(String clientId, Map<String, dynamic> data) async {
    return await remoteDataSource.addContact(clientId, data);
  }

  @override
  Future<ClientContact> updateContact(String clientId, int contactId, Map<String, dynamic> data) async {
    return await remoteDataSource.updateContact(clientId, contactId, data);
  }

  @override
  Future<void> deleteContact(String clientId, int contactId) async {
    return await remoteDataSource.deleteContact(clientId, contactId);
  }

  @override
  Future<void> mergeContact(String sourceClientId, String targetClientId, int contactId) async {
    return await remoteDataSource.mergeContact(sourceClientId, targetClientId, contactId);
  }
}
