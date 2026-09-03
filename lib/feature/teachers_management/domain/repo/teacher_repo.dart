import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class TeacherRepo {
  Future<Either<String, List<UserEntity>>> getTeacher(String schoolId);
  Future<Either<String, Unit>> addTeacher(UserEntity user);
  Future<Either<String, Unit>> updateTeacher(UserEntity user);
  Future<Either<String, Unit>> deleteTeacher(String userId);
}
