import 'dart:convert';

import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';
import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

abstract class AttendanceRemote {
  /// Teacher
  Future<QRModel> getQR(String schoolId);
  Future<void> addQR(QRModel code);
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance);
  Future<List<TeacherAttendanceModel>> getTeacherAttendanceByDate(String date);
  Future<DateTime> getDateTimeFromService();

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

  @override
  Future<List<TeacherAttendanceModel>> getTeacherAttendanceByDate(
    String date,
  ) async {
    try {
      final snapshot = await firestore
          .collection('teacherAttendance')
          .doc(date)
          .collection('teachers')
          .get();
      return snapshot.docs
          .map((doc) => TeacherAttendanceModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DateTime> getDateTimeFromService() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://timeapi.io/api/Time/current/zone?timeZone=Asia/Aden',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('فشل في جلب وقت السيرفر');
      }

      final data = jsonDecode(response.body);

      return DateTime.parse(data['dateTime']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
