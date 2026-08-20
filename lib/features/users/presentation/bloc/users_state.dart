import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum UsersStatus { initial, loading, success, failure }

enum UsersOperationStatus { initial, loading, success, failure }

class UsersState extends Equatable {
  final UsersStatus status;
  final List<User> users;
  final String? errorMessage;
  final int page;
  final bool hasReachedMax;

  final UsersOperationStatus operationStatus;
  final String? operationMessage;

  final UsersStatus detailStatus;
  final User? userDetail;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.errorMessage,
    this.page = 1,
    this.hasReachedMax = false,
    this.operationStatus = UsersOperationStatus.initial,
    this.operationMessage,
    this.detailStatus = UsersStatus.initial,
    this.userDetail,
  });

  UsersState copyWith({
    UsersStatus? status,
    List<User>? users,
    String? errorMessage,
    int? page,
    bool? hasReachedMax,
    UsersOperationStatus? operationStatus,
    String? operationMessage,
    UsersStatus? detailStatus,
    User? userDetail,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      operationStatus: operationStatus ?? this.operationStatus,
      operationMessage: operationMessage ?? this.operationMessage,
      detailStatus: detailStatus ?? this.detailStatus,
      userDetail: userDetail ?? this.userDetail,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    errorMessage,
    page,
    hasReachedMax,
    operationStatus,
    operationMessage,
    detailStatus,
    userDetail,
  ];
}
