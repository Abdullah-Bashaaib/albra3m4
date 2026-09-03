class UserEntity {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum UserRole {
  superAdmin,
  manager,
  teacher,
  parent,
}
extension UserRoleArabicLabel on UserRole {
  String get arabicLabel =>
      switch (this) {
        UserRole.superAdmin => 'مشرف تقني',
        UserRole.manager => 'مدير',
        UserRole.teacher => 'معلمة',
        UserRole.parent => 'ولي أمر',
      };
}