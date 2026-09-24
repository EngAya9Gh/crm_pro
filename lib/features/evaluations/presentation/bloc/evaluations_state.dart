import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../domain/entities/evaluation_type.dart';

abstract class EvaluationsState {}

class EvaluationsInitial extends EvaluationsState {}

class EvaluationsLoading extends EvaluationsState {}

class EvaluationsLoaded extends EvaluationsState {
  final List<Evaluation> evaluations;
  final EvaluationStats stats;
  EvaluationsLoaded(this.evaluations, this.stats);
}

class EvaluationTypesLoaded extends EvaluationsState {
  final List<EvaluationType> types;
  EvaluationTypesLoaded(this.types);
}

class EvaluationsError extends EvaluationsState {
  final String message;
  EvaluationsError(this.message);
}

class EvaluationOperationSuccess extends EvaluationsState {
  final String message;
  EvaluationOperationSuccess(this.message);
}
