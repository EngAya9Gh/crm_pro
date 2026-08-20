import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/get_user_details_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsers;
  final CreateUserUseCase createUser;
  final GetUserDetailsUseCase getUserDetails;
  final UpdateUserUseCase updateUser;

  // Filter state
  String? _currentSearch;
  int? _currentTeamId;
  int? _currentRoleId;
  int? _currentIsActive;

  UsersBloc({
    required this.getUsers,
    required this.createUser,
    required this.getUserDetails,
    required this.updateUser,
  }) : super(const UsersState()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<GetUserDetailsEvent>(_onGetUserDetails);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    if (event.isRefresh) {
      emit(
        state.copyWith(
          status: UsersStatus.loading,
          users: [],
          page: 1,
          hasReachedMax: false,
        ),
      );
    } else {
      emit(state.copyWith(status: UsersStatus.loading));
    }

    _currentSearch = event.search;
    _currentTeamId = event.teamId;
    _currentRoleId = event.roleId;
    _currentIsActive = event.isActive;

    final result = await getUsers(
      page: 1,
      search: event.search,
      teamId: event.teamId,
      roleId: event.roleId,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UsersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginatedList) => emit(
        state.copyWith(
          status: UsersStatus.success,
          users: paginatedList.items,
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<UsersState> emit,
  ) async {
    if (state.hasReachedMax || state.status != UsersStatus.success) return;

    final result = await getUsers(
      page: state.page + 1,
      search: _currentSearch,
      teamId: _currentTeamId,
      roleId: _currentRoleId,
      isActive: _currentIsActive,
    );

    result.fold(
      (failure) => null,
      (paginatedList) => emit(
        state.copyWith(
          users: List.of(state.users)..addAll(paginatedList.items),
          page: paginatedList.currentPage,
          hasReachedMax: paginatedList.currentPage >= paginatedList.lastPage,
        ),
      ),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: UsersOperationStatus.loading,
        operationMessage: '',
      ),
    );

    final result = await createUser(event.data);

    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: UsersOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          operationStatus: UsersOperationStatus.success,
          operationMessage: 'تم إضافة المستخدم بنجاح',
          users: [user, ...state.users],
        ),
      ),
    );
  }

  Future<void> _onGetUserDetails(
    GetUserDetailsEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(detailStatus: UsersStatus.loading));
    final result = await getUserDetails(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailStatus: UsersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(detailStatus: UsersStatus.success, userDetail: user),
      ),
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: UsersOperationStatus.loading,
        operationMessage: '',
      ),
    );

    final result = await updateUser(event.id, event.data);

    result.fold(
      (failure) => emit(
        state.copyWith(
          operationStatus: UsersOperationStatus.failure,
          operationMessage: failure.message,
        ),
      ),
      (user) {
        final updatedList = state.users
            .map((e) => e.id == user.id ? user : e)
            .toList();

        emit(
          state.copyWith(
            operationStatus: UsersOperationStatus.success,
            operationMessage: 'تم تحديث بيانات المستخدم بنجاح',
            users: updatedList,
            userDetail: user,
          ),
        );
      },
    );
  }
}
