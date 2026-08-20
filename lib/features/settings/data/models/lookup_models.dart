import '../../domain/entities/lookup_entities.dart';

class RegionModel extends RegionEntity {
  const RegionModel({required super.id, required super.name});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(id: json['id'], name: json['name']);
  }
}

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.name,
    required super.regionId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
      regionId: json['region_id'],
    );
  }
}

class SourceModel extends SourceEntity {
  const SourceModel({
    required super.id,
    required super.name,
    required super.isActive,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class BehaviorModel extends BehaviorEntity {
  const BehaviorModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory BehaviorModel.fromJson(Map<String, dynamic> json) {
    return BehaviorModel(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#000000',
    );
  }
}

class InvalidReasonModel extends InvalidReasonEntity {
  const InvalidReasonModel({required super.id, required super.name});

  factory InvalidReasonModel.fromJson(Map<String, dynamic> json) {
    return InvalidReasonModel(id: json['id'], name: json['name']);
  }
}

class StatusModel extends StatusEntity {
  const StatusModel({
    required super.id,
    required super.name,
    required super.color,
    required super.order,
    required super.weight,
    required super.isDefault,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#000000',
      order: json['order'] ?? 0,
      weight: json['weight'] ?? 0,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}

class TagModel extends TagEntity {
  const TagModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#000000',
    );
  }
}

class InvoiceTagModel extends InvoiceTagEntity {
  const InvoiceTagModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory InvoiceTagModel.fromJson(Map<String, dynamic> json) {
    return InvoiceTagModel(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#000000',
    );
  }
}

class CommentTypeModel extends CommentTypeEntity {
  const CommentTypeModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
  });

  factory CommentTypeModel.fromJson(Map<String, dynamic> json) {
    return CommentTypeModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#000000',
    );
  }
}

class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.id,
    required super.name,
    super.displayName,
    super.category,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      category: json['category'],
    );
  }
}

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    super.teamId,
    super.isDefault,
    super.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      teamId: json['team_id'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
                .map((e) => PermissionModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    super.description,
    super.isActive,
    super.roles,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      roles: json['roles'] != null
          ? (json['roles'] as List).map((e) => RoleModel.fromJson(e)).toList()
          : [],
    );
  }
}
