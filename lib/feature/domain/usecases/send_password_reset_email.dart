import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/domain/repositories/authentication_repository.dart';
import 'package:dartz/dartz.dart';

class SendPasswordResetEmail {
  final AuthRepository _repository;

  const SendPasswordResetEmail(this._repository);

  Future<Either<Failure, Unit>> call({required String email}) async {
    return await _repository.sendPasswordResetEmail(email: email);
  }
}
