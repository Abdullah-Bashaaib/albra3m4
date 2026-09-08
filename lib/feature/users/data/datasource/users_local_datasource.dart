import 'package:albra3m4/core/database/database_helper.dart';
import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';

abstract class UsersLocalDataSource {
  Future<void> updateUserRole(String uid, UserRole role);

  Future<void> updateUserStatus(String uid, bool isActive);

  Future<void> updateUser(UserModel user);

  Future<void> deleteUser(String uid);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final DatabaseHelper databaseHelper;

  UsersLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'users',
        {'role': role.name},
        where: 'uid = ?',
        whereArgs: [uid],
      );
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'users',
        {'is_active': isActive ? 1 : 0},
        where: 'uid = ?',
        whereArgs: [uid],
      );
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        'users',
        {
          'full_name': user.fullName,
          'phone': user.phone,
          'role': user.role.name,
        },
        where: 'uid = ?',
        whereArgs: [user.uid],
      );
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        // حذف المعلم أولاً إن وجد ارتباط لتجنب خطأ المفتاح الأجنبي
        await txn.delete('teachers', where: 'user_id = ?', whereArgs: [uid]);
        // حذف المستخدم
        await txn.delete('users', where: 'uid = ?', whereArgs: [uid]);
      });
    } catch (e) {
      throw LocalException(e.toString());
    }
  }
}
