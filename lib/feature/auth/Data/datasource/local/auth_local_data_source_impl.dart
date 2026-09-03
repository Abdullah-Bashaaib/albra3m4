import 'package:albra3m4/core/utils/perf_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Database database;

  static const String usersTable = 'users';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.database,
  });

  // ---------------------------------------------------------------------------
  // SharedPreferences
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheLoginSession({required String uid}) async {
    await sharedPreferences.setBool(PerfKeys.isLoggedInKey, true);

    await sharedPreferences.setString(PerfKeys.userIdKey, uid);
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(PerfKeys.isLoggedInKey) ?? false;
  }

  @override
  Future<String?> getCachedUserId() async {
    return sharedPreferences.getString(PerfKeys.userIdKey);
  }

  @override
  Future<void> clearLoginSession() async {
    await sharedPreferences.remove(PerfKeys.isLoggedInKey);

    await sharedPreferences.remove(PerfKeys.userIdKey);
  }

  // ---------------------------------------------------------------------------
  // SQLite
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheUser(UserModel user) async {
    await database.insert(
      usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final result = await database.query(usersTable, limit: 1);

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    await database.update(
      usersTable,
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  @override
  Future<void> deleteCachedUser() async {
    await database.delete(usersTable);
  }
}
