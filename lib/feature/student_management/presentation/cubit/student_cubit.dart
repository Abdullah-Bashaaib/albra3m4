import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/repo/student_repo.dart';

part 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepo _repo;

  StudentCubit(this._repo) : super(const StudentState());

  // ─── Load ────────────────────────────────────────────────────────────────

  Future<void> loadStudents() async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    final result = await _repo.getStudents();
    result.fold((err) => emit(state.copyWith(isLoading: false, error: err)), (
      list,
    ) {
      final displayed = _applyFilter(list, state.selectedClass, state.query);
      emit(
        state.copyWith(
          isLoading: false,
          students: list,
          displayedStudents: displayed,
        ),
      );
    });
  }

  // ─── Save (Add / Edit) ───────────────────────────────────────────────────

  Future<void> saveStudent(StudentEntity student) async {
    emit(state.copyWith(isLoadingSave: true, error: null, success: null));
    final result = await _repo.saveStudent(student);
    result.fold(
      (err) => emit(state.copyWith(isLoadingSave: false, error: err)),
      (_) {
        final updated = _upsert(state.students, student);
        final displayed = _applyFilter(
          updated,
          state.selectedClass,
          state.query,
        );
        emit(
          state.copyWith(
            isLoadingSave: false,
            students: updated,
            displayedStudents: displayed,
            success: 'تم حفظ بيانات الطالب',
          ),
        );
      },
    );
  }

  // ─── Delete ──────────────────────────────────────────────────────────────

  Future<void> deleteStudent(String id) async {
    emit(state.copyWith(isLoadingDelete: true, error: null, success: null));
    final result = await _repo.deleteStudent(id);
    result.fold(
      (err) => emit(state.copyWith(isLoadingDelete: false, error: err)),
      (_) {
        final updated = state.students.where((s) => s.id != id).toList();
        final displayed = _applyFilter(
          updated,
          state.selectedClass,
          state.query,
        );
        emit(
          state.copyWith(
            isLoadingDelete: false,
            students: updated,
            displayedStudents: displayed,
            success: 'تم حذف الطالب',
          ),
        );
      },
    );
  }

  // ─── Update Grades ───────────────────────────────────────────────────────

  Future<void> updateGrades(
    String studentId,
    List<SubjectGrades> grades,
  ) async {
    emit(state.copyWith(isLoadingSave: true, error: null, success: null));
    final result = await _repo.updateGrades(studentId, grades);
    result.fold(
      (err) => emit(state.copyWith(isLoadingSave: false, error: err)),
      (_) {
        final updated = state.students.map((s) {
          return s.id == studentId ? s.copyWith(grades: grades) : s;
        }).toList();
        final displayed = _applyFilter(
          updated,
          state.selectedClass,
          state.query,
        );
        emit(
          state.copyWith(
            isLoadingSave: false,
            students: updated,
            displayedStudents: displayed,
            success: 'تم حفظ الدرجات',
          ),
        );
      },
    );
  }

  // ─── Promote Class ───────────────────────────────────────────────────────

  Future<void> promoteClass(StudentEntity student) async {
    final next = student.classroom.next;
    if (next == null) {
      emit(state.copyWith(error: 'هذا الطالب في أعلى مرحلة'));
      return;
    }
    final promoted = student.copyWith(classroom: next);
    await saveStudent(promoted);
  }

  // ─── Filter & Search ─────────────────────────────────────────────────────

  void filterByClass(KindergartenClass? classroom) {
    final displayed = _applyFilter(state.students, classroom, state.query);
    emit(
      state.copyWith(selectedClass: classroom, displayedStudents: displayed),
    );
  }

  void search(String query) {
    final displayed = _applyFilter(state.students, state.selectedClass, query);
    emit(state.copyWith(query: query, displayedStudents: displayed));
  }

  // ─── Ranking ─────────────────────────────────────────────────────────────

  /// إرجاع قائمة الطلاب مرتبة تنازليًا حسب المتوسط العام
  List<StudentEntity> get rankedStudents {
    final sorted = List<StudentEntity>.from(state.students)
      ..sort((a, b) => b.overallAverage.compareTo(a.overallAverage));
    return sorted;
  }

  /// إرجاع ترتيب طالب معيّن بين أقرانه في نفس الصف
  int rankInClass(StudentEntity student) {
    final classmates =
        state.students.where((s) => s.classroom == student.classroom).toList()
          ..sort((a, b) => b.overallAverage.compareTo(a.overallAverage));
    return classmates.indexWhere((s) => s.id == student.id) + 1;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<StudentEntity> _applyFilter(
    List<StudentEntity> all,
    KindergartenClass? cls,
    String query,
  ) {
    var list = all;
    if (cls != null) {
      list = list.where((s) => s.classroom == cls).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((s) => s.fullName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<StudentEntity> _upsert(List<StudentEntity> all, StudentEntity student) {
    final idx = all.indexWhere((s) => s.id == student.id);
    final list = List<StudentEntity>.from(all);
    if (idx >= 0) {
      list[idx] = student;
    } else {
      list.add(student);
    }
    return list;
  }
}
