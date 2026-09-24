import '../entities/evaluation.dart';
import '../entities/evaluation_stats.dart';
import '../entities/evaluation_type.dart';
import '../repositories/evaluations_repository.dart';

class GetEvaluationsUseCase {
  final EvaluationsRepository repository;
  GetEvaluationsUseCase(this.repository);
  Future<List<Evaluation>> call({int? clientId, int? assignedUserId, int? typeId, int? rating}) {
    return repository.getEvaluations(clientId: clientId, assignedUserId: assignedUserId, typeId: typeId, rating: rating);
  }
}

class GetEvaluationStatsUseCase {
  final EvaluationsRepository repository;
  GetEvaluationStatsUseCase(this.repository);
  Future<EvaluationStats> call({int? assignedUserId}) {
    return repository.getEvaluationStats(assignedUserId: assignedUserId);
  }
}

class CreateEvaluationUseCase {
  final EvaluationsRepository repository;
  CreateEvaluationUseCase(this.repository);
  Future<Evaluation> call(Evaluation evaluation) {
    return repository.createEvaluation(evaluation);
  }
}

class CreateEvaluationLinkUseCase {
  final EvaluationsRepository repository;
  CreateEvaluationLinkUseCase(this.repository);
  Future<String> call(int typeId, {int? clientId, int? assignedUserId, int? ticketId, String channel = 'whatsapp', String? noteForClient}) {
    return repository.createEvaluationLink(typeId, clientId: clientId, assignedUserId: assignedUserId, ticketId: ticketId, channel: channel, noteForClient: noteForClient);
  }
}

class GetEvaluationTypesUseCase {
  final EvaluationsRepository repository;
  GetEvaluationTypesUseCase(this.repository);
  Future<List<EvaluationType>> call() {
    return repository.getTypes();
  }
}

class CreateEvaluationTypeUseCase {
  final EvaluationsRepository repository;
  CreateEvaluationTypeUseCase(this.repository);
  Future<EvaluationType> call(EvaluationType type) {
    return repository.createType(type);
  }
}

class UpdateEvaluationTypeUseCase {
  final EvaluationsRepository repository;
  UpdateEvaluationTypeUseCase(this.repository);
  Future<EvaluationType> call(int id, EvaluationType type) {
    return repository.updateType(id, type);
  }
}

class DeleteEvaluationTypeUseCase {
  final EvaluationsRepository repository;
  DeleteEvaluationTypeUseCase(this.repository);
  Future<void> call(int id) {
    return repository.deleteType(id);
  }
}
