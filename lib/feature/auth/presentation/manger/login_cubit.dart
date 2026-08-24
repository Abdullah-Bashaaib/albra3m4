import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/complete_google_profile_use_case.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/google_login_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/send_password_reset_email.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._loginUseCase,
    this._registerUserUseCase,
    this._sendEmailVerificationUseCase,
    this._sendPasswordResetEmail,
    this._getCachedUserUseCase,
    this._getCurrentUserUseCase,
    this._googleLoginUseCase,
    this._completeGoogleProfileUseCase,
  ) : super(AuthInitial());
  final LoginUseCase _loginUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final GetCachedUserUseCase _getCachedUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final CompleteGoogleProfileUseCase _completeGoogleProfileUseCase;

  // Global variables
  UserEntity? user;
  Future<void> checkAuthStatus() async {
    emit(const AuthCheckingSession());

    final result = await _getCurrentUserUseCase();

    result.fold(
      (_) {
        log('message: user is ${user?.email ?? 'null'}');
        user = null;
        emit(const AuthUnauthenticated());
      },
      (userEntity) {
        user = userEntity;
        emit(AuthAuthenticated(userEntity));
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await _loginUseCase(email: email, password: password);
    result.fold(
      (failure) {
        emit(LoginFailure(failure.message));
      },
      (userLogged) {
        user = userLogged;
        emit(LoginSuccess());
      },
    );
  }

  /// تسجيل الدخول عبر Google — تُستدعى من زر [GoogleSignInButton].
  ///
  /// لو كان الحساب جديداً (أول مرة يسجّل بها عبر Google)، تُطلق
  /// [LoginGoogleProfileIncomplete] بدل [LoginSuccess] عشان الشاشة توجّه
  /// المستخدم لإكمال بياناته (الدور الحقيقي + الهاتف) قبل الدخول للتطبيق.
  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    final result = await _googleLoginUseCase();
    result.fold((failure) => emit(LoginFailure(failure.message)), (data) {
      user = data.user;

      if (data.isNewUser) {
        emit(LoginGoogleProfileIncomplete(data.user));
      } else {
        emit(LoginSuccess());
      }
    });
  }

  /// إكمال الملف الشخصي بعد Google Sign-In الأول — تُستدعى من زر الحفظ
  /// في CompleteGoogleProfileScreen.
  Future<void> completeGoogleProfile({
    required UserEntity currentUser,
    required String fullName,
    required UserRole role,
    required String phone,
  }) async {
    emit(LoginLoading());
    final result = await _completeGoogleProfileUseCase(
      currentUser: currentUser,
      role: role,
      phone: phone,
      fullName: fullName,
    );
    result.fold((failure) => emit(LoginFailure(failure.message)), (userLogged) {
      user = userLogged;
      emit(LoginSuccess());
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
  }) async {
    emit(LoginLoading());
    final result = await _registerUserUseCase(
      email,
      password,
      fullName,
      role,
      phone,
    );
    result.fold(
      (failure) {
        emit(LoginFailure(failure.message));
      },
      (userLogged) {
        user = userLogged;
        emit(LoginSuccess());
      },
    );
  }
}
