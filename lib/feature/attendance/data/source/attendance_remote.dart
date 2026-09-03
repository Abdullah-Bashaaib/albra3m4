import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';
import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AttendanceRemote {
  /// Teacher
  Future<QRModel> getQR(String schoolId);
  Future<void> addQR(QRModel code);
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance);

  /// Students
}

class AttendanceRemoteImp implements AttendanceRemote {
  final FirebaseFirestore firestore;

  AttendanceRemoteImp({required this.firestore});

  @override
  Future<QRModel> getQR(String schoolId) async {
    try {
      final snapshot = await firestore
          .collection('attendanceCode')
          .doc(schoolId.toString())
          .get();

      if (!snapshot.exists) {
        throw ServerException('QR code not found');
      }
      return QRModel.fromJson(snapshot.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addQR(QRModel code) async {
    try {
      await firestore
          .collection('attendanceCode')
          .doc(code.schoolId.toString())
          .set(code.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance) async {
    try {
      final date =
          '${attendance.date.year}-'
          '${attendance.date.month.toString().padLeft(2, '0')}-'
          '${attendance.date.day.toString().padLeft(2, '0')}';
      await firestore
          .collection('teacherAttendance')
          .doc(date)
          .collection('teachers')
          .doc(attendance.userId.toString())
          .set(attendance.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

}
