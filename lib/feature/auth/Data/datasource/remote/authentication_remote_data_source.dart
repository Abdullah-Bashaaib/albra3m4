import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  /// يرجع Record يحتوي على:
  /// - `user`: بيانات المستخدم (موجودة مسبقاً أو أُنشئت للتو بدور افتراضي parent)
  /// - `isNewUser`: true إذا كانت هذه أول مرة يسجّل بها هذا الحساب — تُستخدم
  ///   في الطبقات الأعلى لتوجيهه لشاشة إكمال الملف الشخصي (اختيار الدور
  ///   الحقيقي + رقم الهاتف) بدل الذهاب مباشرة للـ Dashboard.
  Future<({UserModel user, bool isNewUser})> loginWithGoogle();

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