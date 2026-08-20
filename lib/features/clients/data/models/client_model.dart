import 'package:crm_wakeel/features/appointments/data/models/appointment_model.dart';
import 'package:crm_wakeel/features/invoices/data/models/invoice_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/status_entity.dart';
import '../../domain/entities/tag_entity.dart';
import 'client_file_model.dart';
import 'comment_model.dart';
import 'timeline_event_model.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.name,
    super.email,
    required super.phone,
    super.company,
    required super.region,
    super.regionId,
    required super.city,
    super.cityId,
    super.address,
    required super.status,
    required super.priority,
    super.leadRating,

    super.behaviorId,
    super.behaviorName,
    super.sourceId,
    super.sourceName,
    required super.sourceStatus,
    super.invalidReasonId,
    super.invalidReasonName,
    super.assignedTo,
    required super.createdAt,
    super.firstContactAt,
    super.convertedAt,
    super.exclusionReason,
    required super.tags,
    required super.files,
    required super.comments,
    required super.invoices,
    required super.appointments,
    required super.timeline,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone']?.toString() ?? '',
      company: json['company'],
      // Handle region safely
      region: json['region'] is Map
          ? json['region']['name']?.toString() ?? ''
          : json['region']?.toString() ?? '',
      regionId: json['region'] is Map ? json['region']['id'] : null,

      // Handle city safely
      city: json['city'] is Map
          ? json['city']['name']?.toString() ?? ''
          : json['city']?.toString() ?? '',
      cityId: json['city'] is Map ? json['city']['id'] : null,

      address: json['address'],
      status: StatusModel.fromJson(json['status']),
      priority: ClientPriority.values.byName(json['priority'] ?? 'medium'),
      leadRating: json['lead_rating'] != null
          ? ClientRating.values.byName(json['lead_rating'])
          : null,
      behaviorId: json['behavior'] != null
          ? json['behavior']['id'].toString()
          : null,
      behaviorName: json['behavior'] != null ? json['behavior']['name'] : null,
      sourceId: json['source'] != null ? json['source']['id'].toString() : null,
      sourceName: json['source'] != null ? json['source']['name'] : null,
      sourceStatus: json['source_status'] != null
          ? SourceStatus.values.byName(json['source_status'])
          : SourceStatus.valid,
      invalidReasonId: json['invalid_reason'] != null
          ? json['invalid_reason']['id'].toString()
          : null,
      invalidReasonName: json['invalid_reason'] != null
          ? json['invalid_reason']['name']
          : null,
      assignedTo: json['assigned_to'] != null
          ? UserModel.fromJson(json['assigned_to'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      firstContactAt: json['first_contact_at'] != null
          ? DateTime.tryParse(json['first_contact_at'])
          : null,
      convertedAt: json['converted_at'] != null
          ? DateTime.tryParse(json['converted_at'])
          : null,
      exclusionReason: json['exclusion_reason'],
      tags: (json['tags'] as List? ?? [])
          .map((e) => TagModel.fromJson(e))
          .toList(),
      files: (json['files'] as List? ?? [])
          .map((e) => ClientFileModel.fromJson(e))
          .toList(),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e))
          .toList(),
      invoices: (json['invoices'] as List? ?? [])
          .map((e) => InvoiceModel.fromJson(e))
          .toList(),
      appointments: (json['appointments'] as List? ?? [])
          .map((e) => AppointmentModel.fromJson(e))
          .toList(),
      timeline: (json['timeline'] as List? ?? [])
          .map((e) => TimelineEventModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'region_id': regionId,
      'city_id': cityId,
      'address': address,
      'status_id': status.id,
      'priority': priority.name,
      'lead_rating': leadRating?.name,
      'behavior_id': behaviorId,
      'source_id': sourceId,
      'source_status': sourceStatus.name,
      'invalid_reason_id': invalidReasonId,
      'assigned_to': assignedTo?.id,
      'tags': tags.map((e) => e.id).toList(),
    };
  }
}

class StatusModel extends StatusEntity {
  const StatusModel({
    required super.id,
    required super.name,
    required super.color,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
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

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
}
