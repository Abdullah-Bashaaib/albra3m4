import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasource/local/auth_local_data_source.dart';
import '../datasource/remote/authentication_remote_data_source.dart';
import '../exceptions/firebase_app_exception.dart';
import '../failures/firebase_failure.dart' hide NetworkFailure;
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final InternetConnectionChecker con;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.con,
  });

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await localDataSource.cacheUser(userModel);

      await localDataSource.cacheLoginSession(uid: userModel.uid);

      return Right(userModel);
    } on FirebaseAppException catch (e) {
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in login: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Login with Google
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, ({UserEntity user, bool isNewUser})>>
  loginWithGoogle() async {
    try {
      final result = await remoteDataSource.loginWithGoogle();

      await localDataSource.cacheUser(result.user);

      await localDataSource.cacheLoginSession(uid: result.user.uid);

      return Right((user: result.user, isNewUser: result.isNewUser));
    } on FirebaseAppException catch (e) {
      log(
          'message:-----------------------------------[Here in Repository start]');
      log('message: error is ${e.message}');
      log(
          'message:-----------------------------------[Here in Repository end]');
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in loginWithGoogle: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Complete Google Profile
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> completeGoogleProfile({
    required UserEntity currentUser,
    required UserRole role,
    required String phone,
    required String fullName,
  }) async {
    try {
      final updatedModel = UserModel.fromEntity(
        currentUser,
      ).copyWith(role: role, phone: phone, fullName: fullName);

      await remoteDataSource.updateUserInFirestore(user: updatedModel);

      await localDataSource.cacheUser(updatedModel);

      return Right(updatedModel);
    } on FirebaseAppException catch (e) {
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in completeGoogleProfile: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      /*
       * المستخدم لم يؤكد البريد بعد.
       *
       * Firebase يقوم بتسجيله داخليًا بعد createUser،
       * لكن تطبيقنا لا يعتبره Authenticated حتى يتم التحقق.
       */

      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on FirebaseAppException catch (e) {
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in register: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Email Verification
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();

      return const Right(unit);
    } on FirebaseAppException catch (e) {
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in sendEmailVerification: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);

      return const Right(unit);
    } on FirebaseAppException catch (e) {
      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (e, s) {
      log('Error in sendPasswordResetEmail: $e', stackTrace: s);
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Current User
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    log('--------------------> message: getCurrentUser() called');
    try {
      if (await con.hasConnection) {
        log('--------------------> message: has internet connection');
        final userModel = await remoteDataSource.getCurrentUser();
        log('----------> user :: ${userModel.toString()}');
        if (userModel == null) {
          await localDataSource.clearLoginSession();
          await localDataSource
              .deleteCachedUser(); // حذف أي نسخة قديمة من المستخدم المخزن محليًا

          return const Left(UserNotFoundFailure());
        } else {
          log('--------> user is ${userModel.toString()}');
          await localDataSource.cacheUser(userModel);
          await localDataSource.cacheLoginSession(uid: userModel.uid);
          return Right(userModel);
        }
      }
      log('--------------------> message: no internet connection');
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.isVerified && cachedUser.isActive) {
        await localDataSource.cacheLoginSession(uid: cachedUser.uid);
        log(
          '--------------------> message: returning cached user :: ${cachedUser.toString()}',
        );
        return Right(cachedUser);
      }
      return Left(AuthFailure('no internet connection'));
    } on FirebaseAppException catch (e) {
      /*
       * في حالة عدم توفر الإنترنت أو Firebase:
       * نحاول استخدام SQLite.
       */
      if (e is FirebaseNetworkAppException) {
        final cachedUser = await localDataSource.getCachedUser();

        if (cachedUser != null &&
            cachedUser.isVerified &&
            cachedUser.isActive) {
          await localDataSource.cacheLoginSession(uid: cachedUser.uid);

          return Right(cachedUser);
        }
      }

      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (_) {
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Cached User
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();

      if (userModel == null) {
        return const Left(UserNotFoundFailure());
      }

      return Right(userModel);
    } catch (_) {
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();

      await localDataSource.clearLoginSession();

      await localDataSource.deleteCachedUser();

      return const Right(unit);
    } on FirebaseAppException catch (e) {
      /*
       * حتى لو فشل Firebase signOut بسبب مشكلة شبكة،
       * نريد تنظيف الـ local session.
       */
      await localDataSource.clearLoginSession();
      await localDataSource.deleteCachedUser();

      return Left(_mapFirebaseExceptionToFailure(e));
    } catch (_) {
      await localDataSource.clearLoginSession();
      await localDataSource.deleteCachedUser();

      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Failure Mapper
  // ---------------------------------------------------------------------------

  Failure _mapFirebaseExceptionToFailure(FirebaseAppException exception) {
    if (exception is FirebaseNetworkAppException) {
      return NetworkFailure('No internet connection.');
    }

    if (exception is FirebaseAuthAppException) {
      switch (exception.code) {
        case 'invalid-email':
          return const InvalidEmailFailure();

        case 'user-not-found':
          return const UserNotFoundFailure();

        case 'wrong-password':
          return const WrongPasswordFailure();

        case 'invalid-credential':
          return const InvalidCredentialFailure();

        case 'email-already-in-use':
          return const EmailAlreadyInUseFailure();

        case 'weak-password':
          return const WeakPasswordFailure();

        case 'user-disabled':
          return const UserDisabledFailure();

        case 'too-many-requests':
          return const TooManyRequestsFailure();

        case 'operation-not-allowed':
          return const OperationNotAllowedFailure();

        case 'email-not-verified':
          return const EmailNotVerifiedFailure();

        case 'account-inactive':
          return const AccountInactiveFailure();

        // TODO: أضف case 'sign-in-cancelled' هنا بعد إضافة
        // GoogleSignInCancelledFailure إلى firebase_failure.dart.

        default:
          return const FirebaseUnknownFailure();
      }
    }

    if (exception is FirebaseFirestoreAppException) {
      switch (exception.code) {
        case 'permission-denied':
          return const FirestorePermissionDeniedFailure();

        case 'not-found':
          return const UserDocumentNotFoundFailure();

        default:
          return const FirebaseUnknownFailure();
      }
    }

    return const FirebaseUnknownFailure();
  }
}
