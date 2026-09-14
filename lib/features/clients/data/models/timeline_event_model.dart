import '../../domain/entities/client_enums.dart';
import '../../domain/entities/timeline_event.dart';

class TimelineEventModel extends TimelineEvent {
  TimelineEventModel({
    required super.id,
    required super.type,
    required super.description,
    required super.occurredAt,
    super.performedBy,
    super.metadata,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      id: json['id']?.toString() ?? '',
      type: _parseType(
        json['event_type']?.toString() ?? json['type']?.toString(),
      ),
      description: json['description'] ?? '',
      occurredAt:
          DateTime.tryParse(
            json['occurred_at']?.toString() ??
                json['created_at']?.toString() ??
                '',
          )?.toLocal() ??
          DateTime.now(),
      performedBy:
          json['performed_by']?.toString() ??
          (json['user'] != null ? json['user']['name']?.toString() : null),
      metadata: json['metadata'],
    );
  }

  static TimelineEventType _parseType(String? value) {
    if (value == null) return TimelineEventType.unknown;

    switch (value.toLowerCase()) {
      case 'created':
      case 'client_created':
        return TimelineEventType.clientCreated;
      case 'comment_added':
        return TimelineEventType.commentAdded;
      case 'file_uploaded':
        return TimelineEventType.fileUploaded;
      case 'invoice_created':
        return TimelineEventType.invoiceCreated;
      case 'appointment_scheduled':
        return TimelineEventType.appointmentScheduled;
      case 'contacted':
        return TimelineEventType.contacted;
      case 'assigned':
        return TimelineEventType.assigned;
      case 'status_changed':
        return TimelineEventType.statusChanged;
      default:
        try {
          return TimelineEventType.values.byName(value);
        } catch (_) {
          return TimelineEventType.unknown;
        }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'occurred_at': occurredAt.toIso8601String(),
      'performed_by': performedBy,
      'metadata': metadata,
    };
  }
}
