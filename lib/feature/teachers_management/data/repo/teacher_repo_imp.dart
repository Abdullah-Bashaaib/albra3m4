import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/core/messages.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/data/models/teacher_model.dart';
import 'package:albra3m4/feature/teachers_management/data/source/teacher_local.dart';
import 'package:albra3m4/feature/teachers_management/data/source/teacher_remote.dart';
import 'package:albra3m4/feature/teachers_management/domain/repo/teacher_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class TeacherRepoImp implements TeacherRepo {
  final InternetConnectionChecker conn;
  final TeacherLocal local;
  final TeacherRemote remote;

  TeacherRepoImp(this.conn, this.local, this.remote);

  @override
  Future<Either<String, Unit>> addTeacher(UserEntity user) async {
    try {
      if (!await conn.hasConnection) {
        return left(offline);
      }
      final uModel = UserModel.fromEntity(user);
      final tModel = TeacherModel.fromEntity(user.tDetails!);

      await remote.addTeacher(uModel, tModel);
      try {
        await local.addTeacher(uModel, tModel);
        return right(unit);
      } on LocalException catch (e) {
        return left(e.message);
      }
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, Unit>> deleteTeacher(String userId) async {
    try {
      if (!await conn.hasConnection) {
        return left(offline);
      }
      await remote.deleteTeacher(userId);

      try {
        await local.deleteTeacher(userId);
        return right(unit);
      } on LocalException catch (e) {
        return left(e.message);
      }
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, List<UserEntity>>> getTeacher(String schoolId) async {
    try {
      try {
        final result = await local.getTeacher();

        final teachers = result
            .map((model) => UserEntity.fromModel(model))
            .toList();

        if (teachers.isNotEmpty) {
          return right(teachers);
        }
      } on LocalException catch (e) {
        return left(e.message);
      }
      print('===================== vvvvvv ========================');
      final result = await remote.getTeacher(schoolId);

      final teachers = result
          .map((model) => UserEntity.fromModel(model))
          .toList();
    print(teachers.length);
      return right(teachers);
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, Unit>> updateTeacher(UserEntity user) async {
    try {
      if (!await conn.hasConnection) {
        return left(offline);
      }
      final uModel = UserModel.fromEntity(user);
      final tModel = TeacherModel.fromEntity(user.tDetails!);

      await remote.updateTeacher(uModel, tModel);
      try {
        await local.updateTeacher(uModel, tModel);
        return right(unit);
      } on LocalException catch (e) {
        return left(e.message);
      }
    } on ServerException catch (e) {
      return left(e.message);
    }
  }
}
