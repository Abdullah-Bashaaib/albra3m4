import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'app_permission.dart';
import 'package:albra3m4/feature/teachers_management/domain/entities/teacher_entity.dart';

class UserEntity {
  final String uid;
  final String fullName;
  final String? schoolId;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final TeacherEntity? tDetails;
  final List<AppPermission> permissions;

  const UserEntity({
    required this.uid,
    required this.fullName,
    this.schoolId,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.tDetails,
    this.permissions = const [],
  });

  factory UserEntity.fromModel(UserModel m) {
    return UserEntity(
      uid: m.uid,
      fullName: m.fullName,
      schoolId: m.schoolId,
      email: m.email,
      phone: m.phone,
      role: m.role,
      isVerified: m.isVerified,
      isActive: m.isActive,
      createdAt: m.createdAt,
      tDetails: m.tDetails,
      permissions: m.permissions,
    );
  }

  /// Permissions are extra administrative duties, never a replacement for a role.
  bool hasPermission(AppPermission permission) {
    if (!isActive) return false;
    if (role == UserRole.superAdmin || role == UserRole.manager) return true;
    return role == UserRole.teacher && permissions.contains(permission);
  }

  UserEntity copyWith({
    String? uid,
    String? fullName,
    String? schoolId,
    String? email,
    String? phone,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    TeacherEntity? tDetails,
    List<AppPermission>? permissions,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      schoolId: schoolId ?? this.schoolId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      tDetails: tDetails ?? this.tDetails,
      permissions: permissions ?? this.permissions,
    );
  }
}

enum UserRole { superAdmin, manager, teacher, parent }

extension UserRoleArabicLabel on UserRole {
  String get arabicLabel => switch (this) {
    UserRole.superAdmin => 'مشرف',
    UserRole.manager => 'مدير',
    UserRole.teacher => 'معلمة',
    UserRole.parent => 'ولي أمر',
  };
}
