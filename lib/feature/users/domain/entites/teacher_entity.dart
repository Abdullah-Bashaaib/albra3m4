import 'package:albra3m4/feature/auth/domain/entities/user.dart';

class TeacherEntity extends UserEntity {
  TeacherEntity({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.createdAt,
  });
}
