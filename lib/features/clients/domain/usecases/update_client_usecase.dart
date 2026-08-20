import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class UpdateClient {
  final ClientsRepository repository;

  UpdateClient(this.repository);

  Future<Either<Failure, Client>> call(Client client) async {
    return await repository.updateClient(client);
  }
}
