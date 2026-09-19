import 'package:albra3m4/core/messages.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/delete_teacher_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/get_teachers_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/save_teacher_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/sync_teacher_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'teacher_state.dart';

class TeacherCubit extends Cubit<TeacherState> {
  final GetTeachersUsecase getTeachersUsecase;
  final SaveTeacherUsecase saveTeacherUsecase;
  final DeleteTeacherUsecase deleteTeacherUsecase;
  final SyncTeachersUseCase syncTeachersUseCase;

  TeacherCubit({
    required this.getTeachersUsecase,
    required this.saveTeacherUsecase,
    required this.deleteTeacherUsecase,
    required this.syncTeachersUseCase,
  }) : super(TeacherState()) {
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await getTeachersUsecase('1');
    result.fold(
      (l) {
        emit(state.copyWith(isLoading: false, error: l));
      },
      (r) {
        emit(state.copyWith(isLoading: false, teachers: r));
      },
    );
  }

  void search(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      emit(state.copyWith(query: '', resultSearch: []));
      return;
    }

    final result = state.teachers.where((teacher) {
      return teacher.fullName.contains(query);
    }).toList();

    emit(state.copyWith(query: query, resultSearch: result));
  }

  Future<void> saveTeacher(UserEntity teacher) async {
    emit(state.copyWith(isLoadingEdit: true, error: null));

    final result = await saveTeacherUsecase(teacher);

    result.fold(
      (l) {
        emit(state.copyWith(isLoadingEdit: false, error: l));
      },
      (r) {
        final teachers = state.teachers.map((item) {
          if (item.uid == teacher.uid) {
            return teacher;
          }

          return item;
        }).toList();

        emit(
          state.copyWith(
            isLoadingEdit: false,
            success: saveSuccess,
            teachers: teachers,
          ),
        );
      },
    );
    emit(state.copyWith(success: null, error: null));
  }

  Future<void> deleteTeacher(String teacherId) async {
    emit(state.copyWith(isLoadingDelete: true, error: null));
    final result = await deleteTeacherUsecase(teacherId);
    result.fold(
      (l) {
        emit(state.copyWith(isLoadingDelete: false, error: l));
      },
      (r) {
        final teachers = state.teachers
            .where((teacher) => teacher.uid != teacherId)
            .toList();

        emit(
          state.copyWith(
            isLoadingDelete: false,
            success: deleteSuccess,
            teachers: teachers,
          ),
        );
      },
    );
  }

  Future<void> syncTeachers() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await syncTeachersUseCase('1');

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure));
      },
      (teachers) {
        emit(
          state.copyWith(
            isLoading: false,
            teachers: teachers,
            success: 'تم تحديث بيانات المعلمات بنجاح',
          ),
        );
      },
    );
  }
}
