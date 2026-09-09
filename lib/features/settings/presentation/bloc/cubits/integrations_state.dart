import 'package:equatable/equatable.dart';
import '../../../domain/entities/integrations_entity.dart';

abstract class IntegrationsState extends Equatable {
  const IntegrationsState();

  @override
  List<Object?> get props => [];
}

class IntegrationsInitial extends IntegrationsState {}

class IntegrationsLoading extends IntegrationsState {}

class IntegrationsLoaded extends IntegrationsState {
  final IntegrationsEntity integrations;

  const IntegrationsLoaded(this.integrations);

  @override
  List<Object?> get props => [integrations];
}

class IntegrationsError extends IntegrationsState {
  final String message;

  const IntegrationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class IntegrationUpdateLoading extends IntegrationsState {}

class IntegrationUpdateSuccess extends IntegrationsState {
  final String message;

  const IntegrationUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class IntegrationUpdateError extends IntegrationsState {
  final String message;

  const IntegrationUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
