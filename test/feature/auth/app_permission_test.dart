import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1);
  UserEntity user(UserRole role, {List<AppPermission> permissions = const [], bool active = true}) =>
      UserEntity(
        uid: 'uid', fullName: 'Teacher', email: 'teacher@example.org',
        role: role, isVerified: true, isActive: active, createdAt: createdAt,
        permissions: permissions,
      );

  test('new teacher has no internal permissions', () {
    expect(user(UserRole.teacher).permissions, isEmpty);
    expect(user(UserRole.teacher).hasPermission(AppPermission.manageFinance), false);
  });

  test('teachers can hold multiple independent assignments', () {
    final teacher = user(UserRole.teacher, permissions: [
      AppPermission.manageMedia, AppPermission.manageActivities,
    ]);
    expect(teacher.hasPermission(AppPermission.manageMedia), true);
    expect(teacher.hasPermission(AppPermission.manageActivities), true);
    expect(teacher.hasPermission(AppPermission.manageFinance), false);
    expect(teacher.copyWith(permissions: []).permissions, isEmpty);
  });

  test('administrators have functional access but disabled accounts do not', () {
    for (final role in [UserRole.manager, UserRole.superAdmin]) {
      expect(user(role).hasPermission(AppPermission.manageFinance), true);
      expect(user(role, active: false).hasPermission(AppPermission.manageFinance), false);
    }
    expect(user(UserRole.parent, permissions: [AppPermission.manageMedia])
        .hasPermission(AppPermission.manageMedia), false);
  });

  test('Firestore keys and local JSON round-trip, ignoring unknown values', () {
    final original = [AppPermission.manageFinance, AppPermission.manageTechnical];
    expect(AppPermissionCodec.fromList(['manageFinance', 'futureKey', 'manageFinance']),
        [AppPermission.manageFinance]);
    expect(AppPermissionCodec.fromJson(AppPermissionCodec.toJson(original)), original);
    expect(AppPermissionCodec.fromJson('{broken'), isEmpty);
    expect(AppPermissionCodec.fromList(null), isEmpty);
  });
}
