import '../../../../core/errors/failure.dart';

abstract class FirebaseFailure extends Failure {
  const FirebaseFailure(super.message);
}

class InvalidEmailFailure extends FirebaseFailure {
  const InvalidEmailFailure() : super('البريد الإلكتروني غير صالح.');
}

class UserNotFoundFailure extends FirebaseFailure {
  const UserNotFoundFailure()
    : super('لا يوجد حساب مرتبط بهذا البريد الإلكتروني.');
}

class WrongPasswordFailure extends FirebaseFailure {
  const WrongPasswordFailure()
    : super('البريد الإلكتروني أو كلمة المرور غير صحيحة.');
}

class InvalidCredentialFailure extends FirebaseFailure {
  const InvalidCredentialFailure()
    : super('البريد الإلكتروني أو كلمة المرور غير صحيحة.');
}

class EmailAlreadyInUseFailure extends FirebaseFailure {
  const EmailAlreadyInUseFailure() : super('البريد الإلكتروني مستخدم بالفعل.');
}

class WeakPasswordFailure extends FirebaseFailure {
  const WeakPasswordFailure() : super('كلمة المرور ضعيفة.');
}

class UserDisabledFailure extends FirebaseFailure {
  const UserDisabledFailure() : super('تم تعطيل هذا الحساب.');
}

class DeleteUserFailure extends FirebaseFailure {
  const DeleteUserFailure() : super('مشكلة في حذف الحساب');
}

class TooManyRequestsFailure extends FirebaseFailure {
  const TooManyRequestsFailure()
    : super('تم تجاوز عدد المحاولات المسموح بها. حاول لاحقًا.');
}

class OperationNotAllowedFailure extends FirebaseFailure {
  const OperationNotAllowedFailure() : super('هذه العملية غير مسموح بها.');
}

class NetworkFailure extends FirebaseFailure {
  const NetworkFailure() : super('تعذر الاتصال بالإنترنت.');
}

class EmailNotVerifiedFailure extends FirebaseFailure {
  const EmailNotVerifiedFailure() : super('يجب تأكيد البريد الإلكتروني أولاً.');
}

class AccountInactiveFailure extends FirebaseFailure {
  const AccountInactiveFailure()
    : super('حسابك غير نشط حاليًا. يرجى التواصل مع الإدارة.');
}

class UserDocumentNotFoundFailure extends FirebaseFailure {
  const UserDocumentNotFoundFailure() : super('بيانات المستخدم غير موجودة.');
}

class FirestorePermissionDeniedFailure extends FirebaseFailure {
  const FirestorePermissionDeniedFailure()
    : super('ليس لديك صلاحية للوصول إلى بيانات المستخدم.');
}

class GoogleSignInCancelledFailure extends FirebaseFailure {
  const GoogleSignInCancelledFailure() : super('إلغاء المستخدم');
}

class FirebaseUnknownFailure extends FirebaseFailure {
  const FirebaseUnknownFailure() : super('حدث خطأ غير متوقع. حاول مرة أخرى.');
}
