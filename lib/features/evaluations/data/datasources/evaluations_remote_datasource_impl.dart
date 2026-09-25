import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/api_response.dart';
import '../../../../core/utils/end_points.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_stats_model.dart';
import '../models/evaluation_type_model.dart';
import 'evaluations_remote_datasource.dart';

class EvaluationsRemoteDataSourceImpl implements EvaluationsRemoteDataSource {
  final ApiClient apiClient;

  EvaluationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<List<EvaluationModel>>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      if (clientId != null) 'client_id': clientId,
      if (assignedUserId != null) 'assigned_user_id': assignedUserId,
      if (typeId != null) 'type_id': typeId,
      if (rating != null) 'rating': rating,
    };

    return await apiClient.get<List<EvaluationModel>>(
      EndPoints.evaluations,
      queryParameters: queryParams,
      fromJson: (json) => (json as List)
          .map((e) => EvaluationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<EvaluationStatsModel> getEvaluationStats({int? assignedUserId}) async {
    final queryParams = <String, dynamic>{
      if (assignedUserId != null) 'assigned_user_id': assignedUserId,
    };

    final response = await apiClient.get<EvaluationStatsModel>(
      EndPoints.evaluationStats,
      queryParameters: queryParams,
      fromJson: (json) => EvaluationStatsModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<EvaluationModel> createEvaluation(EvaluationModel evaluation) async {
    final response = await apiClient.post<EvaluationModel>(
      EndPoints.evaluations,
      data: evaluation.toJson(),
      fromJson: (json) => EvaluationModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<String> createEvaluationLink(int typeId, {
    int? clientId,
    int? assignedUserId,
    int? ticketId,
    String channel = 'whatsapp',
    String? noteForClient,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      EndPoints.evaluationLinks,
      data: {
        'type_id': typeId,
        if (clientId != null) 'client_id': clientId,
        if (assignedUserId != null) 'assigned_user_id': assignedUserId,
        if (ticketId != null) 'ticket_id': ticketId,
        'channel': channel,
        if (noteForClient != null) 'note_for_client': noteForClient,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return response.data!['public_url'] as String;
  }

  @override
  Future<List<EvaluationTypeModel>> getTypes() async {
    final response = await apiClient.get<List<EvaluationTypeModel>>(
      EndPoints.evaluationTypes,
      fromJson: (json) => (json as List)
          .map((e) => EvaluationTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data ?? [];
  }

  @override
  Future<EvaluationTypeModel> createType(EvaluationTypeModel type) async {
    final response = await apiClient.post<EvaluationTypeModel>(
      EndPoints.evaluationTypes,
      data: type.toJson(),
      fromJson: (json) => EvaluationTypeModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<EvaluationTypeModel> updateType(int id, EvaluationTypeModel type) async {
    final response = await apiClient.put<EvaluationTypeModel>(
      EndPoints.evaluationType(id.toString()),
      data: type.toJson(),
      fromJson: (json) => EvaluationTypeModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteType(int id) async {
    await apiClient.delete<void>(
      EndPoints.evaluationType(id.toString()),
      fromJson: (_) {},
    );
  }
}
