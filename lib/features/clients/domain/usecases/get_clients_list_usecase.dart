import 'package:dartz/dartz.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_brief.dart';
import '../repositories/clients_repository.dart';

class GetClientsListUseCase {
  final ClientsRepository repository;

  GetClientsListUseCase(this.repository);

  Future<Either<Failure, PaginatedList<ClientBrief>>> call({
    int page = 1,
    int perPage = 15,
    String? search,
  }) {
    return repository.getClientsList(
      page: page,
      perPage: perPage,
      search: search,
    );
  }
}
