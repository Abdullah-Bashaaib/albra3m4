import 'package:albra3m4/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../repo/users_reopsitory.dart';

class DeleteUserUseCase {
  final UsersRepository _usersRepository;

  const DeleteUserUseCase(this._usersRepository);

  Future<Either<Failure, Unit>> call(String id) async =>
      await _usersRepository.deleteUser(id);
}
