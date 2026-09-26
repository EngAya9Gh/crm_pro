import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/evaluations_usecases.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import 'evaluations_state.dart';

class EvaluationsCubit extends Cubit<EvaluationsState> {
  final GetEvaluationsUseCase getEvaluationsUseCase;
  final GetEvaluationStatsUseCase getEvaluationStatsUseCase;
  final CreateEvaluationUseCase createEvaluationUseCase;
  final CreateEvaluationLinkUseCase createEvaluationLinkUseCase;

  int _currentPage = 1;
  bool _hasMorePages = false;
  bool _isFetching = false;
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
    bool fetchStats = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh) {
      _currentPage = 1;
      _allEvaluations = [];
      emit(EvaluationsLoading());
    } else {
      // For simplicity, we just pass dummy stats since we don't hold them in the Cubit yet,
      // but the state already holds them. We'll rely on the API or old stats if possible,
      // or we can use the last state's stats if it was EvaluationsLoaded.
      EvaluationStats oldStats = EvaluationStats(average: 0, total: 0, distribution: {});
      if (state is EvaluationsLoaded) {
        oldStats = (state as EvaluationsLoaded).stats;
      }
      emit(EvaluationsLoaded(_allEvaluations, oldStats, meta: null, currentPage: _currentPage, isFetchingMore: true));
    }

    try {
      final response = await getEvaluationsUseCase(
        clientId: clientId,
        assignedUserId: assignedUserId,
        typeId: typeId,
        rating: rating,
        page: _currentPage,
      );
      
      EvaluationStats? stats;
      if (fetchStats) {
        try {
          stats = await getEvaluationStatsUseCase(assignedUserId: assignedUserId);
        } catch (_) {
          // Ignore stats error so it doesn't crash the list
        }
      } else if (state is EvaluationsLoaded) {
        stats = (state as EvaluationsLoaded).stats;
      }

      if (response.data != null) {
        if (refresh) {
          _allEvaluations = response.data!;
        } else {
          _allEvaluations = [..._allEvaluations, ...response.data!];
        }
        _hasMorePages = response.meta != null && _currentPage < response.meta!.lastPage;
      }

      emit(EvaluationsLoaded(_allEvaluations, stats ?? EvaluationStats(average: 0, total: 0, distribution: {}), meta: response.meta, currentPage: _currentPage, isFetchingMore: false));
    } catch (e) {
      emit(EvaluationsError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadNextPage({int? clientId, int? assignedUserId, int? typeId, int? rating}) async {
    if (!_hasMorePages || _isFetching) return;
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
