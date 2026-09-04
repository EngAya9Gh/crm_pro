import 'package:equatable/equatable.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointments extends AppointmentsEvent {
  final int page;
  final String? status;
  final String? type;
  final int? clientId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isRefresh;

  const LoadAppointments({
    this.page = 1,
    this.status,
    this.type,
    this.clientId,
    this.dateFrom,
    this.dateTo,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    status,
    type,
    clientId,
    dateFrom,
    dateTo,
    isRefresh,
  ];
}

class LoadMoreAppointments extends AppointmentsEvent {}

class LoadMonthAppointmentsDates extends AppointmentsEvent {
  final DateTime month;
  const LoadMonthAppointmentsDates(this.month);
  
  @override
  List<Object?> get props => [month];
}

class GetAppointmentDetailsEvent extends AppointmentsEvent {
  final int id;
  const GetAppointmentDetailsEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateAppointmentEvent extends AppointmentsEvent {
  final Map<String, dynamic> data;
  const CreateAppointmentEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateAppointmentEvent extends AppointmentsEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateAppointmentEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  final int id;
  const DeleteAppointmentEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ChangeAppointmentStatusEvent extends AppointmentsEvent {
  final int id;
  final String status;
  const ChangeAppointmentStatusEvent(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class GetAppointmentClientsEvent extends AppointmentsEvent {
  final String? search;
  const GetAppointmentClientsEvent({this.search});
  @override
  List<Object?> get props => [search];
}
