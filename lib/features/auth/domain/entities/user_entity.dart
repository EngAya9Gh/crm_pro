import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final RoleEntity role;
  final TeamEntity? team;
  final TenantEntity? tenant;
  final Set<String> permissions;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.team,
    this.tenant,
  });

  @override
  List<Object?> get props => [id, name, email, role, team, tenant, permissions];
}

class RoleEntity extends Equatable {
  final int id;
  final String name;

  const RoleEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class TeamEntity extends Equatable {
  final int id;
  final String name;

  const TeamEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class TenantEntity extends Equatable {
  final int id;
  final String name;
  final Set<String> enabledFeatures;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.enabledFeatures,
  });

  @override
  List<Object?> get props => [id, name, enabledFeatures];
}
