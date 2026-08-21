import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';

class TeacherAttendanceEntity {
  final String id;
  final String userId;
  final String schoolId;
  final String role;
  final String name;
  final String timeOfArrival;
  final String departureTime;
  final String status;
  final DateTime date;

  TeacherAttendanceEntity({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.role,
    required this.name,
    required this.timeOfArrival,
    required this.departureTime,
    required this.status,
    required this.date,
  });

  TeacherAttendanceEntity copyWith({
    String? id,
    String? userId,
    String? schoolId,
    String? role,
    String? name,
    String? timeOfArrival,
    String? departureTime,
    String? status,
    DateTime? date,
  }) {
    return TeacherAttendanceEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      schoolId: schoolId ?? this.schoolId,
      role: role ?? this.role,
      name: name ?? this.name,
      timeOfArrival: timeOfArrival ?? this.timeOfArrival,
      departureTime: departureTime ?? this.departureTime,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  factory TeacherAttendanceEntity.fromModel(TeacherAttendanceModel t) {
    return TeacherAttendanceEntity(
      id: t.id,
      userId: t.userId,
      role: t.role,
      name: t.name,
      timeOfArrival: t.timeOfArrival,
      departureTime: t.departureTime,
      date: t.date,
      schoolId: t.schoolId, status: t.status,
    );
  }
}
