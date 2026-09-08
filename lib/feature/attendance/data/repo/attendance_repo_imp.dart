import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';
import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';
import 'package:albra3m4/feature/attendance/data/source/attendance_local.dart';
import 'package:albra3m4/feature/attendance/data/source/attendance_remote.dart';
import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AttendanceRepoImp implements AttendanceRepo {
  final InternetConnectionChecker conn;
  final AttendanceRemote remote;
  final AttendanceLocal local;

  AttendanceRepoImp(this.conn, this.remote, this.local);

  /// Teacher
  @override
  Future<Either<String, Unit>> addAttendanceTeacher(
    TeacherAttendanceEntity attendance,
  ) async {
    try {
      if (!await conn.hasConnection) {
        return Left('لا يوجد اتصال بالإنترنت');
      }

      final model = TeacherAttendanceModel.fromEntity(attendance);

      await remote.addAttendanceTeacher(model);
      try {
        await local.addAttendanceTeacher(model);
        return const Right(unit);
      } on LocalException catch (e) {
        return left(e.message);
      }
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, Unit>> addQR(QREntity code) async {
    try {
      if (!await conn.hasConnection) {
        return Left('لا يوجد اتصال بالإنترنت');
      }

      final model = QRModel.fromEntity(code);

      await remote.addQR(model);
      try {
        await local.addQR(model);
        return const Right(unit);
      } on LocalException catch (e) {
        return left(e.message);
      }
    } on ServerException catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, QREntity>> getQR(String schoolId) async {
    try {
      final qr = await local.getQR();
      final code = qr?.code ?? '';
      if (code.isEmpty) {
        if (!await conn.hasConnection) {
          return left('لا يوجد اتصال بالإنترنت');
        }

        final model = await remote.getQR(schoolId);
        try {
          final entity = QREntity.fromModel(model);
          await local.addQR(model);
          return Right(entity);
        } on LocalException catch (e) {
          return left(e.message);
        }
      } else {
        return right(qr!);
      }
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, bool>> checkCode() async {
    try {
      final codeDate = await local.checkCode();
      return right(codeDate);
    } on LocalException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, QREntity>> getQRTeacher(String schoolId) async {
    try {
      final model = await remote.getQR(schoolId);
      // print('===============================================');
      final entity = QREntity.fromModel(model);
      // print(entity.endTime);
      return right(entity);
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, List<TeacherAttendanceEntity>>>
  getTeacherAttendanceByDate(String date) async {
    try {
      if (!await conn.hasConnection) {
        return left('لا يوجد اتصال بالإنترنت');
      }
      final models = await remote.getTeacherAttendanceByDate(date);
      final entities = models
          .map((m) => TeacherAttendanceEntity.fromModel(m))
          .toList();
      return right(entities);
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  @override
  Future<Either<String, DateTime>> getDateTimeFromService() async {
    try {
      if (!await conn.hasConnection) {
        return left('لا يوجد اتصال بالإنترنت');
      }
      final dateTime = await remote.getDateTimeFromService();
      return right(dateTime);
    } on ServerException catch (e) {
      return left(e.message);
    }
  }

  /// Students
}
