import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

import '../repo/users_reopsitory.dart';

class UpdateUserUseCase {
  final UsersRepository _repository;

  const UpdateUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(UserEntity user) async {
    return await _repository.updateUser(user);
  }
}
