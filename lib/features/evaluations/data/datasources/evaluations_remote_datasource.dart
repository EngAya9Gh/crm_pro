import '../models/evaluation_model.dart';
import '../models/evaluation_stats_model.dart';
import '../models/evaluation_type_model.dart';
import '../../../../core/services/network/api_response.dart';

abstract class EvaluationsRemoteDataSource {
  Future<ApiResponse<List<EvaluationModel>>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
    int page = 1,
  });

  Future<EvaluationStatsModel> getEvaluationStats({int? assignedUserId});
  Future<EvaluationModel> createEvaluation(EvaluationModel evaluation);
  Future<String> createEvaluationLink(int typeId, {
    int? clientId,
    int? assignedUserId,
    int? ticketId,
    String channel = 'whatsapp',
    String? noteForClient,
  });

  Future<List<EvaluationTypeModel>> getTypes();
  Future<EvaluationTypeModel> createType(EvaluationTypeModel type);
  Future<EvaluationTypeModel> updateType(int id, EvaluationTypeModel type);
  Future<void> deleteType(int id);
}
