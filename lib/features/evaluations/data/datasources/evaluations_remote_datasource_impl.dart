import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_stats_model.dart';
import '../models/evaluation_type_model.dart';
import 'evaluations_remote_datasource.dart';

class EvaluationsRemoteDataSourceImpl implements EvaluationsRemoteDataSource {
  final ApiClient apiClient;

  EvaluationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EvaluationModel>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
  }) async {
    final queryParams = <String, dynamic>{
      if (clientId != null) 'client_id': clientId,
      if (assignedUserId != null) 'assigned_user_id': assignedUserId,
      if (typeId != null) 'type_id': typeId,
      if (rating != null) 'rating': rating,
    };

    final response = await apiClient.get(
      EndPoints.evaluations,
      queryParameters: queryParams,
    );

    return (response.data['data'] as List)
        .map((json) => EvaluationModel.fromJson(json))
        .toList();
  }

  @override
  Future<EvaluationStatsModel> getEvaluationStats({int? assignedUserId}) async {
    final queryParams = <String, dynamic>{
      if (assignedUserId != null) 'assigned_user_id': assignedUserId,
    };

    final response = await apiClient.get(
      EndPoints.evaluationStats,
      queryParameters: queryParams,
    );

    return EvaluationStatsModel.fromJson(response.data['data']);
  }

  @override
  Future<EvaluationModel> createEvaluation(EvaluationModel evaluation) async {
    final response = await apiClient.post(
      EndPoints.evaluations,
      data: evaluation.toJson(),
    );
    return EvaluationModel.fromJson(response.data['data']);
  }

  @override
  Future<String> createEvaluationLink(int typeId, {
    int? clientId,
    int? assignedUserId,
    int? ticketId,
    String channel = 'whatsapp',
    String? noteForClient,
  }) async {
    final response = await apiClient.post(
      EndPoints.evaluationLinks,
      data: {
        'type_id': typeId,
        'client_id': clientId,
        'assigned_user_id': assignedUserId,
        'ticket_id': ticketId,
        'channel': channel,
        'note_for_client': noteForClient,
      },
    );
    return response.data['data']['link'];
  }

  @override
  Future<List<EvaluationTypeModel>> getTypes() async {
    final response = await apiClient.get(EndPoints.evaluationTypes);
    return (response.data['data'] as List)
        .map((json) => EvaluationTypeModel.fromJson(json))
        .toList();
  }

  @override
  Future<EvaluationTypeModel> createType(EvaluationTypeModel type) async {
    final response = await apiClient.post(
      EndPoints.evaluationTypes,
      data: type.toJson(),
    );
    return EvaluationTypeModel.fromJson(response.data['data']);
  }

  @override
  Future<EvaluationTypeModel> updateType(int id, EvaluationTypeModel type) async {
    final response = await apiClient.put(
      EndPoints.evaluationType(id.toString()),
      data: type.toJson(),
    );
    return EvaluationTypeModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteType(int id) async {
    await apiClient.delete(EndPoints.evaluationType(id.toString()));
  }
}
