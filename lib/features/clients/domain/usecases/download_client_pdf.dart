import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clients_repository.dart';

class DownloadClientPdf {
  final ClientsRepository repository;

  DownloadClientPdf(this.repository);

  Future<Either<Failure, String>> call(String clientId) async {
    return await repository.downloadClientPdf(clientId);
  }
}
