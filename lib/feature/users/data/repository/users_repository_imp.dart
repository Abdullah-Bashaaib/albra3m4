import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/auth/Data/failures/firebase_failure.dart'
    hide NetworkFailure;
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/repo/users_reopsitory.dart';
import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../datasource/users_local_datasource.dart';
import '../datasource/users_remote_datasource.dart';

class UsersRepositoryImp implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;
  final UsersLocalDataSource _localDataSource;
  final InternetConnectionChecker _connectionChecker;

  UsersRepositoryImp(
    this._remoteDataSource,
    this._localDataSource,
    this._connectionChecker,
  );

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      if (await _connectionChecker.hasConnection) {
        final users = await _remoteDataSource.getAllUsers();

        return Right(users);
      }

      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      return Right(unit);
    } catch (e) {
      return Left(DeleteUserFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String id) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> changeUserRole(
    String uid,
    UserRole newRole,
  ) async {
    try {
      if (await _connectionChecker.hasConnection) {
        // 1. التعديل في Firebase
        await _remoteDataSource.updateUserRole(uid, newRole);

        // 2. التعديل في Sqflite محلياً
        await _localDataSource.updateUserRole(uid, newRole);

        return const Right(unit);
      }

      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
