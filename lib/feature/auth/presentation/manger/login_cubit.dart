import 'dart:developer';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/complete_google_profile_use_case.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/watch_current_user_use_case.dart';
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
    this._watchCurrentUserUseCase,
  ) : super(AuthInitial());
  final LoginUseCase _loginUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final GetCachedUserUseCase _getCachedUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final CompleteGoogleProfileUseCase _completeGoogleProfileUseCase;
  final WatchCurrentUserUseCase _watchCurrentUserUseCase;
  StreamSubscription<UserEntity?>? _userUpdates;

  // Global variables
  UserEntity? user;

  Future<void> checkAuthStatus() async {
    log(
      '[message]:-----------------------------------[Here in Cubit method checkAuthStatus start]',
    );
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
        _observeCurrentUser(userEntity);
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
        emit(LoginSuccess(user!));
        _observeCurrentUser(userLogged);
      },
    );
  }

  Future<void> loginWithGoogle() async {
    log('message: loginWithGoogle at Cubit start');
    emit(LoginLoading());
    final result = await _googleLoginUseCase();
    result.fold((failure) => emit(LoginFailure(failure.message)), (data) {
      user = data.user;
      log('message: the user is new : ${data.isNewUser}');
      if (data.isNewUser) {
        emit(LoginGoogleProfileIncomplete(data.user));
      } else {
        emit(LoginSuccess(user!));
        _observeCurrentUser(user!);
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
      if (user!.isActive) {
        emit(LoginSuccess(user!));
        _observeCurrentUser(userLogged);
      } else {
        emit(AuthUnauthenticated());
      }

      // emit(LoginFailure('تواصل مع الإدارة لتنشيط الحساب'));
    });
  }

  void _observeCurrentUser(UserEntity current) {
    _userUpdates?.cancel();
    _userUpdates = _watchCurrentUserUseCase(current.uid).listen((latest) {
      if (isClosed) return;
      if (latest == null || !latest.isActive || !latest.isVerified) {
        user = null;
        emit(const AuthUnauthenticated());
        return;
      }
      final previous = user;
      user = latest;
      if (previous != null &&
          previous.role == latest.role &&
          previous.isActive == latest.isActive &&
          previous.isVerified == latest.isVerified &&
          previous.schoolId == latest.schoolId &&
          previous.permissions.length == latest.permissions.length &&
          previous.permissions.every(latest.permissions.contains)) {
        return;
      }
      emit(AuthAuthenticated(latest));
    }, onError: (Object error, StackTrace stack) {
      // A temporary network outage must not sign the user out.
      log('Live user snapshot unavailable: $error', stackTrace: stack);
    });
  }

  @override
  Future<void> close() async {
    await _userUpdates?.cancel();
    await super.close();
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
        emit(LoginSuccess(user!));
      },
    );
  }
}
