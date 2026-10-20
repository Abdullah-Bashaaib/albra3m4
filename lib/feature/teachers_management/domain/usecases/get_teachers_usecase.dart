import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';

class GetTeachersUsecase {
  final TeacherRepo repo;

  GetTeachersUsecase(this.repo);

  Future<Either<String, List<UserEntity>>> call(String schoolId) async {
    return await repo.getTeacher(schoolId);
  }
}
