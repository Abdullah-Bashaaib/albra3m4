import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// تسجيل الدخول عبر Google.
  /// الجزء الثاني من الـ Record (`isNewUser`) يخبر الطبقات الأعلى إن كان
  /// يجب توجيه المستخدم لشاشة إكمال الملف الشخصي (اختيار الدور + الهاتف).
  Future<Either<Failure, ({UserEntity user, bool isNewUser})>>
  loginWithGoogle();

  /// يُستدعى بعد Google Sign-In الأول لإكمال البيانات الناقصة من UserModel:
  /// الدور الحقيقي (Teacher/Parent فقط) ورقم الهاتف الإلزامي.
  Future<Either<Failure, UserEntity>> completeGoogleProfile({
    required UserEntity currentUser,
    required UserRole role,
    required String phone,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });

  Future<Either<Failure, Unit>> sendEmailVerification();

  Future<Either<Failure, Unit>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> getCachedUser();

  Future<Either<Failure, Unit>> logout();
}