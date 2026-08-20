import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clients_repository.dart';

class DeleteProcedureUseCase {
  final ClientsRepository repository;

  DeleteProcedureUseCase(this.repository);

  Future<Either<Failure, void>> call(String clientId, int procedureId) async {
    return await repository.deleteProcedure(clientId, procedureId);
  }
}
