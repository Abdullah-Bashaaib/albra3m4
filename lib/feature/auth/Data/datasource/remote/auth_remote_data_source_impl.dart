import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/user.dart';
import '../../mappers/firebase_exception_mapper.dart';
import '../../models/user_model.dart';
import 'authentication_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'registration-failed',
          message: 'تعذر الحصول على بيانات المستخدم.',
        );
      }

      await firebaseUser.reload(); //

      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'تعذر الحصول على بيانات المستخدم.',
        );
      }

      if (!currentUser.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'يجب تأكيد البريد الإلكتروني أولاً.',
        );
      }

      final userModel = await getUserFromFirestore(uid: currentUser.uid);

      if (!userModel.isActive) {
        throw FirebaseAuthException(
          code: 'account-inactive',
          message: 'حسابك غير نشط حاليًا.',
        );
      }

      return userModel.copyWith(isVerified: currentUser.emailVerified);
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'registration-failed',
          message: 'فشل إنشاء الحساب.',
        );
      }

      await firebaseUser.updateDisplayName(fullName.trim());

      final userModel = UserModel(
        uid: firebaseUser.uid,
        fullName: fullName.trim(),
        email: firebaseUser.email ?? email,
        phone: phone,
        role: UserRole.parent,
        isVerified: firebaseUser.emailVerified,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await createUserInFirestore(user: userModel);

      await firebaseUser.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'لا يوجد مستخدم مسجل الدخول.',
        );
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return null;
      }

      await user.reload();

      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return null;
      }

      if (!currentUser.emailVerified) {
        return null;
      }

      final userModel = await getUserFromFirestore(uid: currentUser.uid);

      if (!userModel.isActive) {
        return null;
      }

      return userModel.copyWith(isVerified: currentUser.emailVerified);
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<UserModel> getUserFromFirestore({required String uid}) async {
    try {
      final document = await firestore.collection('users').doc(uid).get();

      if (!document.exists || document.data() == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'بيانات المستخدم غير موجودة.',
        );
      }

      return UserModel.fromFirestore(document.data()!);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<void> createUserInFirestore({required UserModel user}) async {
    try {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.name,
        'isVerified': user.isVerified,
        'isActive': user.isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<void> updateUserInFirestore({required UserModel user}) async {
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = firebaseAuth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      return firebaseAuth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }
}
