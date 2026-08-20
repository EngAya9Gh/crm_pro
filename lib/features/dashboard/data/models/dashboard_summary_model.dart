import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalClients,
    required super.activeClients,
    required super.totalInvoices,
    required super.totalAppointments,
    required super.pendingInvoices,
    required super.upcomingAppointments,
    required super.userName,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final clients = json['clients'] as Map<String, dynamic>?;
    final invoices = json['invoices'] as Map<String, dynamic>?;
    final appointments = json['appointments'] as Map<String, dynamic>?;

    return DashboardSummaryModel(
      totalClients: _toInt(clients?['total']),
      activeClients: _toInt(
        clients?['total'],
      ), // Or map to a specific active field if exists
      totalInvoices: _toInt(invoices?['total']),
      totalAppointments: _toInt(appointments?['total']),
      pendingInvoices: _toInt(
        invoices?['pending_count'] ?? 0,
      ), // Adjust based on real field
      upcomingAppointments: _toInt(appointments?['upcoming'] ?? 0),
      userName: json['user_name']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_clients': totalClients,
      'active_clients': activeClients,
      'total_invoices': totalInvoices,
      'total_appointments': totalAppointments,
      'pending_invoices': pendingInvoices,
      'upcoming_appointments': upcomingAppointments,
      'user_name': userName,
    };
  }
}
