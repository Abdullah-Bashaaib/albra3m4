import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';
import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AttendanceRemote {
  /// Teacher
  Future<QRModel> getQR();
  Future<void> addQR(QRModel code);
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance);

  /// Students
}

class AttendanceRemoteImp implements AttendanceRemote {
  final FirebaseFirestore firestore;

  AttendanceRemoteImp({required this.firestore});

  @override
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance) {
    throw UnimplementedError();
  }

  @override
  Future<void> addQR(QRModel code) {
    throw UnimplementedError();
  }

  @override
  Future<QRModel> getQR() {
    throw UnimplementedError();
  }
}
