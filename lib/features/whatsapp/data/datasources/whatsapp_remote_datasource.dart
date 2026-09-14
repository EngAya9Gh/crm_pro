import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/whatsapp_thread_model.dart';
import '../models/whatsapp_message_model.dart';

abstract class WhatsappRemoteDataSource {
  Future<List<WhatsappThreadModel>> getThreads({int page = 1});
  Future<List<WhatsappMessageModel>> getThreadMessages(
    String threadId, {
    int page = 1,
  });
  Future<WhatsappMessageModel> sendMessage(Map<String, dynamic> data);
  Future<void> replyToThread(
    String threadId, {
    required Map<String, dynamic> data,
    bool isFormData = false,
  });
  Future<void> sendMediaFormData(Map<String, dynamic> data);
  Future<String> uploadMedia(
    String threadId, {
    required Map<String, dynamic> data,
  });
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
        final map = json as Map<String, dynamic>;
        final threadsList = map['threads'] as List<dynamic>? ?? [];
        return threadsList
            .map((e) => WhatsappThreadModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data ?? [];
  }

  @override
  Future<List<WhatsappMessageModel>> getThreadMessages(
    String threadId, {
    int page = 1,
  }) async {
    final response = await apiClient.get<List<WhatsappMessageModel>>(
      EndPoints.whatsappThreadMessages(threadId),
      queryParameters: {'page': page},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final messagesList = map['messages'] as List<dynamic>? ?? [];
        return messagesList.reversed
            .map(
              (e) => WhatsappMessageModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    return response.data ?? [];
  }

  @override
  Future<WhatsappMessageModel> sendMessage(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.whatsappSend,
      data: data,
      fromJson: (json) =>
          WhatsappMessageModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> replyToThread(
    String threadId, {
    required Map<String, dynamic> data,
    bool isFormData = false,
  }) async {
    await apiClient.post(
      EndPoints.whatsappThreadMessages(threadId),
      data: data,
      isFormData: isFormData,
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> sendMediaFormData(Map<String, dynamic> data) async {
    // POST /whatsapp/send with FormData (for media files)
    await apiClient.post(
      EndPoints.whatsappSend,
      data: data,
      isFormData: true,
      fromJson: (json) => null,
    );
  }

  @override
  Future<String> uploadMedia(
    String threadId, {
    required Map<String, dynamic> data,
  }) async {
    final response = await apiClient.post(
      EndPoints.whatsappMediaUpload(threadId),
      data: data,
      isFormData: true,
      fromJson: (json) => (json as Map<String, dynamic>)['url'] as String,
    );
    return response.data!;
  }
}
