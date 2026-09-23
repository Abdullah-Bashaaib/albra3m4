import 'dart:convert';
import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.fullName,
    required super.gender,
    required super.birthDate,
    required super.classroom,
    required super.createdAt,
    super.guardianPhone,
    super.notes,
    super.grades,
  });

  factory StudentModel.fromEntity(StudentEntity entity) => StudentModel(
    id: entity.id,
    fullName: entity.fullName,
    gender: entity.gender,
    birthDate: entity.birthDate,
    classroom: entity.classroom,
    createdAt: entity.createdAt,
    guardianPhone: entity.guardianPhone,
    notes: entity.notes,
    grades: entity.grades,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'gender': gender.index,
    'birthDate': birthDate.toIso8601String(),
    'classroom': classroom.index,
    'guardianPhone': guardianPhone,
    'notes': notes,
    'grades': grades.map((g) => g.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    List<SubjectGrades> grades = [];
    if (json['grades'] != null) {
      grades = (json['grades'] as List)
          .map((e) => SubjectGrades.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return StudentModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      gender: StudentGender.values[json['gender'] as int],
      birthDate: DateTime.parse(json['birthDate'] as String),
      classroom: KindergartenClass.values[json['classroom'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      guardianPhone: json['guardianPhone'] as String?,
      notes: json['notes'] as String?,
      grades: grades,
    );
  }

  // ─── SQLite helpers ──────────────────────────────────────────────────────

  Map<String, dynamic> toDb() => {
    'id': id,
    'fullName': fullName,
    'gender': gender.index,
    'birthDate': birthDate.toIso8601String(),
    'classroom': classroom.index,
    'guardianPhone': guardianPhone,
    'notes': notes,
    'grades': jsonEncode(grades.map((g) => g.toJson()).toList()),
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudentModel.fromDb(Map<String, dynamic> row) {
    List<SubjectGrades> grades = [];
    if (row['grades'] != null && (row['grades'] as String).isNotEmpty) {
      final decoded = jsonDecode(row['grades'] as String) as List;
      grades = decoded
          .map((e) => SubjectGrades.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return StudentModel(
      id: row['id'] as String,
      fullName: row['fullName'] as String,
      gender: StudentGender.values[row['gender'] as int],
      birthDate: DateTime.parse(row['birthDate'] as String),
      classroom: KindergartenClass.values[row['classroom'] as int],
      createdAt: DateTime.parse(row['createdAt'] as String),
      guardianPhone: row['guardianPhone'] as String?,
      notes: row['notes'] as String?,
      grades: grades,
    );
  }
}
