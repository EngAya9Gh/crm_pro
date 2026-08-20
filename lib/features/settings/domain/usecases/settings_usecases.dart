import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../domain/entities/product.dart';
import '../../../users/domain/entities/user.dart';

// --- Statuses ---
class GetClientStatusesUseCase {
  final SettingsRepository repository;
  GetClientStatusesUseCase(this.repository);
  Future<Either<Failure, List<StatusEntity>>> call() =>
      repository.getClientStatuses();
}

class CreateClientStatusUseCase {
  final SettingsRepository repository;
  CreateClientStatusUseCase(this.repository);
  Future<Either<Failure, StatusEntity>> call(Map<String, dynamic> data) =>
      repository.createClientStatus(data);
}

class UpdateClientStatusUseCase {
  final SettingsRepository repository;
  UpdateClientStatusUseCase(this.repository);
  Future<Either<Failure, StatusEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateClientStatus(id, data);
}

class DeleteClientStatusUseCase {
  final SettingsRepository repository;
  DeleteClientStatusUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) =>
      repository.deleteClientStatus(id);
}

// --- Sources ---
class GetSourcesUseCase {
  final SettingsRepository repository;
  GetSourcesUseCase(this.repository);
  Future<Either<Failure, List<SourceEntity>>> call() => repository.getSources();
}

class CreateSourceUseCase {
  final SettingsRepository repository;
  CreateSourceUseCase(this.repository);
  Future<Either<Failure, SourceEntity>> call(Map<String, dynamic> data) =>
      repository.createSource(data);
}

class UpdateSourceUseCase {
  final SettingsRepository repository;
  UpdateSourceUseCase(this.repository);
  Future<Either<Failure, SourceEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateSource(id, data);
}

class DeleteSourceUseCase {
  final SettingsRepository repository;
  DeleteSourceUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteSource(id);
}

// --- Behaviors ---
class GetBehaviorsUseCase {
  final SettingsRepository repository;
  GetBehaviorsUseCase(this.repository);
  Future<Either<Failure, List<BehaviorEntity>>> call() =>
      repository.getBehaviors();
}

class CreateBehaviorUseCase {
  final SettingsRepository repository;
  CreateBehaviorUseCase(this.repository);
  Future<Either<Failure, BehaviorEntity>> call(Map<String, dynamic> data) =>
      repository.createBehavior(data);
}

class UpdateBehaviorUseCase {
  final SettingsRepository repository;
  UpdateBehaviorUseCase(this.repository);
  Future<Either<Failure, BehaviorEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateBehavior(id, data);
}

class DeleteBehaviorUseCase {
  final SettingsRepository repository;
  DeleteBehaviorUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteBehavior(id);
}

// --- Invalid Reasons ---
class GetInvalidReasonsUseCase {
  final SettingsRepository repository;
  GetInvalidReasonsUseCase(this.repository);
  Future<Either<Failure, List<InvalidReasonEntity>>> call() =>
      repository.getInvalidReasons();
}

class CreateInvalidReasonUseCase {
  final SettingsRepository repository;
  CreateInvalidReasonUseCase(this.repository);
  Future<Either<Failure, InvalidReasonEntity>> call(
    Map<String, dynamic> data,
  ) => repository.createInvalidReason(data);
}

class UpdateInvalidReasonUseCase {
  final SettingsRepository repository;
  UpdateInvalidReasonUseCase(this.repository);
  Future<Either<Failure, InvalidReasonEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateInvalidReason(id, data);
}

class DeleteInvalidReasonUseCase {
  final SettingsRepository repository;
  DeleteInvalidReasonUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) =>
      repository.deleteInvalidReason(id);
}

// --- Regions ---
class GetRegionsUseCase {
  final SettingsRepository repository;
  GetRegionsUseCase(this.repository);
  Future<Either<Failure, List<RegionEntity>>> call() => repository.getRegions();
}

class CreateRegionUseCase {
  final SettingsRepository repository;
  CreateRegionUseCase(this.repository);
  Future<Either<Failure, RegionEntity>> call(Map<String, dynamic> data) =>
      repository.createRegion(data);
}

class UpdateRegionUseCase {
  final SettingsRepository repository;
  UpdateRegionUseCase(this.repository);
  Future<Either<Failure, RegionEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateRegion(id, data);
}

class DeleteRegionUseCase {
  final SettingsRepository repository;
  DeleteRegionUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteRegion(id);
}

// --- Cities ---
class GetCitiesUseCase {
  final SettingsRepository repository;
  GetCitiesUseCase(this.repository);
  Future<Either<Failure, List<CityEntity>>> call({int? regionId}) =>
      repository.getCities(regionId: regionId);
}

class CreateCityUseCase {
  final SettingsRepository repository;
  CreateCityUseCase(this.repository);
  Future<Either<Failure, CityEntity>> call(Map<String, dynamic> data) =>
      repository.createCity(data);
}

class UpdateCityUseCase {
  final SettingsRepository repository;
  UpdateCityUseCase(this.repository);
  Future<Either<Failure, CityEntity>> call(int id, Map<String, dynamic> data) =>
      repository.updateCity(id, data);
}

class DeleteCityUseCase {
  final SettingsRepository repository;
  DeleteCityUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteCity(id);
}

// --- Tags ---
class GetClientTagsUseCase {
  final SettingsRepository repository;
  GetClientTagsUseCase(this.repository);
  Future<Either<Failure, List<TagEntity>>> call() => repository.getClientTags();
}

class CreateClientTagUseCase {
  final SettingsRepository repository;
  CreateClientTagUseCase(this.repository);
  Future<Either<Failure, TagEntity>> call(Map<String, dynamic> data) =>
      repository.createClientTag(data);
}

class UpdateClientTagUseCase {
  final SettingsRepository repository;
  UpdateClientTagUseCase(this.repository);
  Future<Either<Failure, TagEntity>> call(int id, Map<String, dynamic> data) =>
      repository.updateClientTag(id, data);
}

class DeleteClientTagUseCase {
  final SettingsRepository repository;
  DeleteClientTagUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteClientTag(id);
}

// --- Products ---
class GetProductsUseCase {
  final SettingsRepository repository;
  GetProductsUseCase(this.repository);
  Future<Either<Failure, List<Product>>> call() => repository.getProducts();
}

class CreateProductUseCase {
  final SettingsRepository repository;
  CreateProductUseCase(this.repository);
  Future<Either<Failure, Product>> call(Map<String, dynamic> data) =>
      repository.createProduct(data);
}

class UpdateProductUseCase {
  final SettingsRepository repository;
  UpdateProductUseCase(this.repository);
  Future<Either<Failure, Product>> call(int id, Map<String, dynamic> data) =>
      repository.updateProduct(id, data);
}

class DeleteProductUseCase {
  final SettingsRepository repository;
  DeleteProductUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteProduct(id);
}

// --- Invoice Tags ---
class GetInvoiceTagsUseCase {
  final SettingsRepository repository;
  GetInvoiceTagsUseCase(this.repository);
  Future<Either<Failure, List<InvoiceTagEntity>>> call() =>
      repository.getInvoiceTags();
}

class CreateInvoiceTagUseCase {
  final SettingsRepository repository;
  CreateInvoiceTagUseCase(this.repository);
  Future<Either<Failure, InvoiceTagEntity>> call(Map<String, dynamic> data) =>
      repository.createInvoiceTag(data);
}

class UpdateInvoiceTagUseCase {
  final SettingsRepository repository;
  UpdateInvoiceTagUseCase(this.repository);
  Future<Either<Failure, InvoiceTagEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateInvoiceTag(id, data);
}

class DeleteInvoiceTagUseCase {
  final SettingsRepository repository;
  DeleteInvoiceTagUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteInvoiceTag(id);
}

// --- Comment Types ---
class GetCommentTypesUseCase {
  final SettingsRepository repository;
  GetCommentTypesUseCase(this.repository);
  Future<Either<Failure, List<CommentTypeEntity>>> call() =>
      repository.getCommentTypes();
}

class CreateCommentTypeUseCase {
  final SettingsRepository repository;
  CreateCommentTypeUseCase(this.repository);
  Future<Either<Failure, CommentTypeEntity>> call(Map<String, dynamic> data) =>
      repository.createCommentType(data);
}

class UpdateCommentTypeUseCase {
  final SettingsRepository repository;
  UpdateCommentTypeUseCase(this.repository);
  Future<Either<Failure, CommentTypeEntity>> call(
    int id,
    Map<String, dynamic> data,
  ) => repository.updateCommentType(id, data);
}

class DeleteCommentTypeUseCase {
  final SettingsRepository repository;
  DeleteCommentTypeUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) =>
      repository.deleteCommentType(id);
}

// --- Teams ---
class GetTeamsUseCase {
  final SettingsRepository repository;
  GetTeamsUseCase(this.repository);
  Future<Either<Failure, List<TeamEntity>>> call() => repository.getTeams();
}

class CreateTeamUseCase {
  final SettingsRepository repository;
  CreateTeamUseCase(this.repository);
  Future<Either<Failure, TeamEntity>> call(Map<String, dynamic> data) =>
      repository.createTeam(data);
}

class UpdateTeamUseCase {
  final SettingsRepository repository;
  UpdateTeamUseCase(this.repository);
  Future<Either<Failure, TeamEntity>> call(int id, Map<String, dynamic> data) =>
      repository.updateTeam(id, data);
}

class DeleteTeamUseCase {
  final SettingsRepository repository;
  DeleteTeamUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteTeam(id);
}

// --- Roles ---
class GetRolesUseCase {
  final SettingsRepository repository;
  GetRolesUseCase(this.repository);
  Future<Either<Failure, List<RoleEntity>>> call({int? teamId}) =>
      repository.getRoles(teamId: teamId);
}

class CreateRoleUseCase {
  final SettingsRepository repository;
  CreateRoleUseCase(this.repository);
  Future<Either<Failure, RoleEntity>> call(Map<String, dynamic> data) =>
      repository.createRole(data);
}

class UpdateRoleUseCase {
  final SettingsRepository repository;
  UpdateRoleUseCase(this.repository);
  Future<Either<Failure, RoleEntity>> call(int id, Map<String, dynamic> data) =>
      repository.updateRole(id, data);
}

class DeleteRoleUseCase {
  final SettingsRepository repository;
  DeleteRoleUseCase(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteRole(id);
}

// --- Permissions ---
class GetPermissionsUseCase {
  final SettingsRepository repository;
  GetPermissionsUseCase(this.repository);
  Future<Either<Failure, List<PermissionEntity>>> call() =>
      repository.getPermissions();
}

// --- Employees ---
class GetEmployeesUseCase {
  final SettingsRepository repository;
  GetEmployeesUseCase(this.repository);
  Future<Either<Failure, List<User>>> call() => repository.getEmployees();
}
