import 'package:equatable/equatable.dart';

class RegionEntity extends Equatable {
  final int id;
  final String name;

  const RegionEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class CityEntity extends Equatable {
  final int id;
  final String name;
  final int regionId;

  const CityEntity({
    required this.id,
    required this.name,
    required this.regionId,
  });

  @override
  List<Object?> get props => [id, name, regionId];
}

class SourceEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const SourceEntity({
    required this.id,
    required this.name,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}

class BehaviorEntity extends Equatable {
  final int id;
  final String name;
  final String color;

  const BehaviorEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}

class InvalidReasonEntity extends Equatable {
  final int id;
  final String name;

  const InvalidReasonEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class StatusEntity extends Equatable {
  final int id;
  final String name;
  final String color;
  final int order;
  final int weight;
  final bool isDefault;

  const StatusEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.order,
    required this.weight,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [id, name, color, order, weight, isDefault];
}

class TagEntity extends Equatable {
  final int id;
  final String name;
  final String color;

  const TagEntity({required this.id, required this.name, required this.color});

  @override
  List<Object?> get props => [id, name, color];
}

class InvoiceTagEntity extends Equatable {
  final int id;
  final String name;
  final String color;

  const InvoiceTagEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, color];
}

class CommentTypeEntity extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String color;

  const CommentTypeEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [id, name, icon, color];
}

class PermissionEntity extends Equatable {
  final int id;
  final String name;
  final String? displayName;
  final String? category;

  const PermissionEntity({
    required this.id,
    required this.name,
    this.displayName,
    this.category,
  });

  @override
  List<Object?> get props => [id, name, displayName, category];
}

class RoleEntity extends Equatable {
  final int id;
  final String name;
  final int? teamId;
  final bool isDefault;
  final List<PermissionEntity> permissions;

  const RoleEntity({
    required this.id,
    required this.name,
    this.teamId,
    this.isDefault = false,
    this.permissions = const [],
  });

  @override
  List<Object?> get props => [id, name, teamId, isDefault, permissions];
}

class TeamEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final List<RoleEntity> roles;

  const TeamEntity({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.roles = const [],
  });

  @override
  List<Object?> get props => [id, name, description, isActive, roles];
}
