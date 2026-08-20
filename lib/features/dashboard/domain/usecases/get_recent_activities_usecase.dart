import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recent_activity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentActivitiesUseCase {
  final DashboardRepository repository;

  GetRecentActivitiesUseCase(this.repository);

  Future<Either<Failure, List<RecentActivity>>> call() async {
    return await repository.getRecentActivities();
  }
}
