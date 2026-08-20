import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client_file.dart';
import '../repositories/clients_repository.dart';

class UploadClientFile {
  final ClientsRepository repository;

  UploadClientFile(this.repository);

  Future<Either<Failure, ClientFile>> call(
    String clientId,
    dynamic file,
    String type,
  ) async {
    return await repository.uploadFile(clientId, file, type);
  }
}
