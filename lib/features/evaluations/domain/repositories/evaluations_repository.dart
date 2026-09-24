import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../domain/entities/evaluation_type.dart';

abstract class EvaluationsRepository {
  Future<List<Evaluation>> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
  });

  Future<EvaluationStats> getEvaluationStats({int? assignedUserId});
  Future<Evaluation> createEvaluation(Evaluation evaluation);
  Future<String> createEvaluationLink(int typeId, {
    int? clientId,
    int? assignedUserId,
    int? ticketId,
    String channel = 'whatsapp',
    String? noteForClient,
  });

  Future<List<EvaluationType>> getTypes();
  Future<EvaluationType> createType(EvaluationType type);
  Future<EvaluationType> updateType(int id, EvaluationType type);
  Future<void> deleteType(int id);
}
