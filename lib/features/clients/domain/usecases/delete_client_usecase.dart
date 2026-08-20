import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clients_repository.dart';

class DeleteClient {
  final ClientsRepository repository;

  DeleteClient(this.repository);

  Future<Either<Failure, void>> call(String clientId) async {
    return await repository.deleteClient(clientId);
  }
}
