import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_procedure.dart';
import '../repositories/clients_repository.dart';

class GetClientProceduresUseCase {
  final ClientsRepository repository;

  GetClientProceduresUseCase(this.repository);

  Future<Either<Failure, List<ClientProcedure>>> call(String clientId) async {
    return await repository.getProcedures(clientId);
  }
}
