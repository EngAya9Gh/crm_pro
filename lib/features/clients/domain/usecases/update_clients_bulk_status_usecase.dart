import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateClientsBulkStatus {
  final ClientsRepository repository;

  UpdateClientsBulkStatus(this.repository);

  Future<Either<Failure, void>> call(
    List<String> clientIds,
    int statusId,
  ) async {
    return await repository.updateClientsBulkStatus(clientIds, statusId);
  }
}
