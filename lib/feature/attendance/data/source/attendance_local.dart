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
  Future<String> checkCode();

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
      if (attendance.departureTime != '0' &&
          attendance.departureTime!.isNotEmpty) {
        await perf.setString(
          PerfKeys.departureDateKey,
          DateTime.now().toIso8601String(),
        );
      } else {
        await perf.setString(
          PerfKeys.attendanceDateKey,
          DateTime.now().toIso8601String(),
        );
      }
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
      perf.setInt(PerfKeys.arrivalTimeKey, code.arrivalTime);
      perf.setInt(PerfKeys.departureTimeKey, code.departureTime);
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
      final int? arrivalTimeString = perf.getInt(PerfKeys.arrivalTimeKey);
      final int? departureTimeString = perf.getInt(PerfKeys.departureTimeKey);
      final String? createdBy = perf.getString(PerfKeys.createdByKey);

      final qrModel = QRModel(
        id: idQ ?? '',
        schoolId: school ?? '',
        schoolName: schoolName ?? '',
        code: currentQR ?? '',
        date: dateQ != null ? DateTime.parse(dateQ) : null,
        arrivalTime: arrivalTimeString ?? 0,
        departureTime: departureTimeString ?? 0,
        createdBy: createdBy ?? '',
      );
      return qrModel;
    } catch (e) {
      // print(e.toString());
      throw LocalException(e.toString());
    }
  }

  @override
  Future<String> checkCode() async {
    try {
      final savedDateString = perf.getString(PerfKeys.attendanceDateKey);
      final departureDateString = perf.getString(PerfKeys.departureDateKey);
      final toDay = DateTime.now();

      bool hasAttendance = false;
      bool hasDeparture = false;

      if (savedDateString != null) {
        final savedDate = DateTime.tryParse(savedDateString);
        if (savedDate != null &&
            savedDate.year == toDay.year &&
            savedDate.month == toDay.month &&
            savedDate.day == toDay.day) {
          hasAttendance = true;
        }
      }

      if (departureDateString != null) {
        final departureDate = DateTime.tryParse(departureDateString);
        if (departureDate != null &&
            departureDate.year == toDay.year &&
            departureDate.month == toDay.month &&
            departureDate.day == toDay.day) {
          hasDeparture = true;
        }
      }

      if (hasAttendance && hasDeparture) return 'departure';
      if (hasAttendance) return 'attendance';
      return 'none';
    } catch (e) {
      // print(e.toString());
      throw LocalException(e.toString());
    }
  }
}
