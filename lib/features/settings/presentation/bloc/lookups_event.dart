import 'package:equatable/equatable.dart';

abstract class LookupsEvent extends Equatable {
  const LookupsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllLookups extends LookupsEvent {}

class LoadCities extends LookupsEvent {
  final int? regionId;
  const LoadCities(this.regionId);

  @override
  List<Object?> get props => [regionId];
}

class LoadEmployees extends LookupsEvent {}
