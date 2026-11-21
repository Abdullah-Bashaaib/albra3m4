import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

UserEntity makeUser({
  UserRole role = UserRole.teacher,
  bool isActive = true,
  List<AppPermission> permissions = const [],
}) => UserEntity(
  uid: 'test-user',
  fullName: 'Test',
  email: 'test@example.com',
  role: role,
  isVerified: true,
  isActive: isActive,
  createdAt: DateTime(2026),
  permissions: permissions,
);

void main() {
  group('Teacher internal permissions', () {
    test('new teachers have no internal permissions', () {
      final teacher = makeUser();
      for (final permission in AppPermission.values) {
        expect(teacher.hasPermission(permission), isFalse);
      }
    });

    test('only explicitly assigned permissions are granted', () {
      final teacher = makeUser(permissions: [
        AppPermission.manageMedia,
        AppPermission.manageActivities,
      ]);
      expect(teacher.hasPermission(AppPermission.manageMedia), isTrue);
      expect(teacher.hasPermission(AppPermission.manageActivities), isTrue);
      expect(teacher.hasPermission(AppPermission.manageFinance), isFalse);
      expect(teacher.hasPermission(AppPermission.manageTechnical), isFalse);
    });

    test('inactive users cannot exercise permissions', () {
      for (final role in UserRole.values) {
        final user = makeUser(
          role: role,
          isActive: false,
          permissions: AppPermission.values,
        );
        for (final permission in AppPermission.values) {
          expect(user.hasPermission(permission), isFalse);
        }
      }
    });

    test('parents never gain internal permissions from stored values', () {
      final parent = makeUser(
        role: UserRole.parent,
        permissions: AppPermission.values,
      );
      for (final permission in AppPermission.values) {
        expect(parent.hasPermission(permission), isFalse);
      }
    });

    test('managers and super admins can access internal departments', () {
      for (final role in [UserRole.manager, UserRole.superAdmin]) {
        final user = makeUser(role: role);
        for (final permission in AppPermission.values) {
          expect(user.hasPermission(permission), isTrue);
        }
      }
    });

    test('unknown permission keys are ignored and duplicates removed', () {
      final decoded = AppPermissionCodec.fromList([
        'manageMedia',
        'unknownPermission',
        'manageMedia',
        42,
      ]);
      expect(decoded, [AppPermission.manageMedia]);
    });

    test('malformed cached permissions are treated as empty', () {
      expect(AppPermissionCodec.fromJson('not-json'), isEmpty);
      expect(AppPermissionCodec.fromJson('{"permissions":[]}'), isEmpty);
    });
  });
}
