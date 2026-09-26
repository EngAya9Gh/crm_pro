import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../domain/entities/evaluation_type.dart';
import '../../../../core/services/network/api_response.dart';

abstract class EvaluationsState {}

class EvaluationsInitial extends EvaluationsState {}

class EvaluationsLoading extends EvaluationsState {}

class EvaluationsLoaded extends EvaluationsState {
  final List<Evaluation> evaluations;
  final EvaluationStats stats;
  final PaginationMeta? meta;
  final int currentPage;
  final bool isFetchingMore;
  EvaluationsLoaded(this.evaluations, this.stats, {this.meta, this.currentPage = 1, this.isFetchingMore = false});
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
