import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';

class DeleteTeacherUsecase {
  final TeacherRepo repo;

  DeleteTeacherUsecase(this.repo);

  Future<Either<String, Unit>> call(String userId) async {
    return await repo.deleteTeacher(userId);
  }
}
