import 'package:equatable/equatable.dart';

abstract class SettingsCrudState extends Equatable {
  const SettingsCrudState();
  @override
  List<Object?> get props => [];
}

class SettingsCrudInitial extends SettingsCrudState {}

class SettingsCrudLoading extends SettingsCrudState {}

class SettingsCrudSuccess extends SettingsCrudState {
  final String message;
  const SettingsCrudSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsCrudFailure extends SettingsCrudState {
  final String message;
  const SettingsCrudFailure(this.message);
  @override
  List<Object?> get props => [message];
}
