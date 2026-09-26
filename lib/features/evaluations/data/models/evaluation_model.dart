import '../../domain/entities/evaluation.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/entities/client_enums.dart';
import '../../../clients/domain/entities/status_entity.dart';
import '../../../users/domain/entities/user.dart';
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
      client: json['client'] != null
          ? _EvalPartialClient.fromJson(json['client'])
          : null,
      assignedUser: json['assigned_user'] != null
          ? _EvalPartialUser.fromJson(json['assigned_user'])
          : null,
      type: json['type'] != null
          ? (json['type'] is String
              ? EvaluationTypeModel(id: 0, name: json['type'])
              : EvaluationTypeModel.fromJson(json['type']))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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

/// Lightweight Client stub for partial API responses in evaluations
class _EvalPartialClient extends Client {
  _EvalPartialClient({
    required String id,
    required String name,
    String phone = '',
  }) : super(
          id: id,
          name: name,
          phone: phone,
          region: '',
          city: '',
          status: const StatusModel(id: 0, name: '', color: '#000000'),
          priority: ClientPriority.medium,
          sourceStatus: SourceStatus.valid,
          tags: const [],
          files: const [],
          comments: const [],
          invoices: const [],
          appointments: const [],
          timeline: const [],
          createdAt: DateTime.now(),
        );

  factory _EvalPartialClient.fromJson(Map<String, dynamic> json) {
    return _EvalPartialClient(
      id: json['id']?.toString() ?? '0',
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

/// Lightweight User stub for partial API responses in evaluations
class _EvalPartialUser extends User {
  const _EvalPartialUser({required super.id, required super.name})
      : super(email: '');

  factory _EvalPartialUser.fromJson(Map<String, dynamic> json) {
    return _EvalPartialUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
    );
  }
}
