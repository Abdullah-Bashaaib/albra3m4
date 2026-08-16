import 'package:albra3m4/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email: email, password: password);
  }
}
