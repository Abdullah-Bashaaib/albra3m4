import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/domain/entities/user.dart';
import 'package:albra3m4/feature/domain/repositories/authentication_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await _repository.getCurrentUser();
  }
}
