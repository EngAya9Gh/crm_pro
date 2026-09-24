import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/evaluations_usecases.dart';
import '../../domain/entities/evaluation.dart';
import 'evaluations_state.dart';

class EvaluationsCubit extends Cubit<EvaluationsState> {
  final GetEvaluationsUseCase getEvaluationsUseCase;
  final GetEvaluationStatsUseCase getEvaluationStatsUseCase;
  final CreateEvaluationUseCase createEvaluationUseCase;
  final CreateEvaluationLinkUseCase createEvaluationLinkUseCase;

  EvaluationsCubit({
    required this.getEvaluationsUseCase,
    required this.getEvaluationStatsUseCase,
    required this.createEvaluationUseCase,
    required this.createEvaluationLinkUseCase,
  }) : super(EvaluationsInitial());

  Future<void> getEvaluations({int? clientId, int? assignedUserId, int? typeId, int? rating}) async {
    emit(EvaluationsLoading());
    try {
      final evaluations = await getEvaluationsUseCase(
        clientId: clientId,
        assignedUserId: assignedUserId,
        typeId: typeId,
        rating: rating,
      );
      final stats = await getEvaluationStatsUseCase(assignedUserId: assignedUserId);
      emit(EvaluationsLoaded(evaluations, stats));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> createEvaluation(Evaluation evaluation) async {
    emit(EvaluationsLoading());
    try {
      await createEvaluationUseCase(evaluation);
      emit(EvaluationOperationSuccess('تم إضافة التقييم بنجاح'));
      getEvaluations();
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> createEvaluationLink(int typeId, {int? clientId, int? assignedUserId, int? ticketId, String channel = 'whatsapp', String? noteForClient}) async {
    try {
      final link = await createEvaluationLinkUseCase(
        typeId,
        clientId: clientId,
        assignedUserId: assignedUserId,
        ticketId: ticketId,
        channel: channel,
        noteForClient: noteForClient,
      );
      emit(EvaluationOperationSuccess('تم إنشاء رابط التقييم: $link'));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }
}
