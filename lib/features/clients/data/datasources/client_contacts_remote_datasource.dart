import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/client_contact_model.dart';
import 'package:dio/dio.dart';

abstract class ClientContactsRemoteDataSource {
  Future<List<ClientContactModel>> getContacts(String clientId);
  Future<ClientContactModel> addContact(String clientId, Map<String, dynamic> data);
  Future<ClientContactModel> updateContact(String clientId, int contactId, Map<String, dynamic> data);
  Future<void> deleteContact(String clientId, int contactId);
  Future<void> mergeContact(String sourceClientId, String targetClientId, int contactId);
}

class ClientContactsRemoteDataSourceImpl implements ClientContactsRemoteDataSource {
  final ApiClient _apiClient;

  ClientContactsRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<ClientContactModel>> getContacts(String clientId) async {
    final response = await _apiClient.dio.get(EndPoints.clientContacts(clientId));
    
    // API returns a direct List instead of a standard {data: ...} object
    if (response.data is List) {
      return (response.data as List)
          .map((e) => ClientContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<ClientContactModel> addContact(String clientId, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      EndPoints.clientContacts(clientId),
      data: data,
    );
    // API returns {message: ..., contact: {...}}
    return ClientContactModel.fromJson(response.data['contact'] as Map<String, dynamic>);
  }

  @override
  Future<ClientContactModel> updateContact(String clientId, int contactId, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.put(
      EndPoints.clientContact(clientId, contactId.toString()),
      data: data,
    );
    // Assuming API returns {message: ..., contact: {...}} on update as well
    return ClientContactModel.fromJson(response.data['contact'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteContact(String clientId, int contactId) async {
    await _apiClient.dio.delete(
      EndPoints.clientContact(clientId, contactId.toString()),
    );
  }

  @override
  Future<void> mergeContact(String sourceClientId, String targetClientId, int contactId) async {
    await _apiClient.dio.post(
      EndPoints.clientMergeContact(sourceClientId),
      data: {
        'target_client_id': int.tryParse(targetClientId) ?? targetClientId,
        'contact_id': contactId,
      },
    );
  }
}
