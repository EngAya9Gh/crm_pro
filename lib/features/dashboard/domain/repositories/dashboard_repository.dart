import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_chart_data.dart';
import '../../domain/entities/recent_activity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getSummary();
  Future<Either<Failure, DashboardChartData>> getCharts();
  Future<Either<Failure, List<RecentActivity>>> getRecentActivities();
}
