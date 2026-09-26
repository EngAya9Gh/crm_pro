import '../../domain/entities/client_contact.dart';

abstract class ClientContactsRepository {
  Future<List<ClientContact>> getContacts(String clientId);
  Future<ClientContact> addContact(String clientId, Map<String, dynamic> data);
  Future<ClientContact> updateContact(String clientId, int contactId, Map<String, dynamic> data);
  Future<void> deleteContact(String clientId, int contactId);
  Future<void> mergeContact(String sourceClientId, String targetClientId, int contactId);
}
