import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final RoleEntity role;
  final TeamEntity? team;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.team,
  });

  @override
  List<Object?> get props => [id, name, email, role, team];
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
