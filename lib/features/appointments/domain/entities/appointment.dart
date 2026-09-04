class Appointment {
  final int id;
  final String title;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String type; // 'meeting', 'call', 'visit'
  final DateTime startAt;
  final DateTime endAt;
  final String? description;
  final String? location;
  final String? clientName;
  final int? clientId;
  final String? clientStatusName;
  final String? clientStatusColor;

  Appointment({
    required this.id,
    required this.title,
    required this.status,
    required this.type,
    required this.startAt,
    required this.endAt,
    this.description,
    this.location,
    this.clientName,
    this.clientId,
    this.clientStatusName,
    this.clientStatusColor,
  });
}
