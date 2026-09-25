import '../../domain/entities/evaluation_type.dart';

class EvaluationTypeModel extends EvaluationType {
  EvaluationTypeModel({
    required super.id,
    required super.name,
    super.isActive,
  });

  factory EvaluationTypeModel.fromJson(Map<String, dynamic> json) {
    return EvaluationTypeModel(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_active': isActive,
    };
  }
}
