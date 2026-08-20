import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../entities/comment.dart';
import '../repositories/clients_repository.dart';

class GetClientCommentsUseCase {
  final ClientsRepository repository;

  GetClientCommentsUseCase(this.repository);

  Future<Either<Failure, PaginatedList<Comment>>> call({
    required String clientId,
    int page = 1,
    int perPage = 10,
  }) async {
    return await repository.getComments(
      clientId: clientId,
      page: page,
      perPage: perPage,
    );
  }
}
