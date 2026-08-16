import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AttendanceRepo {
  /// Teacher
  Future<Either<String, QREntity>> getQR();
  Future<Either<String, Unit>> addQR(QREntity code);
  Future<Either<String, Unit>> addAttendanceTeacher(
    TeacherAttendanceEntity attendance,
  );

  /// Students
  
}
