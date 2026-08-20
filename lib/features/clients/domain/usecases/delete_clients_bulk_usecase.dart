import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteClientsBulk {
  final ClientsRepository repository;

  DeleteClientsBulk(this.repository);

  Future<Either<Failure, void>> call(List<String> clientIds) async {
    return await repository.deleteClientsBulk(clientIds);
  }
}
