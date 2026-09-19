import 'package:albra3m4/feature/teachers_management/domain/entities/teacher_entity.dart';

class TeacherModel extends TeacherEntity {
  TeacherModel({
    required super.id,
    required super.userId,
    required super.birthDate,
    required super.birthPlace,
    required super.academicQualification,
    required super.qualificationDate,
    required super.specialization,
    required super.socialStatus,
    required super.childrenCount,
    required super.homePhone,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      userId: json['user_id'],
      birthDate: DateTime.parse(json['birth_date']),
      birthPlace: json['birth_place'],
      academicQualification: json['academic_qualification'],
      qualificationDate: DateTime.parse(json['qualification_date']),
      specialization: json['specialization'],
      socialStatus: SocialStatus.values.firstWhere(
        (status) => status.name == json['social_status'],
        orElse: () => SocialStatus.single,
      ),
      childrenCount: json['children_count'],
      homePhone: json['home_phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'birth_date': birthDate.toIso8601String(),
      'birth_place': birthPlace,
      'academic_qualification': academicQualification,
      'qualification_date': qualificationDate.toIso8601String(),
      'specialization': specialization,
      'social_status': socialStatus.name,
      'children_count': childrenCount,
      'home_phone': homePhone,
    };
  }

  factory TeacherModel.fromEntity(TeacherEntity t) {
    return TeacherModel(
      id: t.id,
      userId: t.userId,
      birthDate: t.birthDate,
      birthPlace: t.birthPlace,
      academicQualification: t.academicQualification,
      qualificationDate: t.qualificationDate,
      specialization: t.specialization,
      socialStatus: t.socialStatus,
      childrenCount: t.childrenCount,
      homePhone: t.homePhone,
    );
  }
}
