import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/core/utils/perf_keys.dart';
import 'package:albra3m4/feature/attendance/data/models/q_r_model.dart';
import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AttendanceLocal {
  /// Teacher
  Future<QRModel?> getQR();
  Future<void> addQR(QRModel code);
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance);
  Future<bool> checkCode();

  /// Students
}

class AttendanceLocalImp implements AttendanceLocal {
  // final DatabaseHelper helper;
  final SharedPreferences perf;

  AttendanceLocalImp(
    // this.helper,
    this.perf,
  );

  @override
  Future<void> addAttendanceTeacher(TeacherAttendanceModel attendance) async {
    try {
      await perf.setString(
        PerfKeys.attendanceDateKey,
        DateTime.now().toIso8601String(),
      );
      await perf.setString(PerfKeys.attendanceStatus, attendance.status);
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> addQR(QRModel code) async {
    try {
      perf.setString(PerfKeys.currentQRKey, code.code);
      perf.setString(PerfKeys.schoolIdKey, code.schoolId);
      perf.setString(PerfKeys.schoolNameKey, code.schoolName);
      perf.setString(PerfKeys.currentQRKey, code.code);
      perf.setString(PerfKeys.dateKey, code.date?.toIso8601String() ?? '');
      perf.setInt(PerfKeys.startTimeKey, code.startTime);
      perf.setInt(PerfKeys.endTimeKey, code.endTime);
      perf.setString(PerfKeys.createdByKey, code.createdBy);
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<QRModel?> getQR() async {
    try {
      final String? idQ = perf.getString(PerfKeys.currentQRKey);
      final String? school = perf.getString(PerfKeys.schoolIdKey);
      final String? schoolName = perf.getString(PerfKeys.schoolNameKey);
      final String? currentQR = perf.getString(PerfKeys.currentQRKey);
      final String? dateQ = perf.getString(PerfKeys.dateKey);
      final int? startTimeString = perf.getInt(PerfKeys.startTimeKey);
      final int? endTimeString = perf.getInt(PerfKeys.endTimeKey);
      final String? createdBy = perf.getString(PerfKeys.createdByKey);

      final qrModel = QRModel(
        id: idQ ?? '',
        schoolId: school ?? '',
        schoolName: schoolName ?? '',
        code: currentQR ?? '',
        date: dateQ != null ? DateTime.parse(dateQ) : null,
        startTime: startTimeString ?? 0,
        endTime: endTimeString ?? 0,
        createdBy: createdBy ?? '',
      );
      return qrModel;
    } catch (e) {
      print(e.toString());
      throw LocalException(e.toString());
    }
  }

  @override
  Future<bool> checkCode() async {
    try {
      final savedDateString = perf.getString(PerfKeys.attendanceDateKey);
      if (savedDateString == null) {
        return false;
      }
      final savedDate = DateTime.tryParse(savedDateString);
      if (savedDate == null) {
        return false;
      }
      final toDay = DateTime.now();

      return savedDate.year == toDay.year &&
          savedDate.month == toDay.month &&
          savedDate.day == toDay.day;
    } catch (e) {
      throw LocalException(e.toString());
    }
  }
}
