import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_stats.dart';
import 'package:dartz/dartz.dart';

class GetClientStats {
  final ClientsRepository repository;

  GetClientStats(this.repository);

  Future<Either<Failure, ClientStats>> call() async {
    return await repository.getClientStats();
  }
}
