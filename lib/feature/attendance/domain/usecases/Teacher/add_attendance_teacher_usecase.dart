import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class AddAttendanceTeacherUsecase {
  final AttendanceRepo repo;

  AddAttendanceTeacherUsecase(this.repo);

  Future<Either<String, Unit>> call(TeacherAttendanceEntity attendance) async {
    return await repo.addAttendanceTeacher(attendance);
  }
}
