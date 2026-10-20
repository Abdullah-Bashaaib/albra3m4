import 'package:albra3m4/feature/teachers_management/data/models/teacher_model.dart';

class TeacherEntity {
  final String id;
  final String userId;
  final DateTime birthDate;
  final String birthPlace;
  final String academicQualification;
  final DateTime qualificationDate;
  final String specialization;
  final SocialStatus socialStatus;
  final int childrenCount;
  final String homePhone;

  TeacherEntity({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.birthPlace,
    required this.academicQualification,
    required this.qualificationDate,
    required this.specialization,
    required this.socialStatus,
    required this.childrenCount,
    required this.homePhone,
  });

  TeacherEntity copyWith({
    String? id,
    String? userId,
    DateTime? birthDate,
    String? birthPlace,
    String? academicQualification,
    DateTime? qualificationDate,
    String? specialization,
    SocialStatus? socialStatus,
    int? childrenCount,
    String? homePhone,
    String? mobilePhone,
  }) {
    return TeacherEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      academicQualification:
          academicQualification ?? this.academicQualification,
      qualificationDate: qualificationDate ?? this.qualificationDate,
      specialization: specialization ?? this.specialization,
      socialStatus: socialStatus ?? this.socialStatus,
      childrenCount: childrenCount ?? this.childrenCount,
      homePhone: homePhone ?? this.homePhone,
    );
  }

  factory TeacherEntity.fromModel(TeacherModel t) {
    return TeacherEntity(
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

enum SocialStatus { single, married, divorced, widowed }
