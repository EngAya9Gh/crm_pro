import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class GetUserDetailsUseCase {
  final UsersRepository repository;

  GetUserDetailsUseCase(this.repository);

  Future<Either<Failure, User>> call(int id) {
    return repository.getUserDetails(id);
  }
}
