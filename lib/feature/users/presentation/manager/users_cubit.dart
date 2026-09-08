import 'dart:developer';

import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/use_cases/get_all_users_use_case.dart';
import 'package:bloc/bloc.dart';

import '../../domain/use_cases/change_user_role_use_case.dart';
import '../../domain/use_cases/delete_user_use_case.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(
    this._getAllUsersUseCase,
    this._deleteUserUseCase,
    this._changeUserRoleUseCase,
  ) : super(UsersInitial());

  final GetAllUsersUseCase _getAllUsersUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final ChangeUserRoleUseCase _changeUserRoleUseCase;

  Future<void> getAllUsers() async {
    log(
      '---------------- [message] : start getAllUsers in Cubit [message]----------------',
    );
    emit(UsersLoading());
    final result = await _getAllUsersUseCase();
    result.fold((error) => emit(UsersError(message: error.message)), (
      usersList,
    ) {
      log(
        '---------------- [message] : usersList is $usersList [message]----------------',
      );
      emit(UsersLoaded(users: usersList));
    });
  }

  /// تحديث نص البحث — بدون تأثير إن كانت الحالة الحالية مو UsersLoaded بعد
  /// (مثلاً لسا بحالة Loading).
  void updateSearchQuery(String query) {
    final current = state;
    if (current is! UsersLoaded) return;
    emit(current.copyWith(searchQuery: query));
  }

  void filterByRole(UserRole? role) {
    final current = state;
    if (current is! UsersLoaded) return;
    emit(
      role == null
          ? current.copyWith(clearRoleFilter: true)
          : current.copyWith(roleFilter: role),
    );
  }

  void toggleUserStatus(String uid) {
    final current = state;
    if (current is! UsersLoaded) return;
    final updated = current.users.map((u) {
      if (u.uid != uid) return u;
      return u.copyWith(isActive: !u.isActive);
    }).toList();
    emit(current.copyWith(users: updated));
    // TODO: استدعاء use case حقيقي لتحديث isActive في Firestore عبر UserModel
  }

  Future<void> changeUserRole(String uid, UserRole newRole) async {
    final current = state;
    if (current is! UsersLoaded) return;

    final previousUsers = current.users;
    final updated = current.users.map((u) {
      if (u.uid != uid) return u;
      return u.copyWith(role: newRole);
    }).toList();

    emit(current.copyWith(users: updated));

    final result = await _changeUserRoleUseCase(uid, newRole);

    result.fold(
      (error) {
        emit(current.copyWith(users: previousUsers));
        emit(UsersError(message: error.message));
      },
      (_) {},
    );
  }

  void deleteUser(String uid) async {
    final current = state;
    if (current is! UsersLoaded) return;
    final updated = current.users.where((u) => u.uid != uid).toList();
    final result = await _deleteUserUseCase(uid);
    result.fold((error) => emit(UsersError(message: error.message)), (_) =>
        emit(current.copyWith(users: updated)));
  }
}
