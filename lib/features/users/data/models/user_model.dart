import 'package:crm_wakeel/features/users/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatar,
    super.isActive,
    super.team,
    super.role,
    super.permissions,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      team: json['team'] != null ? TeamModel.fromJson(json['team']) : null,
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive,
      'team': team is TeamModel ? (team as TeamModel).toJson() : null,
      'role': role is RoleModel ? (role as RoleModel).toJson() : null,
      'permissions': permissions,
      'created_at': createdAt,
    };
  }
}

class TeamModel extends Team {
  const TeamModel({required super.id, required super.name, super.category});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category': category};
  }
}

class RoleModel extends Role {
  const RoleModel({required super.id, required super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
