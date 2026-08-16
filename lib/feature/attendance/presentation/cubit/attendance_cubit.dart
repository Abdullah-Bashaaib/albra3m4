import 'dart:math';

import 'package:albra3m4/core/messages.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final SharedPreferences pref;

  AttendanceCubit({required this.pref}) : super(AttendanceState());

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

    try {
      // بيانات افتراضية مؤقتة
      const schoolId = '1';
      const schoolName = 'روضة البراعم';

      final code = _generateRandomCode();
      final now = DateTime.now().toIso8601String();

      emit(
        state.copyWith(
          isLoading: false,
          schoolId: schoolId,
          schoolName: schoolName,
          attendanceCode: code,
          lastUpdated: now,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل كود الحضور',
        ),
      );
    }
  }

  // حفظ كود جديد
  Future<void> saveAttendanceCode(String code) async {
    if (code.trim().isEmpty) {
      emit(state.copyWith(error: 'يرجى إدخال كود الحضور'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // مؤقتًا لا يوجد Backend
      // لاحقًا هنا سيكون استدعاء الـ API

      final now = DateTime.now().toIso8601String();

      emit(
        state.copyWith(
          isLoading: false,
          success: addSuccess,
          attendanceCode: code.trim(),
          lastUpdated: now,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: 'حدث خطأ أثناء حفظ كود الحضور'),
      );
    }
  }

  // إنشاء كود عشوائي
  String generateNewCode() {
    final newCode = _generateRandomCode();

    emit(
      state.copyWith(
        attendanceCode: newCode,
        lastUpdated: DateTime.now().toIso8601String(),
      ),
    );

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

  void clearError() {
    emit(state.copyWith(error: null));
  }

  // وقت بداية التحضير
  final int allowedStartHour = 18;

  // وقت نهاية التحضير
  final int allowedEndHour = 18;

  // بعد كم دقيقة يصبح المعلم متأخرًا
  final int lateMinuteThreshold = 30;

  // =========================================================
  // تحميل الصفحة
  // =========================================================

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, error: null));

    await _fetchCurrentAttendanceCode();
    await trySubmitPendingAttendance();
    await checkIfAlreadyMarked();

    emit(state.copyWith(isLoading: false));
  }

  // =========================================================
  // جلب كود الحضور
  // =========================================================

  Future<void> _fetchCurrentAttendanceCode() async {
    try {
      final int? schoolId = pref.getInt('schoolId');

      if (schoolId == null) {
        _setError('خطأ', 'لم يتم العثور على معرف المدرسة.');
        return;
      }

      // final snapshot = await firestore
      //     .collection('attendanceCodes')
      //     .doc(schoolId.toString())
      //     .get();

      // if (snapshot.exists) {
      //   final code = snapshot['code'];

      //   emit(state.copyWith(currentAttendanceCode: code));
      // } else {
      //   _setError('خطأ', '⚠️ لم يتم العثور على كود الحضور.');
      // }
    } catch (e) {
      _setError('خطأ', '❌ حدث خطأ أثناء جلب كود الحضور: $e');
    }
  }

  // =========================================================
  // معالجة QR
  // =========================================================

  Future<void> handleScan(String scannedCode) async {
    // if (state.status != AttendanceScannerStatus.scanning) {
    //   return;
    // }

    if (scannedCode.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    // ---------------------------------------------------------
    // التحقق من الوقت
    // ---------------------------------------------------------

    final now = DateTime.now();

    if (now.hour < allowedStartHour || now.hour > allowedEndHour) {
      _setError(
        'خارج الوقت المسموح',
        'يمكنك تسجيل الحضور من الساعة '
            '$allowedStartHour إلى الساعة $allowedEndHour',
      );

      return;
    }

    // ---------------------------------------------------------
    // استخراج الكود
    // ---------------------------------------------------------

    String extractedCode = scannedCode;

    if (scannedCode.contains(':')) {
      extractedCode = scannedCode.split(':')[0];
    }

    // ---------------------------------------------------------
    // التأكد من وجود الكود
    // ---------------------------------------------------------

    final currentCode = state.currentAttendanceCode;

    if (currentCode == null) {
      _setError('خطأ', '⚠️ كود الحضور غير متوفر حاليًا. حاول لاحقًا.');

      return;
    }

    // ---------------------------------------------------------
    // مقارنة الكود
    // ---------------------------------------------------------

    if (extractedCode != currentCode) {
      _setError('رمز غير صحيح', '❌ الرجاء التأكد من أنك تمسح الرمز الصحيح.');

      return;
    }

    // ---------------------------------------------------------
    // جلب بيانات المعلم
    // ---------------------------------------------------------

    final String? teacherName = pref.getString('user_name');

    if (teacherName == null || teacherName.isEmpty) {
      _setError('خطأ', 'لم يتم العثور على بيانات المعلم.');

      return;
    }

    // ---------------------------------------------------------
    // التحقق من أنه سجل اليوم
    // ---------------------------------------------------------

    final today = _today();

    final lastDate = pref.getString('last_attendance_date');

    if (lastDate == today) {
      _setError(
        'تم تسجيل الحضور مسبقًا',
        'لقد قمت بتسجيل حضورك بالفعل اليوم! 👍',
      );

      return;
    }

    // ---------------------------------------------------------
    // تحديد حالة الحضور
    // ---------------------------------------------------------

    final attendanceStatus = _calculateAttendanceStatus();

    emit(state.copyWith(attendanceTStatus: attendanceStatus));

    // ---------------------------------------------------------
    // تسجيل الحضور
    // ---------------------------------------------------------

    await markAttendance(
      teacherName: teacherName,
      attendanceStatus: attendanceStatus,
    );
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

  Future<void> markAttendance({
    required String teacherName,
    required String attendanceStatus,
  }) async {
    try {
      final int? teacherId = pref.getInt('user_id');

      final int? schoolId = pref.getInt('schoolId');

      final date = _today();

      // -------------------------------------------------------
      // التحقق من وجود تسجيل سابق
      // -------------------------------------------------------

      // final snapshot = await firestore
      //     .collection('attendance')
      //     .doc(date)
      //     .collection('teachers')
      //     .where('teacherId', isEqualTo: teacherId)
      //     .get();

      // -------------------------------------------------------
      // إضافة التسجيل
      // -------------------------------------------------------

      // if (snapshot.docs.isEmpty) {
      //   await firestore
      //       .collection('attendance')
      //       .doc(date)
      //       .collection('teachers')
      //       .doc(teacherId?.toString() ?? teacherName)
      //       .set({
      //         'teacherId': teacherId,
      //         'schoolId': schoolId,
      //         'name': teacherName,
      //         'status': attendanceStatus,
      //         'timestamp': FieldValue.serverTimestamp(),
      //       });
      // }

      // -------------------------------------------------------
      // حفظ تاريخ آخر حضور
      // -------------------------------------------------------

      await pref.setString('last_attendance_date', date);

      emit(
        state.copyWith(
          isLoading: false,
          success: scanningSuccess,
          attendanceDone: true,
          teacherName: teacherName,
          attendanceTStatus: attendanceStatus,
        ),
      );
    } catch (e) {
      // إذا لم يوجد اتصال
      await savePendingAttendance(
        teacherName: teacherName,
        attendanceStatus: attendanceStatus,
      );
    }
  }

  // =========================================================
  // حفظ التحضير مؤقتًا
  // =========================================================

  Future<void> savePendingAttendance({
    required String teacherName,
    required String attendanceStatus,
  }) async {
    final int? teacherId = pref.getInt('user_id');

    final int? schoolId = pref.getInt('schoolId');

    final date = _today();

    // حفظ محلي
    await pref.setString('pending_attendance', teacherName);

    await pref.setString('pending_attendance_date', date);

    await pref.setString('pending_attendance_status', attendanceStatus);

    await pref.setInt('pending_teacher_id', teacherId ?? 0);

    await pref.setInt('pending_school_id', schoolId ?? 0);

    try {
      // محاولة الرفع مباشرة
      // await firestore
      //     .collection('attendance')
      //     .doc(date)
      //     .collection('teachers')
      //     .doc(teacherId?.toString() ?? teacherName)
      //     .set({
      //       'teacherId': teacherId,
      //       'schoolId': schoolId,
      //       'name': teacherName,
      //       'status': attendanceStatus,
      //       'timestamp': FieldValue.serverTimestamp(),
      //     });

      await _clearPendingAttendance();

      await pref.setString('last_attendance_date', date);

      emit(
        state.copyWith(
          isLoading: false,
          success: scanningSuccess,
          attendanceDone: true,
          teacherName: teacherName,
          attendanceTStatus: attendanceStatus,
        ),
      );
    } catch (e) {
      _setError(
        'لا يوجد اتصال',
        '❌ تم حفظ حضورك مؤقتًا وسيتم رفعه تلقائيًا عند توفر الإنترنت.',
      );
    }
  }

  // =========================================================
  // رفع التحضير المعلق
  // =========================================================

  Future<void> trySubmitPendingAttendance() async {
    try {
      final pendingTeacherName = pref.getString('pending_attendance');

      final pendingDate = pref.getString('pending_attendance_date');

      final pendingStatus = pref.getString('pending_attendance_status');

      final teacherId = pref.getInt('pending_teacher_id');

      final schoolId = pref.getInt('pending_school_id');

      if (pendingTeacherName == null || pendingDate == null) {
        return;
      }

      final today = _today();

      // إذا كان التحضير لليوم
      if (pendingDate == today) {
        // await firestore
        //     .collection('attendance')
        //     .doc(pendingDate)
        //     .collection('teachers')
        //     .doc(teacherId?.toString() ?? pendingTeacherName)
        //     .set({
        //       'teacherId': teacherId,
        //       'schoolId': schoolId,
        //       'name': pendingTeacherName,
        //       'status': pendingStatus ?? 'حاضر',
        //       'timestamp': FieldValue.serverTimestamp(),
        //     });

        await _clearPendingAttendance();

        await pref.setString('last_attendance_date', today);
      } else {
        // حذف التحضير القديم
        await _clearPendingAttendance();
      }
    } catch (e) {
      // لا نعرض خطأ للمستخدم هنا
      // سيتم المحاولة لاحقًا
    }
  }

  // =========================================================
  // التحقق من تسجيل اليوم
  // =========================================================

  Future<void> checkIfAlreadyMarked() async {
    final today = _today();

    final lastMarkedDate = pref.getString('last_attendance_date');

    if (lastMarkedDate == today) {
      emit(state.copyWith(attendanceDone: true, success: scanningSuccess));
    }
  }

  // =========================================================
  // حذف التحضير المعلق
  // =========================================================

  Future<void> _clearPendingAttendance() async {
    await pref.remove('pending_attendance');
    await pref.remove('pending_attendance_date');
    await pref.remove('pending_attendance_status');
    await pref.remove('pending_teacher_id');
    await pref.remove('pending_school_id');
  }

  // =========================================================
  // إعادة تشغيل الماسح بعد Dialog
  // =========================================================

  void resetScanning() {
    emit(state.copyWith());
  }

  // =========================================================
  // Error
  // =========================================================

  void _setError(String title, String message) {
    emit(state.copyWith(isLoading: false, error: message));
  }

  // void clearError() {
  //   emit(
  //     state.copyWith(
  //       status: AttendanceScannerStatus.scanning,
  //       clearError: true,
  //     ),
  //   );
  // }

  String _today() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
