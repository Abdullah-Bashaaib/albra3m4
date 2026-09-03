import 'package:albra3m4/core/messages.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/add_teacher_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/delete_teacher_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/get_teachers_usecase.dart';
import 'package:albra3m4/feature/teachers_management/domain/usecases/update_teacher_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'teacher_state.dart';

class TeacherCubit extends Cubit<TeacherState> {
  final GetTeachersUsecase getTeachersUsecase;
  final AddTeacherUsecase addTeacherUsecase;
  final UpdateTeacherUsecase updateTeacherUsecase;
  final DeleteTeacherUsecase deleteTeacherUsecase;

  TeacherCubit({
    required this.getTeachersUsecase,
    required this.addTeacherUsecase,
    required this.updateTeacherUsecase,
    required this.deleteTeacherUsecase,
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

  void addTeacher(UserEntity teacher) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await addTeacherUsecase(teacher);
    result.fold(
      (l) {
        emit(state.copyWith(isLoading: false, error: l));
      },
      (r) {
        final teachers = [teacher, ...state.teachers];
        emit(
          state.copyWith(
            isLoading: false,
            success: addSuccess,
            teachers: teachers,
          ),
        );
      },
    );
  }

  void updateTeacher(UserEntity teacher) {
    final teachers = state.teachers.map((item) {
      if (item.uid == teacher.uid) {
        return teacher;
      }

      return item;
    }).toList();

    emit(state.copyWith(teachers: teachers));
  }

  void deleteTeacher(String teacherId) {
    final teachers = state.teachers
        .where((teacher) => teacher.uid != teacherId)
        .toList();

    emit(state.copyWith(teachers: teachers));
  }
}
