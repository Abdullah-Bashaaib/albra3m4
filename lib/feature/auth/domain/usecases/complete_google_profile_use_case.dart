import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

/// UseCase لإكمال بيانات المستخدم الناقصة بعد أول تسجيل دخول عبر Google:
/// اختيار الدور الحقيقي (Teacher/Parent) وإدخال رقم الهاتف الإلزامي.
class CompleteGoogleProfileUseCase {
  final AuthRepository repository;

  const CompleteGoogleProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required UserEntity currentUser,
    required UserRole role,
    required String phone,
  }) {
    return repository.completeGoogleProfile(
      currentUser: currentUser,
      role: role,
      phone: phone,
    );
  }
}