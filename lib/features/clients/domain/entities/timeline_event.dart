import 'client_enums.dart';

class TimelineEvent {
  final String id;
  final TimelineEventType type;
  final String description;
  final DateTime occurredAt;
  final String? performedBy;
  final Map<String, dynamic>? metadata;

  TimelineEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.occurredAt,
    this.performedBy,
    this.metadata,
  });
}
