import 'dart:developer';

import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide FirebaseException;

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getAllUsers();

  Future<UserModel> getUserById(String id);

  Future<UserModel> createUser(UserModel user);

  Future<UserModel> updateUser(UserModel user);

  Future<void> deleteUser(String id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  UsersRemoteDataSourceImpl();

  @override
  Future<List<UserModel>> getAllUsers() async {
    log(
      '------------------ [message] getAllUsers start at DataSource [message]----------------',
    );
    try {
      final querySnapshot = await _usersCollection.get();
      final List<UserModel> users = querySnapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.data());
      }).toList();
      log(
        '------------------ [message] users is $users [message]----------------',
      );
      return users;
    } catch (e) {
      log('------------------ [message] error is $e [message]----------------');
      throw FirebaseException(e);
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String id) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getUserById(String id) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateUser(UserModel user) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
