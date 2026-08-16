import 'package:albra3m4/feature/attendance/data/models/teacher_attendance_model.dart';

class TeacherAttendanceEntity {
  final String id;
  final String userId;
  final String role;
  final String name;
  final String timeOfArrival;
  final String departureTime;
  final DateTime date;

  TeacherAttendanceEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.name,
    required this.timeOfArrival,
    required this.departureTime,
    required this.date,
  });

  TeacherAttendanceEntity copyWith({
    String? id,
    String? userId,
    String? role,
    String? name,
    String? timeOfArrival,
    String? departureTime,
    DateTime? date,
  }) {
    return TeacherAttendanceEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      name: name ?? this.name,
      timeOfArrival: timeOfArrival ?? this.timeOfArrival,
      departureTime: departureTime ?? this.departureTime,
      date: date ?? this.date,
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
    );
  }
}
