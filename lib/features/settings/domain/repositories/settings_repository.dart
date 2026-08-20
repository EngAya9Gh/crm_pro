import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../domain/entities/product.dart';

abstract class SettingsRepository {
  // Statuses
  Future<Either<Failure, List<StatusEntity>>> getClientStatuses();
  Future<Either<Failure, StatusEntity>> createClientStatus(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, StatusEntity>> updateClientStatus(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteClientStatus(int id);

  // Sources
  Future<Either<Failure, List<SourceEntity>>> getSources();
  Future<Either<Failure, SourceEntity>> createSource(Map<String, dynamic> data);
  Future<Either<Failure, SourceEntity>> updateSource(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteSource(int id);

  // Behaviors
  Future<Either<Failure, List<BehaviorEntity>>> getBehaviors();
  Future<Either<Failure, BehaviorEntity>> createBehavior(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, BehaviorEntity>> updateBehavior(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteBehavior(int id);

  // Invalid Reasons
  Future<Either<Failure, List<InvalidReasonEntity>>> getInvalidReasons();
  Future<Either<Failure, InvalidReasonEntity>> createInvalidReason(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, InvalidReasonEntity>> updateInvalidReason(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteInvalidReason(int id);

  // Regions
  Future<Either<Failure, List<RegionEntity>>> getRegions();
  Future<Either<Failure, RegionEntity>> createRegion(Map<String, dynamic> data);
  Future<Either<Failure, RegionEntity>> updateRegion(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteRegion(int id);

  // Cities
  Future<Either<Failure, List<CityEntity>>> getCities({int? regionId});
  Future<Either<Failure, CityEntity>> createCity(Map<String, dynamic> data);
  Future<Either<Failure, CityEntity>> updateCity(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteCity(int id);

  // Tags
  Future<Either<Failure, List<TagEntity>>> getClientTags();
  Future<Either<Failure, TagEntity>> createClientTag(Map<String, dynamic> data);
  Future<Either<Failure, TagEntity>> updateClientTag(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteClientTag(int id);

  // Products
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> createProduct(Map<String, dynamic> data);
  Future<Either<Failure, Product>> updateProduct(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteProduct(int id);

  // Invoice Tags
  Future<Either<Failure, List<InvoiceTagEntity>>> getInvoiceTags();
  Future<Either<Failure, InvoiceTagEntity>> createInvoiceTag(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, InvoiceTagEntity>> updateInvoiceTag(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteInvoiceTag(int id);

  // Comment Types
  Future<Either<Failure, List<CommentTypeEntity>>> getCommentTypes();
  Future<Either<Failure, CommentTypeEntity>> createCommentType(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, CommentTypeEntity>> updateCommentType(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteCommentType(int id);

  // Teams
  Future<Either<Failure, List<TeamEntity>>> getTeams();
  Future<Either<Failure, TeamEntity>> createTeam(Map<String, dynamic> data);
  Future<Either<Failure, TeamEntity>> updateTeam(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteTeam(int id);

  // Roles
  Future<Either<Failure, List<RoleEntity>>> getRoles({int? teamId});
  Future<Either<Failure, RoleEntity>> createRole(Map<String, dynamic> data);
  Future<Either<Failure, RoleEntity>> updateRole(
    int id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deleteRole(int id);

  // Permissions
  Future<Either<Failure, List<PermissionEntity>>> getPermissions();

  // Employees
  Future<Either<Failure, List<User>>> getEmployees();
}
