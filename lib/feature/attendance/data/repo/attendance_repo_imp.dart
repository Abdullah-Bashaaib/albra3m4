import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class AttendanceRepoImp implements AttendanceRepo {
  /// Teacher
  @override
  Future<Either<String, Unit>> addAttendanceTeacher(
    TeacherAttendanceEntity attendance,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, Unit>> addQR(QREntity code) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, QREntity>> getQR() {
    throw UnimplementedError();
  }

  /// Students
}
