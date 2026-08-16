import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:dartz/dartz.dart';

class AddQRUsecase {
  final AttendanceRepo repo;

  AddQRUsecase(this.repo);

  Future<Either<String, Unit>> call(QREntity code) async {
    return repo.addQR(code);
  }
}
