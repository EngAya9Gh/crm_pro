import '../../domain/entities/ticket_category.dart';

class TicketCategoryModel extends TicketCategory {
  TicketCategoryModel({
    required super.id,
    required super.name,
    super.parentId,
    super.color,
    super.icon,
    super.slaHours,
    super.isActive,
    super.children,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    return TicketCategoryModel(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'],
      color: json['color'],
      icon: json['icon'],
      slaHours: json['sla_hours'],
      isActive: json['is_active'] ?? true,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => TicketCategoryModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parent_id': parentId,
      'color': color,
      'icon': icon,
      'sla_hours': slaHours,
      'is_active': isActive,
    };
  }
}
