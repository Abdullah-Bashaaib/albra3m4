import 'package:albra3m4/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../repo/users_reopsitory.dart';

class ToggleUserStatusUseCase {
  final UsersRepository _repository;

  const ToggleUserStatusUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String uid, bool isActive) async {
    return await _repository.toggleUserStatus(uid, isActive);
  }
}
