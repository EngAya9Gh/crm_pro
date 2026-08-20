import 'package:crm_wakeel/features/appointments/domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  AppointmentModel({
    required super.id,
    required super.title,
    required super.status,
    required super.type,
    required super.startAt,
    required super.endAt,
    super.description,
    super.location,
    super.clientName,
    super.clientId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? 'موعد بدون عنوان',
      status: json['status'] ?? 'scheduled',
      type: json['type'] ?? 'meeting',
      startAt: DateTime.tryParse(json['start_at'] ?? '') ?? DateTime.now(),
      endAt:
          DateTime.tryParse(json['end_at'] ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      description: json['description'],
      location: json['location'],
      clientName: json['client'] is Map
          ? json['client']['name']
          : json['client_name'],
      clientId: json['client'] is Map
          ? int.tryParse(json['client']['id']?.toString() ?? '0')
          : int.tryParse(json['client_id']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'type': type,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'description': description,
      'location': location,
      // client info is usually read-only or sent as client_id from UI
    };
  }
}
