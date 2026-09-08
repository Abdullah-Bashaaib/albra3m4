import 'dart:developer';

import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/use_cases/get_all_users_use_case.dart';
import 'package:bloc/bloc.dart';

import '../../domain/use_cases/change_user_role_use_case.dart';
import '../../domain/use_cases/delete_user_use_case.dart';
import '../../domain/use_cases/toggle_user_status_use_case.dart';
import '../../domain/use_cases/update_user_use_case.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(
    this._getAllUsersUseCase,
    this._deleteUserUseCase,
    this._changeUserRoleUseCase,
    this._toggleUserStatusUseCase,
    this._updateUserUseCase,
  ) : super(UsersInitial());

  final GetAllUsersUseCase _getAllUsersUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final ChangeUserRoleUseCase _changeUserRoleUseCase;
  final ToggleUserStatusUseCase _toggleUserStatusUseCase;
  final UpdateUserUseCase _updateUserUseCase;

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

  Future<void> toggleUserStatus(String uid) async {
    final current = state;
    if (current is! UsersLoaded) return;

    // حماية: منع تعطيل حساب مسؤول النظام
    final targetUser = current.users.cast<UserEntity?>().firstWhere(
          (u) => u?.uid == uid,
          orElse: () => null,
        );
    if (targetUser == null || targetUser.role == UserRole.superAdmin) return;

    final newStatus = !targetUser.isActive;
    final previousUsers = current.users;

    // تحديث تفاؤلي في الواجهة
    final updated = current.users.map((u) {
      if (u.uid != uid) return u;
      return u.copyWith(isActive: newStatus);
    }).toList();

    emit(current.copyWith(users: updated));

    // التعديل في Firestore و Sqflite
    final result = await _toggleUserStatusUseCase(uid, newStatus);

    result.fold(
      (error) {
        emit(current.copyWith(users: previousUsers));
        emit(UsersError(message: error.message));
      },
      (_) {
        log(
          '---------------- [message] : status updated successfully to $newStatus [message]----------------',
        );
      },
    );
  }

  Future<void> changeUserRole(String uid, UserRole newRole) async {
    final current = state;
    if (current is! UsersLoaded) return;

    // حماية: منع تغيير دور مسؤول النظام
    final targetUser = current.users.cast<UserEntity?>().firstWhere(
          (u) => u?.uid == uid,
          orElse: () => null,
        );
    if (targetUser == null || targetUser.role == UserRole.superAdmin) return;

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
      (_) {
        log(
          '---------------- [message] : role changed successfully [message]----------------',
        );
      },
    );
  }

  Future<void> deleteUser(String uid) async {
    final current = state;
    if (current is! UsersLoaded) return;

    // حماية: منع حذف مسؤول النظام
    final targetUser = current.users.cast<UserEntity?>().firstWhere(
          (u) => u?.uid == uid,
          orElse: () => null,
        );
    if (targetUser == null || targetUser.role == UserRole.superAdmin) return;

    final previousUsers = current.users;
    final updated = current.users.where((u) => u.uid != uid).toList();

    // تحديث تفاؤلي فوري في الواجهة
    emit(current.copyWith(users: updated));

    final result = await _deleteUserUseCase(uid);

    result.fold(
      (error) {
        // التراجع في حال حدوث خطأ
        emit(current.copyWith(users: previousUsers));
        emit(UsersError(message: error.message));
      },
      (_) {
        log(
          '---------------- [message] : user deleted successfully [message]----------------',
        );
      },
    );
  }

  Future<void> updateUser(UserEntity updatedUser) async {
    final current = state;
    if (current is! UsersLoaded) return;

    // حماية: منع تعديل بيانات مسؤول النظام
    if (updatedUser.role == UserRole.superAdmin) return;

    final previousUsers = current.users;
    final updatedList = current.users.map((u) {
      if (u.uid != updatedUser.uid) return u;
      return updatedUser;
    }).toList();

    emit(current.copyWith(users: updatedList));

    final result = await _updateUserUseCase(updatedUser);

    result.fold(
      (error) {
        emit(current.copyWith(users: previousUsers));
        emit(UsersError(message: error.message));
      },
      (_) {
        log(
          '---------------- [message] : user updated successfully [message]----------------',
        );
      },
    );
  }
}
