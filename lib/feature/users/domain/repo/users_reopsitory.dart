import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  Future<Either<Failure, UserEntity>> getUserById(String id);

  Future<Either<Failure, UserEntity>> createUser(UserEntity user);

  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  Future<Either<Failure, Unit>> deleteUser(String id);

  Future<Either<Failure, Unit>> changeUserRole(String uid, UserRole newRole);

  Future<Either<Failure, Unit>> toggleUserStatus(String uid, bool isActive);
}
