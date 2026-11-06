import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/use_cases/update_teacher_permissions_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

sealed class TeacherPermissionsState extends Equatable {
  const TeacherPermissionsState();
  @override
  List<Object?> get props => [];
}

final class TeacherPermissionsIdle extends TeacherPermissionsState {
  const TeacherPermissionsIdle();
}

final class TeacherPermissionsSaving extends TeacherPermissionsState {
  const TeacherPermissionsSaving();
}

final class TeacherPermissionsSaved extends TeacherPermissionsState {
  final UserEntity user;
  const TeacherPermissionsSaved(this.user);
  @override
  List<Object?> get props => [user.uid, ...user.permissions];
}

final class TeacherPermissionsError extends TeacherPermissionsState {
  final String message;
  const TeacherPermissionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class TeacherPermissionsCubit extends Cubit<TeacherPermissionsState> {
  final UpdateTeacherPermissionsUseCase _update;
  TeacherPermissionsCubit(this._update) : super(const TeacherPermissionsIdle());

  Future<void> save(UserEntity teacher, List<AppPermission> permissions) async {
    if (state is TeacherPermissionsSaving) return;
    if (teacher.role != UserRole.teacher) {
      emit(const TeacherPermissionsError('هذه التكليفات مخصصة للمعلمات فقط.'));
      return;
    }
    emit(const TeacherPermissionsSaving());
    final result = await _update(teacher.uid, permissions);
    result.fold(
      (failure) => emit(TeacherPermissionsError(failure.message)),
      (updated) => emit(TeacherPermissionsSaved(updated)),
    );
  }
}
