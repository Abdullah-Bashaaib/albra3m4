import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final user = UserModel(
    uid: 'test-uid',
    fullName: 'معلمة',
    email: 'teacher@example.org',
    role: UserRole.teacher,
    isVerified: true,
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
    permissions: const [
      AppPermission.manageMedia,
      AppPermission.manageActivities,
    ],
  );

  test('Firestore stores a real array and keeps the teacher role', () {
    final encoded = user.toFirestore();
    expect(encoded['permissions'], ['manageMedia', 'manageActivities']);
    final roundTrip = UserModel.fromFirestore(encoded);
    expect(roundTrip.role, UserRole.teacher);
    expect(roundTrip.permissions, user.permissions);
  });

  test('SQLite uses JSON and retains permissions', () {
    final row = user.toMap();
    expect(row['permissions'], '["manageMedia","manageActivities"]');
    final cached = UserModel.fromMap(row);
    expect(cached.permissions, user.permissions);
    expect(cached.copyWith(fullName: 'Updated').permissions, user.permissions);
  });

  test('old Firestore records have no assignments by default', () {
    final old = user.toFirestore()..remove('permissions');
    expect(UserModel.fromFirestore(old).permissions, isEmpty);
  });

  test('old SQLite records have no assignments by default', () {
    final old = user.toMap()..remove('permissions');
    expect(UserModel.fromMap(old).permissions, isEmpty);
  });
}
