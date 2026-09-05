import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class GetTeacherAttendanceByDateUsecase {
  final AttendanceRepo repo;
  GetTeacherAttendanceByDateUsecase(this.repo);

  Future<Either<String, List<TeacherAttendanceEntity>>> call(String date) {
    return repo.getTeacherAttendanceByDate(date);
  }
}
