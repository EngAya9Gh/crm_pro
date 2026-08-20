import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class AddClient {
  final ClientsRepository repository;

  AddClient(this.repository);

  Future<Either<Failure, Client>> call(Client client) async {
    return await repository.addClient(client);
  }
}
