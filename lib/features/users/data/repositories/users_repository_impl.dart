import 'package:dartz/dartz.dart';
import 'package:crm_wakeel/core/common/models/paginated_list.dart';
import 'package:crm_wakeel/core/error/api_exception.dart';
import 'package:crm_wakeel/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedList<User>>> getUsers({
    String? search,
    int? teamId,
    int? roleId,
    int? isActive,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.getUsers(
        search: search,
        teamId: teamId,
        roleId: roleId,
        isActive: isActive,
        page: page,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> createUser(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createUser(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> getUserDetails(int id) async {
    try {
      final result = await remoteDataSource.getUserDetails(id);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateUser(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    } else if (error is UnauthorizedException) {
      return AuthFailure(error.message);
    } else if (error is ApiException) {
      return ServerFailure(error.message); // Validation, NotFound, etc.
    }
    return ServerFailure(error.toString());
  }
}
