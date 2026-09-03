import 'dart:developer';

import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/use_cases/get_all_users_use_case.dart';
import 'package:bloc/bloc.dart';

import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._getAllUsersUseCase) : super(UsersInitial());

  final GetAllUsersUseCase _getAllUsersUseCase;

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

  void changeUserRole(String uid, UserRole newRole) {
    final current = state;
    if (current is! UsersLoaded) return;
    final updated = current.users.map((u) {
      if (u.uid != uid) return u;
      return u.copyWith(role: newRole);
    }).toList();
    emit(current.copyWith(users: updated));
    // TODO: استدعاء use case حقيقي لتحديث role في Firestore عبر UserModel
  }

  void deleteUser(String uid) {
    final current = state;
    if (current is! UsersLoaded) return;
    final updated = current.users.where((u) => u.uid != uid).toList();
    emit(current.copyWith(users: updated));
    // TODO: استدعاء use case حقيقي لحذف المستخدم من Firestore (بعد التأكيد المزدوج بالواجهة)
  }
}
