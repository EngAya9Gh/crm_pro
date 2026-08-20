import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import '../../domain/usecases/get_dashboard_charts_usecase.dart';
import '../../domain/usecases/get_recent_activities_usecase.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getSummary;
  final GetDashboardChartsUseCase getCharts;
  final GetRecentActivitiesUseCase getRecentActivities;

  DashboardBloc({
    required this.getSummary,
    required this.getCharts,
    required this.getRecentActivities,
  }) : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    print('🚀 DashboardBloc: Starting to load data...');
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final results = await Future.wait([
        getSummary(),
        getCharts(),
        getRecentActivities(),
      ]);

      print('✅ DashboardBloc: All API requests completed.');

      final summaryResult = results[0];
      final chartsResult = results[1];
      final activitiesResult = results[2];

      DashboardState newState = state.copyWith(status: DashboardStatus.success);

      summaryResult.fold(
        (failure) {
          print('❌ DashboardBloc: Summary failed: ${failure.message}');
          newState = newState.copyWith(
            errorMessage: failure.message,
            status: DashboardStatus.failure,
          );
        },
        (summary) {
          print('v DashboardBloc: Summary loaded successfully');
          newState = newState.copyWith(summary: summary as dynamic);
        },
      );

      chartsResult.fold(
        (failure) => print(
          '⚠️ DashboardBloc: Charts failed (optional): ${failure.message}',
        ),
        (charts) {
          print('v DashboardBloc: Charts loaded successfully');
          newState = newState.copyWith(charts: charts as dynamic);
        },
      );

      activitiesResult.fold(
        (failure) => print(
          '⚠️ DashboardBloc: Activities failed (optional): ${failure.message}',
        ),
        (activities) {
          print('v DashboardBloc: Recent activities loaded successfully');
          newState = newState.copyWith(recentActivities: activities as dynamic);
        },
      );

      print('📤 DashboardBloc: Emitting final state: ${newState.status}');
      emit(newState);
    } catch (e, stackTrace) {
      print('💥 DashboardBloc: Critical error: $e');
      print(stackTrace);
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'حدث خطأ غير متوقع: $e',
        ),
      );
    }
  }
}
