import 'package:crm_wakeel/core/error/failures.dart';
import 'package:crm_wakeel/features/clients/domain/entities/client.dart';
import 'package:crm_wakeel/features/clients/domain/entities/saved_filter.dart';
import 'package:crm_wakeel/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

import 'package:crm_wakeel/core/common/models/paginated_list.dart';

class GetClients {
  final ClientsRepository repository;

  GetClients(this.repository);

  Future<Either<Failure, PaginatedList<Client>>> call({
    ClientFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    return await repository.getClients(
      filter: filter,
      page: page,
      limit: limit,
    );
  }
}
