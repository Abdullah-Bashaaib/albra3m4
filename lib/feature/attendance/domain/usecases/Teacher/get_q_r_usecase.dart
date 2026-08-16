import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class GetQRUsecase {
  final AttendanceRepo repo;

  GetQRUsecase(this.repo);
  
  Future<Either<String, QREntity>> call() async {
    return await repo.getQR();
  }
}