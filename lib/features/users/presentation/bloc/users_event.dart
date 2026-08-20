import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UsersEvent {
  final String? search;
  final int? teamId;
  final int? roleId;
  final int? isActive;
  final bool isRefresh;

  const LoadUsers({
    this.search,
    this.teamId,
    this.roleId,
    this.isActive,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [search, teamId, roleId, isActive, isRefresh];
}

class LoadMoreUsers extends UsersEvent {}

class CreateUserEvent extends UsersEvent {
  final Map<String, dynamic> data;
  const CreateUserEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class GetUserDetailsEvent extends UsersEvent {
  final int id;
  const GetUserDetailsEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateUserEvent extends UsersEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateUserEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}
