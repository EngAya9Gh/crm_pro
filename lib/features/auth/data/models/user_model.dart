import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.permissions,
    super.team,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'])
          : (json['role_id'] != null
                ? RoleModel(id: json['role_id'], name: 'Unknown')
                : const RoleModel(id: 0, name: 'Guest')),
      permissions: (json['permissions'] != null)
          ? Set<String>.from((json['permissions'] as List).map((e) => e is Map ? e['name'].toString() : e.toString()))
          : (json['permissions_list'] != null)
              ? Set<String>.from((json['permissions_list'] as List).map((e) => e.toString()))
              : const <String>{},
      team: json['team'] != null ? TeamModel.fromJson(json['team']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': (role as RoleModel).toJson(),
      'permissions': permissions.toList(),
      'team': team != null ? (team as TeamModel).toJson() : null,
    };
  }
}

class RoleModel extends RoleEntity {
  const RoleModel({required super.id, required super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TeamModel extends TeamEntity {
  const TeamModel({required super.id, required super.name});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
