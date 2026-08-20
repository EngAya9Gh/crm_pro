import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_all_lookups_usecase.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../../users/domain/entities/user.dart';

abstract class LookupsState extends Equatable {
  const LookupsState();

  @override
  List<Object?> get props => [];
}

class LookupsInitial extends LookupsState {}

class LookupsLoading extends LookupsState {}

class LookupsLoaded extends LookupsState {
  final AllLookups lookups;
  final List<CityEntity> cities;
  final bool isLoadingCities;
  final List<User> employees;
  final bool isLoadingEmployees;

  const LookupsLoaded({
    required this.lookups,
    this.cities = const [],
    this.isLoadingCities = false,
    this.employees = const [],
    this.isLoadingEmployees = false,
  });

  LookupsLoaded copyWith({
    AllLookups? lookups,
    List<CityEntity>? cities,
    bool? isLoadingCities,
    List<User>? employees,
    bool? isLoadingEmployees,
  }) {
    return LookupsLoaded(
      lookups: lookups ?? this.lookups,
      cities: cities ?? this.cities,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      employees: employees ?? this.employees,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
    );
  }

  @override
  List<Object?> get props => [
    lookups,
    cities,
    isLoadingCities,
    employees,
    isLoadingEmployees,
  ];
}

class LookupsError extends LookupsState {
  final String message;
  const LookupsError(this.message);
  @override
  List<Object?> get props => [message];
}
