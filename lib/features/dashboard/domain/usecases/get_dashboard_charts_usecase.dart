import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_chart_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardChartsUseCase {
  final DashboardRepository repository;

  GetDashboardChartsUseCase(this.repository);

  Future<Either<Failure, DashboardChartData>> call() async {
    return await repository.getCharts();
  }
}
