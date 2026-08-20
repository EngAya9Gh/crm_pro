import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/services/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<String, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(email, password);

      await tokenStorage.saveAccessToken(response.accessToken);
      await tokenStorage.saveRefreshToken(response.refreshToken);

      return Right(response.user);
    } on ApiException catch (e) {
      print("Login API Exception: ${e.message}");
      return Left(e.message);
    } catch (e, stackTrace) {
      print("Login Unexpected Error: $e");
      print(stackTrace);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await tokenStorage.clearTokens();
      return const Right(null);
    } on ApiException catch (e) {
      print("Logout API Exception: ${e.message}");
      return Left(e.message);
    } catch (e, stackTrace) {
      print("Logout Unexpected Error: $e");
      print(stackTrace);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> getMe() async {
    try {
      final user = await remoteDataSource.getMe();
      return Right(user);
    } on ApiException catch (e) {
      print("GetMe API Exception: ${e.message}");
      return Left(e.message);
    } catch (e, stackTrace) {
      print("GetMe Unexpected Error: $e");
      print(stackTrace);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
    String token,
  ) async {
    try {
      await remoteDataSource.resetPassword(
        email,
        password,
        passwordConfirmation,
        token,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
