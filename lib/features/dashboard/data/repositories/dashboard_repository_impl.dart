import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_chart_data.dart';
import '../../domain/entities/recent_activity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      final summary = await remoteDataSource.getSummary();
      return Right(summary);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DashboardChartData>> getCharts() async {
    try {
      final charts = await remoteDataSource.getCharts();
      return Right(charts);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentActivity>>> getRecentActivities() async {
    try {
      final activities = await remoteDataSource.getRecentActivities();
      return Right(activities);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
