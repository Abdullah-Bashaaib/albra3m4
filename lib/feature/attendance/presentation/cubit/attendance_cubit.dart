import 'dart:math';

import 'package:albra3m4/core/messages.dart';
import 'package:albra3m4/core/utils/perf_keys.dart';
import 'package:albra3m4/feature/attendance/domain/entities/q_r_entity.dart';
import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/add_attendance_teacher_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/add_q_r_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/check_code.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/get_q_r_teacher_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/get_q_r_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final GetQRUsecase getQRUsecase;
  final AddQRUsecase addQRUsecase;
  final CheckCodeUsecase checkCodeUsecase;
  final AddAttendanceTeacherUsecase addAttendanceTeacherUsecase;
  final GetQRTeacherUsecase getQRTeacherUsecase;

  AttendanceCubit({
    required this.getQRUsecase,
    required this.addQRUsecase,
    required this.checkCodeUsecase,
    required this.addAttendanceTeacherUsecase,
    required this.getQRTeacherUsecase,
  }) : super(AttendanceState());

  attendanceTrue() {
    for (final student in state.students) {
      state.attendanceStatus[student['id']] = true;
    }
  }

  updateAttendance(String studentId) {}
  removeAbsence(String studentId) {}

  // تحميل بيانات الشاشة
  Future<void> loadAttendanceCode() async {
    emit(state.copyWith(isLoading: true, error: null));
    final qr = await getQRUsecase('1');
    qr.fold(
      (l) {
        emit(state.copyWith(isLoading: false, error: l));
      },
      (r) {
        emit(state.copyWith(isLoading: false, attendanceQR: r));
      },
    );
  }

  // حفظ كود جديد
  Future<void> saveAttendanceCode(String code) async {
    if (code.isEmpty) {
      emit(state.copyWith(error: 'ادخل الباركورد اولا'));
      return;
    }
    emit(state.copyWith(isLoadingQ: true, error: null, success: null));
    final Uuid uuid = Uuid();
    final id = uuid.v4();
    final qr = QREntity(
      id: id,
      schoolId: '1',
      schoolName: 'روضة البراعم',
      code: state.attendanceQR?.code ?? '',
      date: state.attendanceQR?.date ?? DateTime.now(),
      startTime: '8:00Am',
      endTime: '11:00AM',
      createdBy: '1',
    );
    final result = await addQRUsecase(qr);
    result.fold(
      (l) {
        emit(state.copyWith(isLoadingQ: false, error: l));
      },
      (r) {
        emit(
          state.copyWith(
            isLoadingQ: false,
            success: addSuccess,
            attendanceQR: qr,
          ),
        );
      },
    );
  }

  // إنشاء كود عشوائي
  String generateNewCode() {
    final newCode = _generateRandomCode();
    final currentQR = state.attendanceQR;
    final Uuid uuid = Uuid();
    final id = uuid.v4();

    final qr = currentQR != null
        ? currentQR.copyWith(code: newCode, date: DateTime.now())
        : QREntity(
            id: id,
            schoolId: '1',
            schoolName: 'روضة البراعم',
            code: newCode,
            date: DateTime.now(),
            startTime: '8:00Am',
            endTime: '11:00AM',
            createdBy: '1',
          );
    emit(state.copyWith(attendanceQR: qr));

    return newCode;
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // وقت بداية التحضير
  final int allowedStartHour = 7;

  // وقت نهاية التحضير
  final int allowedEndHour = 9;

  // بعد كم دقيقة يصبح المعلم متأخرًا
  final int lateMinuteThreshold = 30;

  Future<String> getQR() async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    final result = await getQRUsecase('1');
    return result.fold(
      (l) {
        emit(state.copyWith(isLoading: false, error: l));
        return '';
      },
      (r) {
        emit(state.copyWith(isLoading: true, attendanceQR: r));
        return r.code;
      },
    );
  }

  Future<void> initializeScanning() async {
    await getQRTeacher();

    await checkAttendanceDone();
  }

  Future<void> getQRTeacher() async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    final result = await getQRTeacherUsecase('1');
    return result.fold(
      (l) {
        emit(state.copyWith(isLoading: false, error: l));
      },
      (r) {
        emit(
          state.copyWith(
            isLoading: false,
            attendanceQR: r,
            currentAttendanceCode: r.code,
          ),
        );
      },
    );
  }

  Future<void> checkAttendanceDone() async {
    // emit(state.copyWith(isLoading: true, error: null));
    final result = await checkCodeUsecase();

    result.fold(
      (error) {
        emit(state.copyWith(error: error));
      },
      (done) {
        emit(state.copyWith(attendanceDone: done));
      },
    );
  }

  Future<void> handleScan(String scannedCode) async {
    emit(state.copyWith(isLoading: true, error: null));
    if (state.attendanceDone) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'لقد قمت بتسجيل حضورك اليوم بالفعل.',
        ),
      );
      return;
    }

    if (state.currentAttendanceCode == null) {
      emit(
        state.copyWith(isLoading: false, error: 'كود الحضور غير متوفر حاليًا.'),
      );
      return;
    }

    String extractedCode = scannedCode;

    if (scannedCode.contains(':')) {
      extractedCode = scannedCode.split(':')[0];
    }

    if (extractedCode != state.currentAttendanceCode) {
      emit(state.copyWith(isLoading: false, error: '❌ رمز QR غير صحيح.'));
      return;
    }

    final attendanceStatus = _calculateAttendanceStatus();

    await addAttendanceTeacher(attendanceStatus: attendanceStatus);
  }
  // =========================================================
  // تحديد حالة الحضور
  // =========================================================

  String _calculateAttendanceStatus() {
    final now = DateTime.now();

    if ((now.hour == allowedStartHour && now.minute > lateMinuteThreshold) ||
        now.hour > allowedStartHour) {
      return 'متأخر';
    }

    return 'حاضر';
  }
  // =========================================================
  // تسجيل الحضور
  // =========================================================

  Future<void> addAttendanceTeacher({required String attendanceStatus}) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));

    final attendance = TeacherAttendanceEntity(
      id: const Uuid().v4(),
      userId: '1',
      role: 'T',
      schoolId: state.schoolId,
      name: state.teacherName,
      status: attendanceStatus,
      date: DateTime.now(),
      timeOfArrival: '0',
      departureTime: '0',
    );

    final result = await addAttendanceTeacherUsecase(attendance);

    result.fold(
      (error) {
        emit(state.copyWith(isLoading: false, error: error));
      },
      (_) {
        emit(
          state.copyWith(
            isLoading: false,
            success: 'تم تسجيل حضورك بنجاح',
            attendanceDone: true,
            attendanceTStatus: attendanceStatus,
          ),
        );
      },
    );
  }

  // =========================================================
  // حفظ التحضير مؤقتًا
  // =========================================================

  // Future<void> savePendingAttendance({
  //   required String teacherName,
  //   required String attendanceStatus,
  // }) async {
  //   final int? teacherId = pref.getInt('user_id');

  //   final int? schoolId = pref.getInt('schoolId');

  //   final date = _today();

  //   // حفظ محلي
  //   await pref.setString('pending_attendance', teacherName);

  //   await pref.setString('pending_attendance_date', date);

  //   await pref.setString('pending_attendance_status', attendanceStatus);

  //   await pref.setInt('pending_teacher_id', teacherId ?? 0);

  //   await pref.setInt('pending_school_id', schoolId ?? 0);

  //   try {
  //     // محاولة الرفع مباشرة
  //     // await firestore
  //     //     .collection('attendance')
  //     //     .doc(date)
  //     //     .collection('teachers')
  //     //     .doc(teacherId?.toString() ?? teacherName)
  //     //     .set({
  //     //       'teacherId': teacherId,
  //     //       'schoolId': schoolId,
  //     //       'name': teacherName,
  //     //       'status': attendanceStatus,
  //     //       'timestamp': FieldValue.serverTimestamp(),
  //     //     });

  //     await _clearPendingAttendance();

  //     await pref.setString('last_attendance_date', date);

  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         success: scanningSuccess,
  //         attendanceDone: true,
  //         teacherName: teacherName,
  //         attendanceTStatus: attendanceStatus,
  //       ),
  //     );
  //   } catch (e) {
  //     _setError(
  //       'لا يوجد اتصال',
  //       '❌ تم حفظ حضورك مؤقتًا وسيتم رفعه تلقائيًا عند توفر الإنترنت.',
  //     );
  //   }
  // }

  // // =========================================================
  // // رفع التحضير المعلق
  // // =========================================================

  // Future<void> trySubmitPendingAttendance() async {
  //   try {
  //     final pendingTeacherName = pref.getString('pending_attendance');

  //     final pendingDate = pref.getString('pending_attendance_date');

  //     final pendingStatus = pref.getString('pending_attendance_status');

  //     final teacherId = pref.getInt('pending_teacher_id');

  //     final schoolId = pref.getInt('pending_school_id');

  //     if (pendingTeacherName == null || pendingDate == null) {
  //       return;
  //     }

  //     final today = _today();

  //     // إذا كان التحضير لليوم
  //     if (pendingDate == today) {
  //       // await firestore
  //       //     .collection('attendance')
  //       //     .doc(pendingDate)
  //       //     .collection('teachers')
  //       //     .doc(teacherId?.toString() ?? pendingTeacherName)
  //       //     .set({
  //       //       'teacherId': teacherId,
  //       //       'schoolId': schoolId,
  //       //       'name': pendingTeacherName,
  //       //       'status': pendingStatus ?? 'حاضر',
  //       //       'timestamp': FieldValue.serverTimestamp(),
  //       //     });

  //       await _clearPendingAttendance();

  //       await pref.setString('last_attendance_date', today);
  //     } else {
  //       // حذف التحضير القديم
  //       await _clearPendingAttendance();
  //     }
  //   } catch (e) {
  //     // لا نعرض خطأ للمستخدم هنا
  //     // سيتم المحاولة لاحقًا
  //   }
  // }

  // // =========================================================
  // // التحقق من تسجيل اليوم
  // // =========================================================

  // Future<void> checkIfAlreadyMarked() async {
  //   final today = _today();

  //   final lastMarkedDate = pref.getString('last_attendance_date');

  //   if (lastMarkedDate == today) {
  //     emit(state.copyWith(attendanceDone: true, success: scanningSuccess));
  //   }
  // }

  // // =========================================================
  // // حذف التحضير المعلق
  // // =========================================================

  // Future<void> _clearPendingAttendance() async {
  //   await pref.remove('pending_attendance');
  //   await pref.remove('pending_attendance_date');
  //   await pref.remove('pending_attendance_status');
  //   await pref.remove('pending_teacher_id');
  //   await pref.remove('pending_school_id');
  // }

  // // =========================================================
  // // إعادة تشغيل الماسح بعد Dialog
  // // =========================================================

  // void resetScanning() {
  //   emit(state.copyWith());
  // }

  // // =========================================================
  // // Error
  // // =========================================================

  void _setError(String title, String message) {
    emit(state.copyWith(isLoading: false, error: message));
  }

  void clearMessage() {
    emit(state.copyWith(success: null, error: null));
  }

  String _today() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
