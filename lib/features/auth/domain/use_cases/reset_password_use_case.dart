import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<String, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      params.email,
      params.password,
      params.passwordConfirmation,
      params.token,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String password;
  final String passwordConfirmation;
  final String token;

  const ResetPasswordParams({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.token,
  });

  @override
  List<Object?> get props => [email, password, passwordConfirmation, token];
}
