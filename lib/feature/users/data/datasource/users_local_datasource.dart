import 'package:albra3m4/core/database/database_helper.dart';
import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';

abstract class UsersLocalDataSource {
  Future<void> updateUserRole(String uid, UserRole role);
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
}
