import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../domain/entities/evaluation_type.dart';
import '../../domain/repositories/evaluations_repository.dart';
import '../datasources/evaluations_remote_datasource.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_type_model.dart';
import '../../../../core/services/network/api_response.dart';

class EvaluationsRepositoryImpl implements EvaluationsRepository {
  final EvaluationsRemoteDataSource remoteDataSource;

  EvaluationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<List<Evaluation>>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
    int page = 1,
  }) async {
    final response = await remoteDataSource.getEvaluations(
      clientId: clientId,
      assignedUserId: assignedUserId,
      typeId: typeId,
      rating: rating,
      page: page,
    );
    return ApiResponse<List<Evaluation>>(
      success: response.success,
      message: response.message,
      data: response.data?.cast<Evaluation>(),
      meta: response.meta,
    );
  }

  @override
  Future<EvaluationStats> getEvaluationStats({int? assignedUserId}) async {
    return await remoteDataSource.getEvaluationStats(assignedUserId: assignedUserId);
  }

  @override
  Future<Evaluation> createEvaluation(Evaluation evaluation) async {
    return await remoteDataSource.createEvaluation(evaluation as EvaluationModel);
  }

  @override
  Future<String> createEvaluationLink(int typeId, {
    int? clientId,
    int? assignedUserId,
    int? ticketId,
    String channel = 'whatsapp',
    String? noteForClient,
  }) async {
    return await remoteDataSource.createEvaluationLink(
      typeId,
      clientId: clientId,
      assignedUserId: assignedUserId,
      ticketId: ticketId,
      channel: channel,
      noteForClient: noteForClient,
    );
  }

  @override
  Future<List<EvaluationType>> getTypes() async {
    return await remoteDataSource.getTypes();
  }

  @override
  Future<EvaluationType> createType(EvaluationType type) async {
    if (type is EvaluationTypeModel) {
      return await remoteDataSource.createType(type);
    }
    return await remoteDataSource.createType(EvaluationTypeModel(id: type.id, name: type.name, isActive: type.isActive));
  }

  @override
  Future<EvaluationType> updateType(int id, EvaluationType type) async {
    if (type is EvaluationTypeModel) {
      return await remoteDataSource.updateType(id, type);
    }
    return await remoteDataSource.updateType(id, EvaluationTypeModel(id: type.id, name: type.name, isActive: type.isActive));
  }

  @override
  Future<void> deleteType(int id) async {
    return await remoteDataSource.deleteType(id);
  }
}
