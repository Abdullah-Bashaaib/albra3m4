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
      await perf.setString(attendanceDateKey, DateTime.now().toIso8601String());
      await perf.setString(attendanceStatus, attendance.status);
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> addQR(QRModel code) async {
    try {
      perf.setString('idQR', code.id);
      perf.setString('school_id', code.schoolId);
      perf.setString('school_name', code.schoolName);
      perf.setString(currentQRKey, code.code);
      perf.setString('date', code.date?.toIso8601String() ?? '');
      perf.setString('start_time', code.startTime);
      perf.setString('end_time', code.endTime);
      perf.setString('created_by', code.createdBy);
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<QRModel?> getQR() async {
    try {
      final String? idQ = perf.getString('idQR');
      final String? school = perf.getString('school_id');
      final String? schoolName = perf.getString('school_name');
      final String? currentQR = perf.getString(currentQRKey);
      final String? dateQ = perf.getString('date');
      final String? startTime = perf.getString('start_time');
      final String? endTime = perf.getString('end_time');
      final String? createdBy = perf.getString('created_by');

      final qrModel = QRModel(
        id: idQ ?? '',
        schoolId: school ?? '',
        schoolName: schoolName ?? '',
        code: currentQR ?? '',
        date: dateQ != null ? DateTime.parse(dateQ) : null,
        startTime: startTime ?? '',
        endTime: endTime ?? '',
        createdBy: createdBy ?? '',
      );
      return qrModel;
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<bool> checkCode() async {
    try {
      final savedDateString = perf.getString(attendanceDateKey);
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
