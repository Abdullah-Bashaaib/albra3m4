import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.fullName,
    super.schoolId,
    required super.email,
    super.phone,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.createdAt,
    super.tDetails,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      fullName: entity.fullName,
      schoolId: entity.schoolId,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'full_name': fullName,
      'school_id': schoolId,
      'email': email,
      'phone': phone,
      'role': role.name,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      fullName: map['full_name'] as String? ?? '',
      schoolId: map['school_id'],
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.parent,
      ),
      isVerified: map['is_verified'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _parseFirestoreDate(map['created_at']),
    );
  }

  // ---------------------------------------------------------------------------
  // SQLite
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'full_name': fullName,
      'school_id': schoolId,
      'email': email,
      'phone': phone,
      'role': role.name,
      'is_verified': isVerified ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      fullName: map['full_name'] as String? ?? '',
      schoolId: map['school_id'],
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.parent,
      ),
      isVerified: map['is_verified'] == 1,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? schoolId,
    String? email,
    String? phone,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      schoolId: schoolId ?? this.schoolId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _parseFirestoreDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, phone: $phone, role: $role, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt)';
  }
}
