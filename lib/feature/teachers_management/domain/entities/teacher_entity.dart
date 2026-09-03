import 'package:albra3m4/feature/teachers_management/data/models/teacher_model.dart';

class TeacherEntity {
  final String id;
  final String userId;
  final String schoolId;
  final DateTime birthDate;
  final String birthPlace;
  final String academicQualification;
  final DateTime qualificationDate;
  final String specialization;
  final SocialStatus socialStatus;
  final int childrenCount;
  final String homePhone;
  final String mobilePhone;

  TeacherEntity({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.birthDate,
    required this.birthPlace,
    required this.academicQualification,
    required this.qualificationDate,
    required this.specialization,
    required this.socialStatus,
    required this.childrenCount,
    required this.homePhone,
    required this.mobilePhone,
  });

  TeacherEntity copyWith({
    String? id,
    String? userId,
    String? schoolId,
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
      schoolId: schoolId ?? this.schoolId,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      academicQualification:
          academicQualification ?? this.academicQualification,
      qualificationDate: qualificationDate ?? this.qualificationDate,
      specialization: specialization ?? this.specialization,
      socialStatus: socialStatus ?? this.socialStatus,
      childrenCount: childrenCount ?? this.childrenCount,
      homePhone: homePhone ?? this.homePhone,
      mobilePhone: mobilePhone ?? this.mobilePhone,
    );
  }

  factory TeacherEntity.fromModel(TeacherModel t) {
    return TeacherEntity(
      id: t.id,
      userId: t.userId,
      schoolId: t.schoolId,
      birthDate: t.birthDate,
      birthPlace: t.birthPlace,
      academicQualification: t.academicQualification,
      qualificationDate: t.qualificationDate,
      specialization: t.specialization,
      socialStatus: t.socialStatus,
      childrenCount: t.childrenCount,
      homePhone: t.homePhone,
      mobilePhone: t.mobilePhone,
    );
  }
}

enum SocialStatus { single, married, divorced, widowed }
