import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

import '../repo/users_reopsitory.dart';

class ChangeUserRoleUseCase {
  final UsersRepository _usersRepository;

  const ChangeUserRoleUseCase(this._usersRepository);

  Future<Either<Failure, Unit>> call(String uid, UserRole newRole) async {
    return await _usersRepository.changeUserRole(uid, newRole);
  }
}
