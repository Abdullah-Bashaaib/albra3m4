import 'package:albra3m4/feature/attendance/data/repo/attendance_repo_imp.dart';
import 'package:albra3m4/feature/attendance/data/source/attendance_local.dart';
import 'package:albra3m4/feature/attendance/data/source/attendance_remote.dart';
import 'package:albra3m4/feature/attendance/domain/repo/attendance_repo.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/add_attendance_teacher_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/add_q_r_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/check_code.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/get_q_r_teacher_usecase.dart';
import 'package:albra3m4/feature/attendance/domain/usecases/Teacher/get_q_r_usecase.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/auth/domain/usecases/complete_google_profile_use_case.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
    final prefs = await SharedPreferences.getInstance();

    sl.registerLazySingleton<SharedPreferences>(() => prefs);
    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.createInstance(),
    );

    // Firebase
    // =========================

    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    

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
        con: sl<InternetConnectionChecker>(),
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

    /// ===================== [ Attendance ] ====================
    // Remote
    sl.registerLazySingleton<AttendanceRemote>(
      () => AttendanceRemoteImp(firestore: sl<FirebaseFirestore>()),
    );
    // Local
    sl.registerLazySingleton<AttendanceLocal>(
      () => AttendanceLocalImp(sl<SharedPreferences>()),
    );
    // Repo
    sl.registerLazySingleton<AttendanceRepo>(
      () => AttendanceRepoImp(
        sl<InternetConnectionChecker>(),
        sl<AttendanceRemote>(),
        sl<AttendanceLocal>(),
      ),
    );

    // Usecase
    sl.registerLazySingleton<GetQRUsecase>(
      () => GetQRUsecase(sl<AttendanceRepo>()),
    );
    sl.registerLazySingleton<AddQRUsecase>(
      () => AddQRUsecase(sl<AttendanceRepo>()),
    );
    sl.registerLazySingleton<CheckCodeUsecase>(
      () => CheckCodeUsecase(sl<AttendanceRepo>()),
    );
    sl.registerLazySingleton<AddAttendanceTeacherUsecase>(
      () => AddAttendanceTeacherUsecase(sl<AttendanceRepo>()),
    );
    sl.registerLazySingleton<GetQRTeacherUsecase>(
      () => GetQRTeacherUsecase(sl<AttendanceRepo>()),
    );
    // Cubit
    sl.registerLazySingleton<AttendanceCubit>(
      () => AttendanceCubit(
        getQRUsecase: sl<GetQRUsecase>(),
        addQRUsecase: sl<AddQRUsecase>(),
        checkCodeUsecase: sl<CheckCodeUsecase>(),
        addAttendanceTeacherUsecase: sl<AddAttendanceTeacherUsecase>(),
        getQRTeacherUsecase: sl<GetQRTeacherUsecase>(),
      ),
    );

  }
}
