import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

/// UseCase لتسجيل الدخول عبر Google.
/// لا يحتاج معاملات (Params) — كل بيانات الحساب تأتي من Google مباشرة.
class GoogleLoginUseCase {
  final AuthRepository repository;

  const GoogleLoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.loginWithGoogle();
  }
}
