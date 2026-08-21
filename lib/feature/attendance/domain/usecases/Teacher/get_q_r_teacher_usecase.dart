import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class GetQRTeacherUsecase {
  final AttendanceRepo repo;

  GetQRTeacherUsecase(this.repo);

  Future<Either<String, QREntity>> call(String schoolId) async {
    return await repo.getQRTeacher(schoolId);
  }
}
