import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class ChangeClientStatus {
  final ClientsRepository repository;

  ChangeClientStatus(this.repository);

  Future<Either<Failure, void>> call(String clientId, int statusId) async {
    return await repository.changeClientStatus(clientId, statusId);
  }
}
