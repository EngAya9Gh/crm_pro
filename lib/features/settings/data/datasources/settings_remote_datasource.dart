import '../../../users/data/models/user_model.dart' as users;
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../../data/models/lookup_models.dart';
import '../models/product_model.dart';

abstract class SettingsRemoteDataSource {
  // Statuses
  Future<List<StatusModel>> getClientStatuses();
  Future<StatusModel> createClientStatus(Map<String, dynamic> data);
  Future<StatusModel> updateClientStatus(int id, Map<String, dynamic> data);
  Future<void> deleteClientStatus(int id);

  // Sources
  Future<List<SourceModel>> getSources();
  Future<SourceModel> createSource(Map<String, dynamic> data);
  Future<SourceModel> updateSource(int id, Map<String, dynamic> data);
  Future<void> deleteSource(int id);

  // Behaviors
  Future<List<BehaviorModel>> getBehaviors();
  Future<BehaviorModel> createBehavior(Map<String, dynamic> data);
  Future<BehaviorModel> updateBehavior(int id, Map<String, dynamic> data);
  Future<void> deleteBehavior(int id);

  // Invalid Reasons
  Future<List<InvalidReasonModel>> getInvalidReasons();
  Future<InvalidReasonModel> createInvalidReason(Map<String, dynamic> data);
  Future<InvalidReasonModel> updateInvalidReason(
    int id,
    Map<String, dynamic> data,
  );
  Future<void> deleteInvalidReason(int id);

  // Regions
  Future<List<RegionModel>> getRegions();
  Future<RegionModel> createRegion(Map<String, dynamic> data);
  Future<RegionModel> updateRegion(int id, Map<String, dynamic> data);
  Future<void> deleteRegion(int id);

  // Cities
  Future<List<CityModel>> getCities({int? regionId});
  Future<CityModel> createCity(Map<String, dynamic> data);
  Future<CityModel> updateCity(int id, Map<String, dynamic> data);
  Future<void> deleteCity(int id);

  // Tags
  Future<List<TagModel>> getClientTags();
  Future<TagModel> createClientTag(Map<String, dynamic> data);
  Future<TagModel> updateClientTag(int id, Map<String, dynamic> data);
  Future<void> deleteClientTag(int id);

  // Products
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data);
  Future<void> deleteProduct(int id);

  // Invoice Tags
  Future<List<InvoiceTagModel>> getInvoiceTags();
  Future<InvoiceTagModel> createInvoiceTag(Map<String, dynamic> data);
  Future<InvoiceTagModel> updateInvoiceTag(int id, Map<String, dynamic> data);
  Future<void> deleteInvoiceTag(int id);

  // Comment Types
  Future<List<CommentTypeModel>> getCommentTypes();
  Future<CommentTypeModel> createCommentType(Map<String, dynamic> data);
  Future<CommentTypeModel> updateCommentType(int id, Map<String, dynamic> data);
  Future<void> deleteCommentType(int id);

  // Teams
  Future<List<TeamModel>> getTeams();
  Future<TeamModel> createTeam(Map<String, dynamic> data);
  Future<TeamModel> updateTeam(int id, Map<String, dynamic> data);
  Future<void> deleteTeam(int id);

  // Roles
  Future<List<RoleModel>> getRoles({int? teamId});
  Future<RoleModel> createRole(Map<String, dynamic> data);
  Future<RoleModel> updateRole(int id, Map<String, dynamic> data);
  Future<void> deleteRole(int id);

  // Permissions
  Future<List<PermissionModel>> getPermissions();

  // Employees
  Future<List<users.UserModel>> getEmployees();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl({required this.apiClient});

  // --- Statuses ---
  @override
  Future<List<StatusModel>> getClientStatuses() async {
    final response = await apiClient.get(
      EndPoints.settingsStatuses,
      fromJson: (json) =>
          (json as List).map((e) => StatusModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<StatusModel> createClientStatus(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsStatuses,
      data: data,
      fromJson: (json) => StatusModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<StatusModel> updateClientStatus(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.settingsStatus(id.toString()),
      data: data,
      fromJson: (json) => StatusModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteClientStatus(int id) async {
    await apiClient.delete(
      EndPoints.settingsStatus(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Sources ---
  @override
  Future<List<SourceModel>> getSources() async {
    final response = await apiClient.get(
      EndPoints.settingsSources,
      fromJson: (json) =>
          (json as List).map((e) => SourceModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<SourceModel> createSource(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsSources,
      data: data,
      fromJson: (json) => SourceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<SourceModel> updateSource(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsSource(id.toString()),
      data: data,
      fromJson: (json) => SourceModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteSource(int id) async {
    await apiClient.delete(
      EndPoints.settingsSource(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Behaviors ---
  @override
  Future<List<BehaviorModel>> getBehaviors() async {
    final response = await apiClient.get(
      EndPoints.settingsBehaviors,
      fromJson: (json) =>
          (json as List).map((e) => BehaviorModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<BehaviorModel> createBehavior(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsBehaviors,
      data: data,
      fromJson: (json) => BehaviorModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<BehaviorModel> updateBehavior(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.settingsBehavior(id.toString()),
      data: data,
      fromJson: (json) => BehaviorModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteBehavior(int id) async {
    await apiClient.delete(
      EndPoints.settingsBehavior(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Invalid Reasons ---
  @override
  Future<List<InvalidReasonModel>> getInvalidReasons() async {
    final response = await apiClient.get(
      EndPoints.settingsInvalidReasons,
      fromJson: (json) =>
          (json as List).map((e) => InvalidReasonModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<InvalidReasonModel> createInvalidReason(
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      EndPoints.settingsInvalidReasons,
      data: data,
      fromJson: (json) =>
          InvalidReasonModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<InvalidReasonModel> updateInvalidReason(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.settingsInvalidReason(id.toString()),
      data: data,
      fromJson: (json) =>
          InvalidReasonModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteInvalidReason(int id) async {
    await apiClient.delete(
      EndPoints.settingsInvalidReason(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Regions ---
  @override
  Future<List<RegionModel>> getRegions() async {
    final response = await apiClient.get(
      EndPoints.settingsRegions,
      fromJson: (json) =>
          (json as List).map((e) => RegionModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<RegionModel> createRegion(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsRegions,
      data: data,
      fromJson: (json) => RegionModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<RegionModel> updateRegion(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsRegion(id.toString()),
      data: data,
      fromJson: (json) => RegionModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteRegion(int id) async {
    await apiClient.delete(
      EndPoints.settingsRegion(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Cities ---
  @override
  Future<List<CityModel>> getCities({int? regionId}) async {
    final queryParams = regionId != null ? {'region_id': regionId} : null;
    final response = await apiClient.get(
      EndPoints.settingsCities,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => CityModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<CityModel> createCity(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsCities,
      data: data,
      fromJson: (json) => CityModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<CityModel> updateCity(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsCity(id.toString()),
      data: data,
      fromJson: (json) => CityModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteCity(int id) async {
    await apiClient.delete(
      EndPoints.settingsCity(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Tags ---
  @override
  Future<List<TagModel>> getClientTags() async {
    final response = await apiClient.get(
      EndPoints.settingsTags,
      fromJson: (json) =>
          (json as List).map((e) => TagModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<TagModel> createClientTag(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsTags,
      data: data,
      fromJson: (json) => TagModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<TagModel> updateClientTag(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsTag(id.toString()),
      data: data,
      fromJson: (json) => TagModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteClientTag(int id) async {
    await apiClient.delete(
      EndPoints.settingsTag(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Products ---
  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await apiClient.get(
      EndPoints.settingsProducts,
      fromJson: (json) =>
          (json as List).map((e) => ProductModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsProducts,
      data: data,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsProduct(id.toString()),
      data: data,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await apiClient.delete(
      EndPoints.settingsProduct(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Invoice Tags ---
  @override
  Future<List<InvoiceTagModel>> getInvoiceTags() async {
    final response = await apiClient.get(
      EndPoints.settingsInvoiceTags,
      fromJson: (json) =>
          (json as List).map((e) => InvoiceTagModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<InvoiceTagModel> createInvoiceTag(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsInvoiceTags,
      data: data,
      fromJson: (json) =>
          InvoiceTagModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<InvoiceTagModel> updateInvoiceTag(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.settingsInvoiceTag(id.toString()),
      data: data,
      fromJson: (json) =>
          InvoiceTagModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteInvoiceTag(int id) async {
    await apiClient.delete(
      EndPoints.settingsInvoiceTag(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Comment Types ---
  @override
  Future<List<CommentTypeModel>> getCommentTypes() async {
    final response = await apiClient.get(
      EndPoints.settingsCommentTypes,
      fromJson: (json) =>
          (json as List).map((e) => CommentTypeModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<CommentTypeModel> createCommentType(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsCommentTypes,
      data: data,
      fromJson: (json) =>
          CommentTypeModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<CommentTypeModel> updateCommentType(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      EndPoints.settingsCommentType(id.toString()),
      data: data,
      fromJson: (json) =>
          CommentTypeModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteCommentType(int id) async {
    await apiClient.delete(
      EndPoints.settingsCommentType(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Teams ---
  @override
  Future<List<TeamModel>> getTeams() async {
    final response = await apiClient.get(
      EndPoints.settingsTeams,
      fromJson: (json) =>
          (json as List).map((e) => TeamModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<TeamModel> createTeam(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsTeams,
      data: data,
      fromJson: (json) => TeamModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<TeamModel> updateTeam(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsTeam(id.toString()),
      data: data,
      fromJson: (json) => TeamModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteTeam(int id) async {
    await apiClient.delete(
      EndPoints.settingsTeam(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Roles ---
  @override
  Future<List<RoleModel>> getRoles({int? teamId}) async {
    final queryParams = teamId != null ? {'team_id': teamId} : null;
    final response = await apiClient.get(
      EndPoints.settingsRoles,
      queryParameters: queryParams,
      fromJson: (json) =>
          (json as List).map((e) => RoleModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  @override
  Future<RoleModel> createRole(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      EndPoints.settingsRoles,
      data: data,
      fromJson: (json) => RoleModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<RoleModel> updateRole(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      EndPoints.settingsRole(id.toString()),
      data: data,
      fromJson: (json) => RoleModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> deleteRole(int id) async {
    await apiClient.delete(
      EndPoints.settingsRole(id.toString()),
      fromJson: (json) => true,
    );
  }

  // --- Permissions ---
  @override
  Future<List<PermissionModel>> getPermissions() async {
    final response = await apiClient.get(
      EndPoints.settingsPermissions,
      fromJson: (json) =>
          (json as List).map((e) => PermissionModel.fromJson(e)).toList(),
    );
    return response.data!;
  }

  // --- Employees ---
  @override
  Future<List<users.UserModel>> getEmployees() async {
    final response = await apiClient.get(
      EndPoints.users,
      fromJson: (json) =>
          (json as List).map((e) => users.UserModel.fromJson(e)).toList(),
    );
    return response.data!;
  }
}
