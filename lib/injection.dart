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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'core/database/database_helper.dart';
import 'feature/Data/datasource/local/auth_local_data_source.dart';
import 'feature/Data/datasource/local/auth_local_data_source_impl.dart';
import 'feature/Data/datasource/remote/auth_remote_data_source_impl.dart';
import 'feature/Data/datasource/remote/authentication_remote_data_source.dart';
import 'feature/Data/repositories/authentication_repository_impl.dart';
import 'feature/domain/repositories/authentication_repository.dart';

final sl = GetIt.instance;

class Injection {
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    sl.registerLazySingleton<SharedPreferences>(() => prefs);
    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.createInstance(),
    );

    // Firebase
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    // Database
    sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

    sl.registerSingletonAsync<Database>(() => sl<DatabaseHelper>().database);

    // Remote
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: sl<FirebaseAuth>(),
        firestore: sl<FirebaseFirestore>(),
      ),
    );

    // Local
    sl.registerSingletonWithDependencies<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
        database: sl<Database>(),
      ),
      dependsOn: [Database],
    );

    // Repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        localDataSource: sl<AuthLocalDataSource>(),
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
