import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/evaluations_usecases.dart';
import '../../domain/entities/evaluation.dart';
import 'evaluations_state.dart';

class EvaluationsCubit extends Cubit<EvaluationsState> {
  final GetEvaluationsUseCase getEvaluationsUseCase;
  final GetEvaluationStatsUseCase getEvaluationStatsUseCase;
  final CreateEvaluationUseCase createEvaluationUseCase;
  final CreateEvaluationLinkUseCase createEvaluationLinkUseCase;

  int _currentPage = 1;
  bool _hasMorePages = false;
  List<Evaluation> _allEvaluations = [];

  EvaluationsCubit({
    required this.getEvaluationsUseCase,
    required this.getEvaluationStatsUseCase,
    required this.createEvaluationUseCase,
    required this.createEvaluationLinkUseCase,
  }) : super(EvaluationsInitial());

  Future<void> getEvaluations({
    int? clientId,
    int? assignedUserId,
    int? typeId,
    int? rating,
    bool refresh = true,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _allEvaluations = [];
      emit(EvaluationsLoading());
    }

    try {
      final response = await getEvaluationsUseCase(
        clientId: clientId,
        assignedUserId: assignedUserId,
        typeId: typeId,
        rating: rating,
        page: _currentPage,
      );
      final stats = await getEvaluationStatsUseCase(assignedUserId: assignedUserId);

      if (response.data != null) {
        if (refresh) {
          _allEvaluations = response.data!;
        } else {
          _allEvaluations = [..._allEvaluations, ...response.data!];
        }
        _hasMorePages = response.meta != null && _currentPage < response.meta!.lastPage;
      }

      emit(EvaluationsLoaded(_allEvaluations, stats, meta: response.meta, currentPage: _currentPage));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }

  Future<void> loadNextPage({int? clientId, int? assignedUserId, int? typeId, int? rating}) async {
    if (!_hasMorePages) return;
    _currentPage++;
    await getEvaluations(
      clientId: clientId,
      assignedUserId: assignedUserId,
      typeId: typeId,
      rating: rating,
      refresh: false,
    );
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
      emit(EvaluationOperationSuccess(link));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    }
  }
}
