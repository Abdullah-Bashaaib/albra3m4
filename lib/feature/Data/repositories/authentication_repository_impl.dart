import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasource/local/auth_local_data_source.dart';
import '../datasource/remote/authentication_remote_data_source.dart';
import '../exceptions/firebase_app_exception.dart';
import '../failures/firebase_failure.dart' hide NetworkFailure;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
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
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
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
    } catch (_) {
      return const Left(FirebaseUnknownFailure());
    }
  }

  // ---------------------------------------------------------------------------
  // Current User
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();

      if (userModel == null) {
        final cachedUser = await localDataSource.getCachedUser();

        if (cachedUser != null &&
            cachedUser.isVerified &&
            cachedUser.isActive) {
          return Right(cachedUser);
        }

        return const Left(UserNotFoundFailure());
      }

      final updatedUser = userModel;

      await localDataSource.cacheUser(updatedUser);

      await localDataSource.cacheLoginSession(uid: updatedUser.uid);

      return Right(updatedUser);
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
