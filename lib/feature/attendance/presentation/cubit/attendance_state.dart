part of 'attendance_cubit.dart';

class AttendanceState extends Equatable {
  final bool isLoading;
  final String? success;
  final String? error;
  final List<Map<String, dynamic>> students;
  final Map<String, bool> attendanceStatus;
  final Map<String, String> absenceReasons;
  final QREntity? attendanceQR;
  final String schoolId;
  final String schoolName;
  //تحضير المعلمات
  final bool attendanceDone;
  final bool departureDone;
  final String teacherName;
  final String? currentAttendanceCode;
  final String? attendanceTStatus;
  final bool isLoadingQ;
  // قائمة تحضير المعلمات (لواجهة المديرة)
  final List<TeacherAttendanceEntity> teacherAttendanceList;
  final bool isLoadingAttendanceList;

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
    this.attendanceQR,
    this.schoolId = '',
    this.schoolName = 'البراعم',
    this.attendanceDone = false,
    this.departureDone = false,
    this.teacherName = 'Abdullah',
    this.currentAttendanceCode,
    this.attendanceTStatus,
    this.isLoadingQ = false,
    this.teacherAttendanceList = const [],
    this.isLoadingAttendanceList = false,
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
    attendanceQR,
    attendanceDone,
    departureDone,
    teacherName,
    currentAttendanceCode,
    attendanceTStatus,
    isLoadingQ,
    teacherAttendanceList,
    isLoadingAttendanceList,
  ];

  AttendanceState copyWith({
    bool? isLoading,
    String? success,
    String? error,
    List<Map<String, dynamic>>? students,
    Map<String, bool>? attendanceStatus,
    Map<String, String>? absenceReasons,
    QREntity? attendanceQR,
    String? schoolId,
    String? schoolName,
    bool? attendanceDone,
    bool? departureDone,
    String? teacherName,
    String? currentAttendanceCode,
    String? attendanceTStatus,
    bool? isLoadingQ,
    List<TeacherAttendanceEntity>? teacherAttendanceList,
    bool? isLoadingAttendanceList,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      success: success,
      error: error,
      students: students ?? this.students,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      attendanceQR: attendanceQR ?? this.attendanceQR,
      absenceReasons: absenceReasons ?? this.absenceReasons,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      attendanceDone: attendanceDone ?? this.attendanceDone,
      departureDone: departureDone ?? this.departureDone,
      teacherName: teacherName ?? this.teacherName,
      currentAttendanceCode:
          currentAttendanceCode ?? this.currentAttendanceCode,
      attendanceTStatus: attendanceTStatus ?? this.attendanceTStatus,
      isLoadingQ: isLoadingQ ?? this.isLoadingQ,
      teacherAttendanceList:
          teacherAttendanceList ?? this.teacherAttendanceList,
      isLoadingAttendanceList:
          isLoadingAttendanceList ?? this.isLoadingAttendanceList,
    );
  }
}
