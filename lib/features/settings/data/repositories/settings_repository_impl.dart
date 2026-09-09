import 'package:dartz/dartz.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../domain/entities/product.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/integrations_entity.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  // --- Helpers ---
  Failure _handleError(dynamic error) {
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    } else if (error is UnauthorizedException) {
      return AuthFailure(error.message);
    } else if (error is ApiException) {
      return ServerFailure(error.message);
    }
    return ServerFailure(error.toString());
  }

  // --- Statuses ---
  @override
  Future<Either<Failure, List<StatusEntity>>> getClientStatuses() async {
    try {
      final result = await remoteDataSource.getClientStatuses();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, StatusEntity>> createClientStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createClientStatus(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, StatusEntity>> updateClientStatus(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateClientStatus(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClientStatus(int id) async {
    try {
      await remoteDataSource.deleteClientStatus(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Sources ---
  @override
  Future<Either<Failure, List<SourceEntity>>> getSources() async {
    try {
      final result = await remoteDataSource.getSources();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, SourceEntity>> createSource(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createSource(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, SourceEntity>> updateSource(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateSource(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSource(int id) async {
    try {
      await remoteDataSource.deleteSource(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Behaviors ---
  @override
  Future<Either<Failure, List<BehaviorEntity>>> getBehaviors() async {
    try {
      final result = await remoteDataSource.getBehaviors();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BehaviorEntity>> createBehavior(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createBehavior(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, BehaviorEntity>> updateBehavior(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateBehavior(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBehavior(int id) async {
    try {
      await remoteDataSource.deleteBehavior(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Invalid Reasons ---
  @override
  Future<Either<Failure, List<InvalidReasonEntity>>> getInvalidReasons() async {
    try {
      final result = await remoteDataSource.getInvalidReasons();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, InvalidReasonEntity>> createInvalidReason(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createInvalidReason(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, InvalidReasonEntity>> updateInvalidReason(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateInvalidReason(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvalidReason(int id) async {
    try {
      await remoteDataSource.deleteInvalidReason(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Regions ---
  @override
  Future<Either<Failure, List<RegionEntity>>> getRegions() async {
    try {
      final result = await remoteDataSource.getRegions();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RegionEntity>> createRegion(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createRegion(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RegionEntity>> updateRegion(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateRegion(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegion(int id) async {
    try {
      await remoteDataSource.deleteRegion(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Cities ---
  @override
  Future<Either<Failure, List<CityEntity>>> getCities({int? regionId}) async {
    try {
      final result = await remoteDataSource.getCities(regionId: regionId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> createCity(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createCity(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> updateCity(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateCity(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCity(int id) async {
    try {
      await remoteDataSource.deleteCity(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Tags ---
  @override
  Future<Either<Failure, List<TagEntity>>> getClientTags() async {
    try {
      final result = await remoteDataSource.getClientTags();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> createClientTag(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createClientTag(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> updateClientTag(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateClientTag(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClientTag(int id) async {
    try {
      await remoteDataSource.deleteClientTag(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Products ---
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final result = await remoteDataSource.getProducts();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createProduct(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateProduct(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Invoice Tags ---
  @override
  Future<Either<Failure, List<InvoiceTagEntity>>> getInvoiceTags() async {
    try {
      final result = await remoteDataSource.getInvoiceTags();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, InvoiceTagEntity>> createInvoiceTag(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createInvoiceTag(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, InvoiceTagEntity>> updateInvoiceTag(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateInvoiceTag(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoiceTag(int id) async {
    try {
      await remoteDataSource.deleteInvoiceTag(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Comment Types ---
  @override
  Future<Either<Failure, List<CommentTypeEntity>>> getCommentTypes() async {
    try {
      final result = await remoteDataSource.getCommentTypes();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CommentTypeEntity>> createCommentType(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createCommentType(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, CommentTypeEntity>> updateCommentType(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateCommentType(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentType(int id) async {
    try {
      await remoteDataSource.deleteCommentType(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Teams ---
  @override
  Future<Either<Failure, List<TeamEntity>>> getTeams() async {
    try {
      final result = await remoteDataSource.getTeams();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> createTeam(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createTeam(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> updateTeam(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateTeam(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam(int id) async {
    try {
      await remoteDataSource.deleteTeam(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Roles ---
  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles({int? teamId}) async {
    try {
      final result = await remoteDataSource.getRoles(teamId: teamId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> createRole(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.createRole(data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, RoleEntity>> updateRole(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDataSource.updateRole(id, data);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(int id) async {
    try {
      await remoteDataSource.deleteRole(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Permissions ---
  @override
  Future<Either<Failure, List<PermissionEntity>>> getPermissions() async {
    try {
      final result = await remoteDataSource.getPermissions();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // --- Employees ---
  @override
  Future<Either<Failure, List<User>>> getEmployees() async {
    try {
      final result = await remoteDataSource.getEmployees();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
  // --- Integrations ---
  @override
  Future<Either<Failure, IntegrationsEntity>> getIntegrations() async {
    try {
      final result = await remoteDataSource.getIntegrations();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateIntegration(
    String platform,
    Map<String, dynamic> data,
  ) async {
    try {
      await remoteDataSource.updateIntegration(platform, data);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}
