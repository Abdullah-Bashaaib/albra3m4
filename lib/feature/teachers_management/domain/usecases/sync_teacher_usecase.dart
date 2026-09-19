import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';

class SyncTeachersUseCase {
  final TeacherRepo repository;

  SyncTeachersUseCase(this.repository);

  Future<Either<String, List<UserEntity>>> call(String schoolId) async {
    return await repository.syncTeachers(schoolId);
  }
}
