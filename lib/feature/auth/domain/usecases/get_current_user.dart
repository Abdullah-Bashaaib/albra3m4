import 'dart:developer';

import 'package:albra3m4/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    log('message:----------------Start Call at UseCase');
    return await _repository.getCurrentUser();
  }
}
