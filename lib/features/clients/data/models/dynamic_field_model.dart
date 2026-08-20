import '../../domain/entities/dynamic_field.dart';

class DynamicFieldModel extends DynamicField {
  DynamicFieldModel({
    required super.id,
    required super.name,
    super.color,
    super.icon,
    required super.order,
    super.isActive,
  });

  factory DynamicFieldModel.fromJson(Map<String, dynamic> json) {
    return DynamicFieldModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'بدون اسم',
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'order': order,
      'is_active': isActive,
    };
  }
}
