import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';

class UpdateTeacherUsecase {
  final TeacherRepo repo;

  UpdateTeacherUsecase(this.repo);

  Future<Either<String, Unit>> call(UserEntity user) async {
    return await repo.updateTeacher(user);
  }
}
