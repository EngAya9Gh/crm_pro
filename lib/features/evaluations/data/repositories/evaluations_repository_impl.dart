import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../domain/entities/evaluation_type.dart';
import '../../domain/repositories/evaluations_repository.dart';
import '../datasources/evaluations_remote_datasource.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_type_model.dart';

class EvaluationsRepositoryImpl implements EvaluationsRepository {
  final EvaluationsRemoteDataSource remoteDataSource;

  EvaluationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Evaluation>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
  }) async {
    return await remoteDataSource.getEvaluations(
      clientId: clientId,
      assignedUserId: assignedUserId,
      typeId: typeId,
      rating: rating,
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
    return await remoteDataSource.createType(type as EvaluationTypeModel);
  }

  @override
  Future<EvaluationType> updateType(int id, EvaluationType type) async {
    return await remoteDataSource.updateType(id, type as EvaluationTypeModel);
  }

  @override
  Future<void> deleteType(int id) async {
    return await remoteDataSource.deleteType(id);
  }
}
