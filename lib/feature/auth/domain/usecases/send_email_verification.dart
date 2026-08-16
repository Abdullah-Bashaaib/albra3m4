import 'package:albra3m4/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../repositories/authentication_repository.dart';

class SendEmailVerificationUseCase {
  final AuthRepository _repository;

  const SendEmailVerificationUseCase(this._repository);

  Future<Either<Failure, Unit>> call() async {
    return await _repository.sendEmailVerification();
  }
}
