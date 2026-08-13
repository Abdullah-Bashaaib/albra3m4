import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
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
  }
}
