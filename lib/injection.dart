import 'package:albra3m4/feature/auth/domain/usecases/complete_google_profile_use_case.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'core/database/database_helper.dart';
import 'feature/auth/Data/datasource/local/auth_local_data_source.dart';
import 'feature/auth/Data/datasource/local/auth_local_data_source_impl.dart';
import 'feature/auth/Data/datasource/remote/auth_remote_data_source_impl.dart';
import 'feature/auth/Data/datasource/remote/authentication_remote_data_source.dart';
import 'feature/auth/Data/repositories/authentication_repository_impl.dart';
import 'feature/auth/domain/repositories/authentication_repository.dart';
import 'feature/auth/domain/usecases/get_cached_user.dart';
import 'feature/auth/domain/usecases/get_current_user.dart';
import 'feature/auth/domain/usecases/google_login_use_case.dart';
import 'feature/auth/domain/usecases/login_use_case.dart';
import 'feature/auth/domain/usecases/register_user_usecase.dart';
import 'feature/auth/domain/usecases/send_email_verification.dart';
import 'feature/auth/domain/usecases/send_password_reset_email.dart';

final sl = GetIt.instance;

class Injection {
  static Future<void> init() async {
    // =========================
    // Firebase
    // =========================

    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    // =========================
    // Shared Preferences
    // =========================

    final sharedPreferences = await SharedPreferences.getInstance();

    sl.registerSingleton<SharedPreferences>(sharedPreferences);

    // =========================
    // Database
    // =========================

    sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

    sl.registerSingletonAsync<Database>(() => sl<DatabaseHelper>().database);

    // =========================
    // Remote Data Source
    // =========================

    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: sl<FirebaseAuth>(),
        firestore: sl<FirebaseFirestore>(),
      ),
    );

    // =========================
    // Local Data Source
    // =========================

    sl.registerSingletonWithDependencies<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        database: sl<Database>(),
        sharedPreferences: sl<SharedPreferences>(),
      ),
      dependsOn: [Database],
    );

    // =========================
    // Repository
    // =========================

    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        localDataSource: sl<AuthLocalDataSource>(),
      ),
    );

    // =========================
    // Use Cases
    // =========================

    sl.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<RegisterUserUseCase>(
      () => RegisterUserUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<SendEmailVerificationUseCase>(
      () => SendEmailVerificationUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<SendPasswordResetEmail>(
      () => SendPasswordResetEmail(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<GetCachedUserUseCase>(
      () => GetCachedUserUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<GoogleLoginUseCase>(
      () => GoogleLoginUseCase(sl<AuthRepository>()),
    );

    sl.registerLazySingleton(
      () => CompleteGoogleProfileUseCase(sl<AuthRepository>()),
    );

    // =========================
    // Cubit
    // =========================

    sl.registerFactory<LoginCubit>(
      () => LoginCubit(
        sl<LoginUseCase>(),
        sl<RegisterUserUseCase>(),
        sl<SendEmailVerificationUseCase>(),
        sl<SendPasswordResetEmail>(),
        sl<GetCachedUserUseCase>(),
        sl<GetCurrentUserUseCase>(),
        sl<GoogleLoginUseCase>(),
        sl<CompleteGoogleProfileUseCase>(),
      ),
    );
  }
}
