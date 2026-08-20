import 'package:dartz/dartz.dart';
import '../../../../core/common/models/paginated_list.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, PaginatedList<User>>> call({
    String? search,
    int? teamId,
    int? roleId,
    int? isActive,
    int page = 1,
  }) {
    return repository.getUsers(
      search: search,
      teamId: teamId,
      roleId: roleId,
      isActive: isActive,
      page: page,
    );
  }
}
