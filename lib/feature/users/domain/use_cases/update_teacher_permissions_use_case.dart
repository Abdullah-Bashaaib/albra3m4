import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import '../repo/users_reopsitory.dart';

class UpdateTeacherPermissionsUseCase {
  final UsersRepository _repository;
  const UpdateTeacherPermissionsUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(
    String uid, List<AppPermission> permissions,
  ) => _repository.updateTeacherPermissions(uid, permissions);
}
