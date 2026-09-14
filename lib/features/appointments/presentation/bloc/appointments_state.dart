import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';
import '../../../clients/domain/entities/client_brief.dart';

enum AppointmentsStatus { initial, loading, success, failure }

enum AppointmentOperationStatus { initial, loading, success, failure }

class AppointmentsState extends Equatable {
  final AppointmentsStatus status;
  final List<Appointment> appointments;
  final bool hasReachedMax;
  final int page;
  final String errorMessage;

  final AppointmentsStatus detailStatus;
  final Appointment? appointmentDetail;

  final AppointmentOperationStatus operationStatus;
  final String operationMessage;

  final List<ClientBrief> clientList;
  final bool isClientsLoading;

  final List<String> monthAppointmentsDates;

  const AppointmentsState({
    this.status = AppointmentsStatus.initial,
    this.appointments = const [],
    this.hasReachedMax = false,
    this.page = 1,
    this.errorMessage = '',
    this.detailStatus = AppointmentsStatus.initial,
    this.appointmentDetail,
    this.operationStatus = AppointmentOperationStatus.initial,
    this.operationMessage = '',
    this.clientList = const [],
    this.isClientsLoading = false,
    this.monthAppointmentsDates = const [],
  });

  AppointmentsState copyWith({
    AppointmentsStatus? status,
    List<Appointment>? appointments,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
    AppointmentsStatus? detailStatus,
    Appointment? appointmentDetail,
    AppointmentOperationStatus? operationStatus,
    String? operationMessage,
    List<ClientBrief>? clientList,
    bool? isClientsLoading,
    List<String>? monthAppointmentsDates,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
      detailStatus: detailStatus ?? this.detailStatus,
      appointmentDetail: appointmentDetail ?? this.appointmentDetail,
      operationStatus: operationStatus ?? this.operationStatus,
      operationMessage: operationMessage ?? this.operationMessage,
      clientList: clientList ?? this.clientList,
      isClientsLoading: isClientsLoading ?? this.isClientsLoading,
      monthAppointmentsDates:
          monthAppointmentsDates ?? this.monthAppointmentsDates,
    );
  }

  @override
  List<Object?> get props => [
    status,
    appointments,
    hasReachedMax,
    page,
    errorMessage,
    detailStatus,
    appointmentDetail,
    operationStatus,
    operationMessage,
    clientList,
    isClientsLoading,
    monthAppointmentsDates,
  ];
}
