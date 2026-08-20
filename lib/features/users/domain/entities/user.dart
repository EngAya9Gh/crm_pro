import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final Team? team;
  final Role? role;
  final List<String>? permissions;
  final String? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.isActive = true,
    this.team,
    this.role,
    this.permissions,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    avatar,
    isActive,
    team,
    role,
    permissions,
    createdAt,
  ];
}

class Team extends Equatable {
  final int id;
  final String name;
  final String? category;

  const Team({required this.id, required this.name, this.category});

  @override
  List<Object?> get props => [id, name, category];
}

class Role extends Equatable {
  final int id;
  final String name;

  const Role({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
