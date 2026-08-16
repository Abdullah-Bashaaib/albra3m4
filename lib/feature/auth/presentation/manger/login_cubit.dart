import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/get_current_user.dart';
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
  ) : super(LoginInitial());
  final LoginUseCase _loginUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final GetCachedUserUseCase _getCachedUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  // Global variables
  UserEntity? user;

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
