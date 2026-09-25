import '../../domain/entities/evaluation.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../users/data/models/user_model.dart';
import 'evaluation_type_model.dart';

class EvaluationModel extends Evaluation {
  EvaluationModel({
    required super.id,
    required super.rating,
    super.notes,
    required super.channel,
    super.client,
    super.assignedUser,
    super.type,
    required super.createdAt,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id'],
      rating: json['rating'],
      notes: json['notes'],
      channel: json['channel'] ?? 'manual',
      client: json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      assignedUser: json['assigned_user'] != null ? UserModel.fromJson(json['assigned_user']) : null,
      type: json['type'] != null 
          ? (json['type'] is String 
              ? EvaluationTypeModel(id: 0, name: json['type']) 
              : EvaluationTypeModel.fromJson(json['type'])) 
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'notes': notes,
      'channel': channel,
      'client_id': client?.id,
      'assigned_user_id': assignedUser?.id,
      'type_id': type?.id,
    };
  }
}
