import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheLoginSession({required String uid});

  Future<bool> isLoggedIn();

  Future<String?> getCachedUserId();

  Future<void> clearLoginSession();

  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> updateCachedUser(UserModel user);

  Future<void> deleteCachedUser();
}
