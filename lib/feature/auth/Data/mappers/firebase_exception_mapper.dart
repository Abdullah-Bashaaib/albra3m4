import 'package:firebase_auth/firebase_auth.dart';

import '../exceptions/firebase_app_exception.dart';

class FirebaseExceptionMapper {
  const FirebaseExceptionMapper._();

  static FirebaseAppException mapAuthException(
    FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return const FirebaseAuthAppException(
          code: 'invalid-email',
          message: 'البريد الإلكتروني غير صالح.',
        );

      case 'user-not-found':
        return const FirebaseAuthAppException(
          code: 'user-not-found',
          message: 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.',
        );

      case 'wrong-password':
        return const FirebaseAuthAppException(
          code: 'wrong-password',
          message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        );

      case 'invalid-credential':
        return const FirebaseAuthAppException(
          code: 'invalid-credential',
          message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        );

      case 'email-already-in-use':
        return const FirebaseAuthAppException(
          code: 'email-already-in-use',
          message: 'البريد الإلكتروني مستخدم بالفعل.',
        );

      case 'weak-password':
        return const FirebaseAuthAppException(
          code: 'weak-password',
          message: 'كلمة المرور ضعيفة.',
        );

      case 'user-disabled':
        return const FirebaseAuthAppException(
          code: 'user-disabled',
          message: 'تم تعطيل هذا الحساب.',
        );

      case 'too-many-requests':
        return const FirebaseAuthAppException(
          code: 'too-many-requests',
          message: 'تم تجاوز عدد المحاولات المسموح بها.',
        );

      case 'operation-not-allowed':
        return const FirebaseAuthAppException(
          code: 'operation-not-allowed',
          message: 'هذه العملية غير مسموح بها.',
        );

      case 'network-request-failed':
        return const FirebaseNetworkAppException('تعذر الاتصال بالإنترنت.');

      default:
        return FirebaseAuthAppException(
          code: exception.code,
          message: exception.message ?? 'حدث خطأ غير متوقع في المصادقة.',
        );
    }
  }

  static FirebaseAppException mapFirestoreException(
    FirebaseException exception,
  ) {
    switch (exception.code) {
      case 'permission-denied':
        return const FirebaseFirestoreAppException(
          code: 'permission-denied',
          message: 'ليس لديك صلاحية للوصول إلى البيانات.',
        );

      case 'unavailable':
      case 'network-request-failed':
        return const FirebaseNetworkAppException(
          'تعذر الاتصال بخدمة Firebase.',
        );

      case 'not-found':
        return const FirebaseFirestoreAppException(
          code: 'not-found',
          message: 'بيانات المستخدم غير موجودة.',
        );

      default:
        return FirebaseFirestoreAppException(
          code: exception.code,
          message:
              exception.message ?? 'حدث خطأ أثناء الوصول إلى بيانات المستخدم.',
        );
    }
  }
}
