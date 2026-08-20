import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_procedure.dart';
import '../repositories/clients_repository.dart';

class AddProcedureUseCase {
  final ClientsRepository repository;

  AddProcedureUseCase(this.repository);

  Future<Either<Failure, ClientProcedure>> call(
    String clientId,
    ClientProcedure procedure,
  ) async {
    return await repository.addProcedure(clientId, procedure);
  }
}
