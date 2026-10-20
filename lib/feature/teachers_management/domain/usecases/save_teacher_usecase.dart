import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';

class SaveTeacherUsecase {
  final TeacherRepo repo;

  SaveTeacherUsecase(this.repo);

  Future<Either<String, Unit>> call(UserEntity user) async {
    return await repo.saveTeacher(user);
  }
}
