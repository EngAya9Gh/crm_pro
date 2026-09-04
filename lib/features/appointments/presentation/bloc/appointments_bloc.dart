import 'package:flutter_bloc/flutter_bloc.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/get_appointment_details_usecase.dart';
import '../../domain/usecases/create_appointment_usecase.dart';
import '../../domain/usecases/update_appointment_usecase.dart';
import '../../domain/usecases/delete_appointment_usecase.dart';
import '../../domain/usecases/change_appointment_status_usecase.dart';

import '../../../clients/domain/usecases/get_clients_list_usecase.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAppointmentsUseCase getAppointments;
  final GetAppointmentDetailsUseCase getAppointmentDetails;
  final CreateAppointmentUseCase createAppointment;
  final UpdateAppointmentUseCase updateAppointment;
  final DeleteAppointmentUseCase deleteAppointment;
  final ChangeAppointmentStatusUseCase changeStatus;
  final GetClientsListUseCase getClientsList;

  // Filter state for pagination
  String? _currentStatus;
  String? _currentType;
  int? _currentClientId;
  DateTime? _currentDateFrom;
  DateTime? _currentDateTo;

  static const int _limit = 15;

  AppointmentsBloc({
    required this.getAppointments,
    required this.getAppointmentDetails,
    required this.createAppointment,
    required this.updateAppointment,
    required this.deleteAppointment,
    required this.changeStatus,
    required this.getClientsList,
  }) : super(const AppointmentsState()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<LoadMoreAppointments>(_onLoadMoreAppointments);
    on<GetAppointmentDetailsEvent>(_onGetAppointmentDetails);
    on<CreateAppointmentEvent>(_onCreateAppointment);
    on<UpdateAppointmentEvent>(_onUpdateAppointment);
    on<DeleteAppointmentEvent>(_onDeleteAppointment);
    on<ChangeAppointmentStatusEvent>(_onChangeStatus);
    on<GetAppointmentClientsEvent>(_onGetAppointmentClients);
    on<LoadMonthAppointmentsDates>(_onLoadMonthAppointmentsDates);
  }

  // ... (existing handlers)

  Future<void> _onGetAppointmentClients(
    GetAppointmentClientsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(isClientsLoading: true));
    final result = await getClientsList(search: event.search, perPage: 50);
    result.fold(
      (failure) => emit(
        state.copyWith(isClientsLoading: false, errorMessage: failure.message),
      ),
      (list) => emit(
        state.copyWith(isClientsLoading: false, clientList: list.items),
      ),
    );
  }

  Future<void> _onLoadMonthAppointmentsDates(
    LoadMonthAppointmentsDates event,
    Emitter<AppointmentsState> emit,
  ) async {
    final firstDay = DateTime(event.month.year, event.month.month, 1);
    final lastDay = DateTime(event.month.year, event.month.month + 1, 0, 23, 59, 59);
    
    // Fetch with a large limit just for indicators
    final result = await getAppointments(
      dateFrom: firstDay,
      dateTo: lastDay,
    );
    
    result.fold(
      (failure) {
        print("❌ Failed to load month dates: ${failure.message}");
      },
      (data) {
        final dates = data.items
            .map((e) => "${e.startAt.year}-${e.startAt.month.toString().padLeft(2, '0')}-${e.startAt.day.toString().padLeft(2, '0')}")
            .toList();
        print("✅ Loaded month dates (${dates.length}): $dates");
        emit(state.copyWith(monthAppointmentsDates: dates));
      },
    );
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (event.isRefresh) {
      emit(
        state.copyWith(
          status: AppointmentsStatus.loading,
          appointments: [],
          page: 1,
          hasReachedMax: false,
        ),
      );
    } else {
      emit(state.copyWith(status: AppointmentsStatus.loading));
    }

    _currentStatus = event.status;
    _currentType = event.type;
    _currentClientId = event.clientId;
    _currentDateFrom = event.dateFrom;
    _currentDateTo = event.dateTo;

    final result = await getAppointments(
      page: 1,
      limit: _limit,
      status: event.status,
      type: event.type,
      clientId: event.clientId,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AppointmentsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginatedList) {
        // Update month indicators: add current day if it has appointments
        final updatedDates = List<String>.from(state.monthAppointmentsDates);
        if (event.dateFrom != null) {
          final dayStr = "${event.dateFrom!.year}-${event.dateFrom!.month.toString().padLeft(2, '0')}-${event.dateFrom!.day.toString().padLeft(2, '0')}";
          if (paginatedList.items.isNotEmpty && !updatedDates.contains(dayStr)) {
            updatedDates.add(dayStr);
          }
        }
        emit(
          state.copyWith(
            status: AppointmentsStatus.success,
            appointments: paginatedList.items,
            page: paginatedList.currentPage,
            hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
            monthAppointmentsDates: updatedDates,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreAppointments(
    LoadMoreAppointments event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state.hasReachedMax || state.status != AppointmentsStatus.success) {
      return;
    }

    final result = await getAppointments(
      page: state.page + 1,
      limit: _limit,
      status: _currentStatus,
      type: _currentType,
      clientId: _currentClientId,
      dateFrom: _currentDateFrom,
      dateTo: _currentDateTo,
    );

    result.fold(
      (failure) => null, // Show error via snackbar in listener if needed
      (paginatedList) => emit(
        state.copyWith(
          appointments: List.of(state.appointments)
            ..addAll(paginatedList.items),
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onGetAppointmentDetails(
    GetAppointmentDetailsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(detailStatus: AppointmentsStatus.loading));
    final result = await getAppointmentDetails(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailStatus: AppointmentsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (appointment) => emit(
        state.copyWith(
          detailStatus: AppointmentsStatus.success,
          appointmentDetail: appointment,
        ),
      ),
    );
  }

  Future<void> _onCreateAppointment(
    CreateAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AppointmentOperationStatus.loading,
        operationMessage: '',
      ),
    );
    final result = await createAppointment(event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: AppointmentOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (appointment) => emit(
        state.copyWith(
          operationStatus: AppointmentOperationStatus.success,
          operationMessage: 'تم إضافة الموعد بنجاح',
          appointments: [appointment, ...state.appointments],
        ),
      ),
    );
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AppointmentOperationStatus.loading,
        operationMessage: '',
      ),
    );
    final result = await updateAppointment(event.id, event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: AppointmentOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (appointment) {
        final updatedList = state.appointments
            .map((e) => e.id == appointment.id ? appointment : e)
            .toList();

        emit(
          state.copyWith(
            operationStatus: AppointmentOperationStatus.success,
            operationMessage: 'تم تحديث الموعد بنجاح',
            appointments: updatedList,
            appointmentDetail: appointment,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(operationStatus: AppointmentOperationStatus.loading));
    final result = await deleteAppointment(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: AppointmentOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (_) {
        final updatedList = state.appointments
            .where((e) => e.id != event.id)
            .toList();
        emit(
          state.copyWith(
            operationStatus: AppointmentOperationStatus.success,
            operationMessage: 'تم حذف الموعد',
            appointments: updatedList,
          ),
        );
      },
    );
  }

  Future<void> _onChangeStatus(
    ChangeAppointmentStatusEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(operationStatus: AppointmentOperationStatus.loading));
    final result = await changeStatus(event.id, event.status);
    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: AppointmentOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (appointment) {
        final updatedList = state.appointments
            .map((e) => e.id == appointment.id ? appointment : e)
            .toList();
        emit(
          state.copyWith(
            operationStatus: AppointmentOperationStatus.success,
            operationMessage: 'تم تحديث حالة الموعد',
            appointments: updatedList,
            appointmentDetail: appointment,
          ),
        );
      },
    );
  }
}
