import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

import '../repositories/authentication_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  const RegisterUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
    String fullName,
    UserRole role,
    String? phone,
  ) async {
    return await repository.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}
