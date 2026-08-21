import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Database database;

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';

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
    await sharedPreferences.setBool(_isLoggedInKey, true);

    await sharedPreferences.setString(_userIdKey, uid);
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(_isLoggedInKey) ?? false;
  }

  @override
  Future<String?> getCachedUserId() async {
    return sharedPreferences.getString(_userIdKey);
  }

  @override
  Future<void> clearLoginSession() async {
    await sharedPreferences.remove(_isLoggedInKey);

    await sharedPreferences.remove(_userIdKey);
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
