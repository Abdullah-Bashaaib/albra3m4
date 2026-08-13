import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });

  Future<Either<Failure, Unit>> sendEmailVerification();

  Future<Either<Failure, Unit>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> getCachedUser();

  Future<Either<Failure, Unit>> logout();
}
