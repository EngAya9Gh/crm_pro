import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clients_repository.dart';
import '../entities/saved_filter.dart'; // for ClientFilter

class ExportClientsUseCase {
  final ClientsRepository repository;

  ExportClientsUseCase(this.repository);

  Future<Either<Failure, String>> call(
    ClientFilter? filter, {
    String format = 'csv',
  }) async {
    return await repository.exportClients(filter, format: format);
  }
}
