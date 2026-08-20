import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/timeline_event.dart';
import '../repositories/clients_repository.dart';

class GetClientTimelineUseCase {
  final ClientsRepository repository;

  GetClientTimelineUseCase(this.repository);

  Future<Either<Failure, List<TimelineEvent>>> call(String clientId) async {
    return await repository.getTimeline(clientId);
  }
}
