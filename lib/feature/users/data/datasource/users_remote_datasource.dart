import 'dart:developer';

import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide FirebaseException;

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getAllUsers();

  Future<UserModel> getUserById(String id);

  Future<UserModel> createUser(UserModel user);

  Future<UserModel> updateUser(UserModel user);

  Future<void> deleteUser(String id);

  Future<void> updateUserRole(String uid, UserRole role);

  Future<void> updateUserStatus(String uid, bool isActive);

  Future<UserModel> updateTeacherPermissions(String uid, List<AppPermission> permissions);
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
  Future<void> deleteUser(String id) async {
    try {
      await _usersCollection.doc(id).delete();
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String id) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update({
        'full_name': user.fullName,
        'phone': user.phone,
        'role': user.role.name,
      });
      return user;
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }

  @override
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersCollection.doc(uid).update({'role': role.name});
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }

  @override
  Future<UserModel> updateTeacherPermissions(
    String uid,
    List<AppPermission> permissions,
  ) async {
    final actorUid = FirebaseAuth.instance.currentUser?.uid;
    if (actorUid == null) {
      throw StateError('يجب تسجيل الدخول لتعديل الصلاحيات.');
    }

    // Never trust a cached role for authorization. Server rules are mandatory.
    final firestore = FirebaseFirestore.instance;
    return firestore.runTransaction<UserModel>((transaction) async {
      final actorSnapshot = await transaction.get(_usersCollection.doc(actorUid));
      final targetSnapshot = await transaction.get(_usersCollection.doc(uid));

      if (!actorSnapshot.exists || !targetSnapshot.exists) {
        throw StateError('تعذر العثور على حساب المعلمة أو المسؤول.');
      }
      final actor = UserModel.fromFirestore(actorSnapshot.data()!);
      final target = UserModel.fromFirestore(targetSnapshot.data()!);
      if (!actor.isActive ||
          (actor.role != UserRole.superAdmin && actor.role != UserRole.manager)) {
        throw StateError('ليس لديك صلاحية تكليف المعلمات.');
      }
      if (target.role != UserRole.teacher) {
        throw StateError('يمكن منح التكليفات الإدارية للمعلمات فقط.');
      }
      if (actor.role == UserRole.manager &&
          (actor.schoolId == null ||
              actor.schoolId!.isEmpty ||
              actor.schoolId != target.schoolId)) {
        throw StateError('يمكن للمديرة إدارة معلمات روضتها فقط.');
      }

      final distinct = permissions.toSet().toList();
      transaction.update(_usersCollection.doc(uid), {
        'permissions': distinct.map((permission) => permission.name).toList(),
      });
      return UserModel.fromEntity(target.copyWith(permissions: distinct));
    });
  }

  @override
  Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      await _usersCollection.doc(uid).update({'is_active': isActive});
    } catch (e) {
      throw FirebaseException(e.toString());
    }
  }
}
