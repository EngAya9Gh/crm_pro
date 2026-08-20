import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:crm_wakeel/features/appointments/domain/entities/appointment.dart';
import 'package:crm_wakeel/features/clients/domain/usecases/get_client_appointments_usecase.dart';

// States
abstract class ClientAppointmentsState extends Equatable {
  const ClientAppointmentsState();
  @override
  List<Object?> get props => [];
}

class ClientAppointmentsInitial extends ClientAppointmentsState {}

class ClientAppointmentsLoading extends ClientAppointmentsState {}

class ClientAppointmentsLoaded extends ClientAppointmentsState {
  final List<Appointment> appointments;
  final bool hasReachedMax;
  final int page;

  const ClientAppointmentsLoaded(
    this.appointments, {
    this.hasReachedMax = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [appointments, hasReachedMax, page];

  ClientAppointmentsLoaded copyWith({
    List<Appointment>? appointments,
    bool? hasReachedMax,
    int? page,
  }) {
    return ClientAppointmentsLoaded(
      appointments ?? this.appointments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }
}

class ClientAppointmentsError extends ClientAppointmentsState {
  final String message;
  const ClientAppointmentsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ClientAppointmentsCubit extends Cubit<ClientAppointmentsState> {
  final GetClientAppointmentsUseCase getClientAppointments;

  static const int _pageSize = 10;
  int _currentPage = 1;

  ClientAppointmentsCubit(this.getClientAppointments)
    : super(ClientAppointmentsInitial());

  Future<void> loadAppointments(String clientId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      emit(ClientAppointmentsLoading());
    } else if (state is ClientAppointmentsLoaded) {
      // Keep silent or loading based on requirement
    } else {
      emit(ClientAppointmentsLoading());
    }

    final result = await getClientAppointments(
      clientId: clientId,
      page: _currentPage,
      perPage: _pageSize,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ClientAppointmentsError(failure.message)),
      (paginatedList) => emit(
        ClientAppointmentsLoaded(
          paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> loadMoreAppointments(String clientId) async {
    if (state is! ClientAppointmentsLoaded) return;

    final currentState = state as ClientAppointmentsLoaded;
    if (currentState.hasReachedMax) return;

    _currentPage++;

    final result = await getClientAppointments(
      clientId: clientId,
      page: _currentPage,
      perPage: _pageSize,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _currentPage--;
      },
      (paginatedList) {
        emit(
          currentState.copyWith(
            appointments: List.of(currentState.appointments)
              ..addAll(paginatedList.items),
            hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
            page: paginatedList.currentPage,
          ),
        );
      },
    );
  }
}
