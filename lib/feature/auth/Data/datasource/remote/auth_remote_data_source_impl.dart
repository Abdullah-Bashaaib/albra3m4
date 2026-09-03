import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/entities/user.dart';
import '../../mappers/firebase_exception_mapper.dart';
import '../../models/user_model.dart';
import 'authentication_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn();

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

      await firebaseUser.reload();

      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'تعذر الحصول على بيانات المستخدم.',
        );
      }

      // ⚠️ ملاحظة مهمة: لا نتحقق هنا من currentUser.emailVerified
      // (فلاج Firebase Auth الأصلي). التطبيق يستخدم نظام تحقق مخصص
      // عبر OTP/EmailJS (UC-002) يحدّث حقل isVerified في Firestore،
      // ومفيش علاقة بينه وبين نظام Firebase المدمج (اللي يحتاج
      // المستخدم يضغط لينك تحقق مُرسَل من Firebase نفسه). الاعتماد
      // على currentUser.emailVerified هنا كان يرجّع دايماً false
      // لأي مستخدم اتحقق عبر OTP بس، حتى لو حسابه فعلاً verified.
      final userModel = await getUserFromFirestore(uid: currentUser.uid);

      if (!userModel.isVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'يجب تأكيد البريد الإلكتروني أولاً.',
        );
      }

      if (!userModel.isActive) {
        throw FirebaseAuthException(
          code: 'account-inactive',
          message: 'حسابك غير نشط حاليًا.',
        );
      }

      // لا نستخدم .copyWith(isVerified: currentUser.emailVerified) هنا —
      // ده كان بيكتب فوق قيمة isVerified الصحيحة (من Firestore/OTP)
      // بقيمة Firebase الأصلي (غالباً false)، وده كان بيتخزّن محلياً
      // كمان عبر localDataSource.cacheUser ويبوّظ مسار الـ offline.
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    } on FirebaseException catch (e) {
      throw FirebaseExceptionMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<({UserModel user, bool isNewUser})> loginWithGoogle() async {
    log(
        '----------> message: START loginWithGoogle method at remote data source');
    try {
      // 1) فتح شاشة اختيار حساب Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // المستخدم ألغى العملية — ليست حالة خطأ من Firebase، نبنيها يدوياً
        log('message: user canceled login with google');
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'تم إلغاء تسجيل الدخول عبر Google.',
        );
      }

      // 2) الحصول على tokens المصادقة من Google
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3) تسجيل الدخول إلى Firebase بواسطة الـ credential
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      log('message: firebaseUser is ${firebaseUser.toString()}');
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'تعذر تسجيل الدخول عبر Google.',
        );
      }

      // 4) هل المستخدم موجود مسبقاً في Firestore؟
      final document = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final bool isNewUser = !document.exists || document.data() == null;

      UserModel userModel;

      if (!isNewUser) {
        // مستخدم حالي — نجلب بياناته كما هي
        userModel = UserModel.fromFirestore(document.data()!);

        if (!userModel.isActive) {
          throw FirebaseAuthException(
            code: 'account-inactive',
            message: 'حسابك غير نشط حاليًا.',
          );
        }
      } else {
        // أول تسجيل دخول عبر Google — إنشاء وثيقة جديدة بدور افتراضي.
        // الدور الحقيقي (Teacher/Parent) والهاتف يُستكملان لاحقاً من
        // شاشة "إكمال الملف الشخصي" في التطبيق.
        userModel = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? googleUser.displayName ?? '',
          email: firebaseUser.email ?? googleUser.email,
          phone: firebaseUser.phoneNumber,
          role: UserRole.parent,
          isVerified: true, // بريد Google موثوق مسبقاً
          isActive: false,
          createdAt: DateTime.now(),
        );

        await createUserInFirestore(user: userModel);
      }

      // بريد Google موثوق أصلاً — isVerified: true ثابتة، بدون أي
      // اعتماد على Firebase Auth's native emailVerified flag.
      return (user: userModel.copyWith(isVerified: true), isNewUser: isNewUser);
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
        isVerified: false,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await createUserInFirestore(user: userModel);

      // ⚠️ TODO: هذا يرسل إيميل تحقق أصلي من Firebase (منفصل تماماً
      // عن رسالة الـ OTP التي يرسلها EmailJS في UC-002). بما إن
      // التطبيق أصبح يعتمد كلياً على isVerified في Firestore (وليس
      // على currentUser.emailVerified)، هذا الاستدعاء لم يعد له أثر
      // فعلي على منطق التحقق — فقط سيرسل للمستخدم إيميل إضافي مربك
      // (رابط Firebase لن يحدّث isVerified في Firestore). يُنصح
      // بإزالته أو استبداله بإرسال الـ OTP مباشرة من هنا.
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
    log(
      '--------------------> message: getCurrentUser() called in DataSourceRemote',
    );
    try {
      final user = firebaseAuth.currentUser;
      log(
        '--------------------> message: currentUser :: ${user.toString()} , isNull :: ${user == null}',
      );
      if (user == null) {
        log(
          '------------------------> message : currentUser is ${user.toString()}',
        );
        return null;
      }

      await user.reload();
      log(
        '--------------------> message: currentUser reloaded :: ${user.email}',
      );
      final currentUser = firebaseAuth.currentUser;
      log(
        '--------------------> message: currentUser after reload :: ${currentUser?.email ?? 'null'}',
      );
      if (currentUser == null) {
        return null;
      }

      // ⚠️ تم حذف الشرط `if (!currentUser.emailVerified) return null;`
      // من هنا — هذا كان السبب الفعلي وراء رجوع null دايماً حتى مع
      // حساب verified وactive. راجع التعليق في login() لتفاصيل أكثر.

      final userModel = await getUserFromFirestore(uid: currentUser.uid);
      log(
        '--------------------> message: userModel from Firestore :: ${userModel.toString()}',
      );

      if (!userModel.isVerified) {
        log('--------------------> message: user not verified (Firestore)');
        return null;
      }

      if (!userModel.isActive) {
        log('--------------------> message: user not active (Firestore)');
        return null;
      }

      // لا copyWith هنا — نرجّع الموديل زي ما جه من Firestore، بدون
      // الكتابة فوق isVerified بقيمة Firebase الأصلي.
      return userModel;
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
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseExceptionMapper.mapAuthException(e);
    }
  }
}