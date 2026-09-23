import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class CheckCodeUsecase {
  final AttendanceRepo repo;

  CheckCodeUsecase(this.repo);

  Future<Either<String, String>> call() async {
    return await repo.checkCode();
  }
}
