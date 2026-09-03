import 'dart:developer';

import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/users/domain/repo/users_reopsitory.dart';
import 'package:dartz/dartz.dart';

import '../../../auth/domain/entities/user.dart';

class GetAllUsersUseCase {
  final UsersRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<Either<Failure, List<UserEntity>>> call() async {
    log(
      '------------------ [message]: GetAllUsersUseCase called [message]------------------',
    );
    return await _repository.getAllUsers();
  }
}
