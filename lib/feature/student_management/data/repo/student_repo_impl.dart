import 'package:dartz/dartz.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repo/student_repo.dart';
import '../source/student_local_source.dart';
import '../source/student_remote_source.dart';

class StudentRepoImpl implements StudentRepo {
  final StudentLocalSource _local;
  final StudentRemoteSource _remote;

  StudentRepoImpl(this._local, this._remote);

  @override
  Future<Either<String, List<StudentEntity>>> getStudents() async {
    try {
      // Try local first for offline support
      final local = await _local.getStudents();
      if (local.isNotEmpty) return Right(local);

      final remote = await _remote.getStudents();
      // cache to local
      for (final s in remote) {
        await _local.saveStudent(s);
      }
      return Right(remote);
    } catch (e) {
      return Left('حدث خطأ أثناء تحميل الطلاب: $e');
    }
  }

  @override
  Future<Either<String, void>> saveStudent(StudentEntity student) async {
    try {
      await _local.saveStudent(student);
      await _remote.saveStudent(student);
      return const Right(null);
    } catch (e) {
      return Left('حدث خطأ أثناء الحفظ: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteStudent(String id) async {
    try {
      await _local.deleteStudent(id);
      await _remote.deleteStudent(id);
      return const Right(null);
    } catch (e) {
      return Left('حدث خطأ أثناء الحذف: $e');
    }
  }

  @override
  Future<Either<String, void>> updateGrades(
    String studentId,
    List<SubjectGrades> grades,
  ) async {
    try {
      final students = await _local.getStudents();
      final student = students.firstWhere((s) => s.id == studentId);
      final updated = student.copyWith(grades: grades);
      await _local.saveStudent(updated);
      await _remote.saveStudent(updated);
      return const Right(null);
    } catch (e) {
      return Left('حدث خطأ أثناء تحديث الدرجات: $e');
    }
  }
}
