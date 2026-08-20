import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int totalClients;
  final int activeClients;
  final int totalInvoices;
  final int totalAppointments;
  final int pendingInvoices;
  final int upcomingAppointments;
  final String userName;

  const DashboardSummary({
    required this.totalClients,
    required this.activeClients,
    required this.totalInvoices,
    required this.totalAppointments,
    required this.pendingInvoices,
    required this.upcomingAppointments,
    required this.userName,
  });

  @override
  List<Object?> get props => [
    totalClients,
    activeClients,
    totalInvoices,
    totalAppointments,
    pendingInvoices,
    upcomingAppointments,
    userName,
  ];
}
