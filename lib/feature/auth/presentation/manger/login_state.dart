part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();
}
/// أول حالة عند تشغيل التطبيق.
class AuthInitial extends LoginState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// التحقق من الجلسة الحالية.
class AuthCheckingSession extends LoginState {
  const AuthCheckingSession();

  @override
  List<Object?> get props => [];
}

/// يوجد مستخدم مسجل دخول.
class AuthAuthenticated extends LoginState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// لا توجد جلسة.
class AuthUnauthenticated extends LoginState {
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// عملية جارية.
class AuthLoading extends LoginState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

final class LoginLoading extends LoginState {
  @override
  List<Object> get props => [];
}

final class LoginSuccess extends LoginState {
  @override
  List<Object> get props => [];
}

/// تُطلق بعد أول تسجيل دخول عبر Google (حساب جديد لم يُكمل بياناته بعد).
/// الشاشة تستمع لهذه الحالة وتنتقل إلى CompleteGoogleProfileScreen.
final class LoginGoogleProfileIncomplete extends LoginState {
  final UserEntity user;

  const LoginGoogleProfileIncomplete(this.user);

  @override
  List<Object> get props => [user];
}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object> get props => [message];
}