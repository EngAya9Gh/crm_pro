import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/whatsapp_thread_model.dart';
import '../models/whatsapp_message_model.dart';

abstract class WhatsappRemoteDataSource {
  Future<List<WhatsappThreadModel>> getThreads({int page = 1});
  Future<List<WhatsappMessageModel>> getThreadMessages(String threadId, {int page = 1});
  Future<WhatsappMessageModel> sendMessage(Map<String, dynamic> data);
  Future<void> replyToThread(String threadId, {required Map<String, dynamic> data});
}

class WhatsappRemoteDataSourceImpl implements WhatsappRemoteDataSource {
  final ApiClient apiClient;

  WhatsappRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<WhatsappThreadModel>> getThreads({int page = 1}) async {
    final response = await apiClient.get(
      EndPoints.whatsappThreads,
      queryParameters: {'page': page},
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        final threadsList = (data['threads'] as List?) ?? (data['data'] as List?) ?? [];
        return threadsList.map((e) => WhatsappThreadModel.fromJson(e)).toList();
      },
    );
    return response.data ?? [];
  }

  @override
  Future<List<WhatsappMessageModel>> getThreadMessages(String threadId, {int page = 1}) async {
    final response = await apiClient.get<List<WhatsappMessageModel>>(
      EndPoints.whatsappThreadMessages(threadId),
      queryParameters: {'page': page},
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        final messagesList = (data['messages'] as List?) ?? (data['data'] as List?) ?? [];
        return messagesList.reversed.map((e) => WhatsappMessageModel.fromJson(e)).toList();
      },
    );
    return response.data ?? [];
  }

  @override
  Future<WhatsappMessageModel> sendMessage(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.whatsappSend,
      data: data,
      fromJson: (json) => WhatsappMessageModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> replyToThread(String threadId, {required Map<String, dynamic> data}) async {
    await apiClient.post(
      EndPoints.whatsappThreadMessages(threadId),
      data: data,
      fromJson: (json) => null, // Ignore response data since it's just a success message
    );
  }
}
