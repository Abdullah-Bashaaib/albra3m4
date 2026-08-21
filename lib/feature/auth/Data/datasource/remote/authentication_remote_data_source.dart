import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  /// تسجيل الدخول عبر Google.
  /// يفتح Google Sign-In، يربط الحساب بـ Firebase Auth، وإذا كانت هذه
  /// أول مرة يسجّل بها المستخدم عبر Google يتم إنشاء وثيقة جديدة له
  /// في Firestore بدور افتراضي (parent) قابل للتعديل لاحقاً من الإدارة.
  Future<UserModel> loginWithGoogle();

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail({required String email});

  Future<UserModel?> getCurrentUser();

  Future<UserModel> getUserFromFirestore({required String uid});

  Future<void> createUserInFirestore({required UserModel user});

  Future<void> updateUserInFirestore({required UserModel user});

  Future<bool> isEmailVerified();

  Future<void> reloadUser();

  Future<void> logout();
}