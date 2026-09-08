import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class GetDateTimeFromServiceUsecase {
  final AttendanceRepo repo;

  GetDateTimeFromServiceUsecase(this.repo);

  Future<Either<String, DateTime>> call() async {
    return await repo.getDateTimeFromService();
  }
}