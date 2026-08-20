import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout();
  Future<UserModel> getMe();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
    String token,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await apiClient.post(
      EndPoints.login,
      data: {'email': email, 'password': password},
      fromJson: (json) =>
          AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    // Usually refresh is done via interceptor, but if manual call is needed:
    final response = await apiClient.post(
      EndPoints.refresh,
      data: {'refresh_token': refreshToken},
      // Depending on API, refresh might return new tokens only or full user
      fromJson: (json) =>
          AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> logout() async {
    await apiClient.post(EndPoints.logout, fromJson: (json) => null);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await apiClient.get(
      EndPoints.me,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post(
      EndPoints.forgotPassword,
      data: {'email': email},
      fromJson: (json) => null,
    );
  }

  @override
  Future<void> resetPassword(
    String email,
    String password,
    String passwordConfirmation,
    String token,
  ) async {
    await apiClient.post(
      EndPoints.resetPassword,
      data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'token': token,
      },
      fromJson: (json) => null,
    );
  }
}
