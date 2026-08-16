part of 'attendance_cubit.dart';

class AttendanceState extends Equatable {
  final bool isLoading;
  final String? success;
  final String? error;
  final List<Map<String, dynamic>> students;
  final Map<String, bool> attendanceStatus;
  final Map<String, String> absenceReasons;
  final String attendanceCode;
  final String schoolId;
  final String schoolName;
  final String lastUpdated;
  final bool attendanceDone;
  final String teacherName;
  final String? currentAttendanceCode;
  final String? attendanceTStatus;

  const AttendanceState({
    this.isLoading = false,
    this.success,
    this.error,
    this.students = const [
      {'id': '1', 'firstName': 'محمد', 'middleName': 'أحمد', 'lastName': 'علي'},
      {
        'id': '2',
        'firstName': 'عبدالله',
        'middleName': 'سعيد',
        'lastName': 'محمد',
      },
      {'id': '3', 'firstName': 'خالد', 'middleName': 'عمر', 'lastName': 'حسن'},
      {'id': '4', 'firstName': 'علي', 'middleName': 'محمد', 'lastName': 'صالح'},
      {
        'id': '5',
        'firstName': 'يوسف',
        'middleName': 'عبدالله',
        'lastName': 'أحمد',
      },
      {
        'id': '6',
        'firstName': 'إبراهيم',
        'middleName': 'علي',
        'lastName': 'حسن',
      },
      {
        'id': '7',
        'firstName': 'عبدالرحمن',
        'middleName': 'خالد',
        'lastName': 'صالح',
      },
      {'id': '8', 'firstName': 'سعيد', 'middleName': 'محمد', 'lastName': 'عمر'},
      {
        'id': '9',
        'firstName': 'حسن',
        'middleName': 'علي',
        'lastName': 'عبدالله',
      },
    ],
    this.attendanceStatus = const {},
    this.absenceReasons = const {},
    this.attendanceCode = '',
    this.schoolId = '',
    this.schoolName = '',
    this.lastUpdated = '',
    this.attendanceDone = false,
    this.teacherName = '',
    this.currentAttendanceCode,
    this.attendanceTStatus,
  });

  @override
  List<Object?> get props => [
    isLoading,
    success,
    error,
    attendanceStatus,
    absenceReasons,
    schoolId,
    schoolName,
    lastUpdated,
    attendanceCode,
    attendanceDone,
    teacherName,
    currentAttendanceCode,
    attendanceTStatus,
  ];

  AttendanceState copyWith({
    bool? isLoading,
    String? success,
    String? error,
    List<Map<String, dynamic>>? students,
    Map<String, bool>? attendanceStatus,
    Map<String, String>? absenceReasons,
    String? attendanceCode,
    String? schoolId,
    String? schoolName,
    String? lastUpdated,
    bool? attendanceDone,
    String? teacherName,
    String? currentAttendanceCode,
    String? attendanceTStatus,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      success: success,
      error: error,
      students: students ?? this.students,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      attendanceCode: attendanceCode ?? this.attendanceCode,
      absenceReasons: absenceReasons ?? this.absenceReasons,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      attendanceDone: attendanceDone ?? this.attendanceDone,
      teacherName: teacherName ?? this.teacherName,
      currentAttendanceCode:
          currentAttendanceCode ?? this.currentAttendanceCode,
      attendanceTStatus: attendanceTStatus ?? this.attendanceTStatus,
    );
  }
}
