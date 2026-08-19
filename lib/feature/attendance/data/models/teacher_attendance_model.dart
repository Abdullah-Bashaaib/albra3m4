import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';

class TeacherAttendanceModel extends TeacherAttendanceEntity {
  TeacherAttendanceModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.name,
    required super.timeOfArrival,
    required super.departureTime,
    required super.date,
    required super.schoolId,
    required super.status,
  });

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      role: json['role'],
      name: json['name'],
      timeOfArrival: json['time_of_arrival'],
      departureTime: json['departure_time'],
      date: DateTime.parse(json['date']),
      schoolId: json['school_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'name': name,
      'time_of_arrival': timeOfArrival,
      'departure_time': departureTime,
      'date': date.toIso8601String(),
      'school_id': schoolId,
      'status': status,
    };
  }

  factory TeacherAttendanceModel.fromEntity(TeacherAttendanceEntity t) {
    return TeacherAttendanceModel(
      id: t.id,
      userId: t.userId,
      role: t.role,
      name: t.name,
      timeOfArrival: t.timeOfArrival,
      departureTime: t.departureTime,
      date: t.date,
      schoolId: t.schoolId,
      status: t.status,
    );
  }
}
