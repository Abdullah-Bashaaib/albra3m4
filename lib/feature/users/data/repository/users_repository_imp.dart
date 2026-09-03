import 'dart:developer';

import 'package:albra3m4/core/errors/failure.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/domain/repo/users_reopsitory.dart';
import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../datasource/users_remote_datasource.dart';

class UsersRepositoryImp implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;
  final InternetConnectionChecker _connectionChecker;

  UsersRepositoryImp(this._remoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    log(
      '--------------------- [message] start getAllUsers in Repository Implement [message]---------------------',
    );
    try {
      if (await _connectionChecker.hasConnection) {
        log(
          '--------------------- [message] has internet connection [message]---------------------',
        );
        final users = await _remoteDataSource.getAllUsers();
        log(
          '--------------------- [message] users is $users [message]---------------------',
        );
        return Right(users);
      }
      log(
        '--------------------- [message] no internet connection [message]---------------------',
      );
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      log(
        '--------------------- [message] error is $e [message]---------------------',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String id) {
    // TODO: implement deleteUser
    throw UnimplementedError();
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
}
