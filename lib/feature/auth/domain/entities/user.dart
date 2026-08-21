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
}

enum UserRole {
  superAdmin,
  manager,
  teacher,
  parent,
}