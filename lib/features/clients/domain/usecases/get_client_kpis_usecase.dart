import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client_kpi.dart';
import 'package:dartz/dartz.dart';

class GetClientKPIs {
  final ClientsRepository repository;

  GetClientKPIs(this.repository);

  Future<Either<Failure, ClientKPI>> call() async {
    return await repository.getClientKPIs();
  }
}
