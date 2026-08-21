class StudentAttendanceEntity {
  final String id;
  final String studentId;
  final String role;
  final String name;
  final String timeOfArrival;
  final String departureTime;
  final DateTime date;

  StudentAttendanceEntity({
    required this.id,
    required this.studentId,
    required this.role,
    required this.name,
    required this.timeOfArrival,
    required this.departureTime,
    required this.date,
  });

  StudentAttendanceEntity copyWith({
    String? id,
    String? studentId,
    String? role,
    String? name,
    String? timeOfArrival,
    String? departureTime,
    DateTime? date,
  }) {
    return StudentAttendanceEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      name: name ?? this.name,
      timeOfArrival: timeOfArrival ?? this.timeOfArrival,
      departureTime: departureTime ?? this.departureTime,
      date: date ?? this.date,
    );
  }
}
