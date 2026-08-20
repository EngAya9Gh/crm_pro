import 'package:dartz/dartz.dart';
import 'package:crm_wakeel/core/common/models/paginated_list.dart';
import 'package:crm_wakeel/core/error/failures.dart';
import '../entities/user.dart';

abstract class UsersRepository {
  Future<Either<Failure, PaginatedList<User>>> getUsers({
    String? search,
    int? teamId,
    int? roleId,
    int? isActive,
    int page = 1,
  });

  Future<Either<Failure, User>> createUser(Map<String, dynamic> data);

  Future<Either<Failure, User>> getUserDetails(int id);

  Future<Either<Failure, User>> updateUser(int id, Map<String, dynamic> data);
}
