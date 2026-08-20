import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_lookups_usecase.dart';
import '../../domain/usecases/settings_usecases.dart';
import 'lookups_event.dart';
import 'lookups_state.dart';

class LookupsBloc extends Bloc<LookupsEvent, LookupsState> {
  final GetAllLookupsUseCase getAllLookups;
  final GetCitiesUseCase getCities;
  final GetEmployeesUseCase getEmployees;

  LookupsBloc({
    required this.getAllLookups,
    required this.getCities,
    required this.getEmployees,
  }) : super(LookupsInitial()) {
    on<LoadAllLookups>(_onLoadAllLookups);
    on<LoadCities>(_onLoadCities);
    on<LoadEmployees>(_onLoadEmployees);
  }

  Future<void> _onLoadAllLookups(
    LoadAllLookups event,
    Emitter<LookupsState> emit,
  ) async {
    emit(LookupsLoading());
    final result = await getAllLookups();
    result.fold(
      (failure) => emit(LookupsError(failure.message)),
      (lookups) => emit(LookupsLoaded(lookups: lookups)),
    );
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<LookupsState> emit,
  ) async {
    if (state is! LookupsLoaded) return;
    final currentState = state as LookupsLoaded;

    emit(currentState.copyWith(isLoadingCities: true));

    final result = await getCities(regionId: event.regionId);

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingCities: false)),
      (cities) =>
          emit(currentState.copyWith(cities: cities, isLoadingCities: false)),
    );
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<LookupsState> emit,
  ) async {
    if (state is! LookupsLoaded) return;
    final currentState = state as LookupsLoaded;

    emit(currentState.copyWith(isLoadingEmployees: true));

    final result = await getEmployees();

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingEmployees: false)),
      (employees) => emit(
        currentState.copyWith(employees: employees, isLoadingEmployees: false),
      ),
    );
  }
}
