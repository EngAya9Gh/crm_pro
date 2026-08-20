import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_file.dart';
import '../repositories/clients_repository.dart';

class GetClientFilesUseCase {
  final ClientsRepository repository;

  GetClientFilesUseCase(this.repository);

  Future<Either<Failure, List<ClientFile>>> call(String clientId) {
    return repository.getFiles(clientId);
  }
}
