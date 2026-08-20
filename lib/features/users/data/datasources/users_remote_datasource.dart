import 'package:crm_wakeel/core/common/models/paginated_list.dart';
import 'package:crm_wakeel/core/services/network/api_client.dart';
import 'package:crm_wakeel/core/utils/end_points.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<PaginatedList<UserModel>> getUsers({
    String? search,
    int? teamId,
    int? roleId,
    int? isActive,
    int page = 1,
  });

  Future<UserModel> createUser(Map<String, dynamic> data);

  Future<UserModel> getUserDetails(int id);

  Future<UserModel> updateUser(int id, Map<String, dynamic> data);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient apiClient;

  UsersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedList<UserModel>> getUsers({
    String? search,
    int? teamId,
    int? roleId,
    int? isActive,
    int page = 1,
  }) async {
    final response = await apiClient.get<List<UserModel>>(
      EndPoints.users,
      queryParameters: {
        if (search != null) 'search': search,
        if (teamId != null) 'team_id': teamId,
        if (roleId != null) 'role_id': roleId,
        if (isActive != null) 'is_active': isActive,
        'page': page,
      },
      fromJson: (json) =>
          (json as List).map((e) => UserModel.fromJson(e)).toList(),
    );

    return PaginatedList(
      items: response.data ?? [],
      total: response.meta?.total ?? 0,
      currentPage: response.meta?.currentPage ?? 1,
      perPage: response.meta?.perPage ?? 15,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await apiClient.post<UserModel>(
      EndPoints.users,
      data: data,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<UserModel> getUserDetails(int id) async {
    final response = await apiClient.get<UserModel>(
      EndPoints.user(id.toString()),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await apiClient.put<UserModel>(
      EndPoints.user(id.toString()),
      data: data,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }
}
