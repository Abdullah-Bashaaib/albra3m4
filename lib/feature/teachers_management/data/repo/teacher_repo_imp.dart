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
      // print('===================== vvvvvv ========================');
      final result = await remote.getTeacher(schoolId);
      // print(result.length);

      final teachers = result
          .map((model) => UserEntity.fromModel(model))
          .toList();
      return right(teachers);
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, Unit>> saveTeacher(UserEntity user) async {
    try {
      if (!await conn.hasConnection) {
        return left(offline);
      }
      final uModel = UserModel.fromEntity(user);
      final tModel = TeacherModel.fromEntity(user.tDetails!);

      await remote.saveTeacher(uModel, tModel);
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

  @override
  Future<Either<String, List<UserEntity>>> syncTeachers(String schoolId) async {
    try {
      // جلب البيانات من Firebase
      final remoteTeachers = await remote.getTeacher(schoolId);

      // جلب البيانات الموجودة في Local
      final localTeachers = await local.getTeacher();

      // تحويل البيانات المحلية إلى Map باستخدام uid
      final localMap = {
        for (final teacher in localTeachers) teacher.uid: teacher,
      };

      // إضافة أو تحديث البيانات
      for (final remoteTeacher in remoteTeachers) {
        final teacherDetails = remoteTeacher.tDetails;

        // لا توجد بيانات مقابلة للمعلمة
        if (teacherDetails == null) {
          continue;
        }

        // تحويل Entity إلى Model
        final teacherModel = TeacherModel.fromEntity(teacherDetails);

        final localTeacher = localMap[remoteTeacher.uid];

        if (localTeacher == null) {
          // المعلمة جديدة في Local
          await local.addTeacher(remoteTeacher, teacherModel);
        } else {
          // المعلمة موجودة مسبقًا
          await local.updateTeacher(remoteTeacher, teacherModel);
        }
      }

      // حذف المعلمات التي لم تعد موجودة في Firebase
      final remoteIds = remoteTeachers.map((teacher) => teacher.uid).toSet();

      for (final localTeacher in localTeachers) {
        if (!remoteIds.contains(localTeacher.uid)) {
          await local.deleteTeacher(localTeacher.uid);
        }
      }

      final updatedTeachers = await local.getTeacher();

      return Right(updatedTeachers);
    } on ServerException catch (e) {
      return left(e.message);
    } on LocalException catch (e) {
      return left(e.message);
    } catch (e) {
      return left(e.toString());
    }
  }
}
