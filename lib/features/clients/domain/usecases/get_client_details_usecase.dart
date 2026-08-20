import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

class GetClientDetails {
  final ClientsRepository repository;

  GetClientDetails(this.repository);

  Future<Either<Failure, Client>> call(String id) async {
    return await repository.getClientDetails(id);
  }
}
