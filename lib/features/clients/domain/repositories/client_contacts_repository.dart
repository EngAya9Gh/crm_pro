import '../../domain/entities/client_contact.dart';

abstract class ClientContactsRepository {
  Future<List<ClientContact>> getContacts(int clientId);
  Future<ClientContact> addContact(int clientId, Map<String, dynamic> data);
  Future<ClientContact> updateContact(int clientId, int contactId, Map<String, dynamic> data);
  Future<void> deleteContact(int clientId, int contactId);
  Future<void> mergeContact(int sourceClientId, int contactId);
}
