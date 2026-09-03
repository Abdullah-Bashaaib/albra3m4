import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';
import 'package:albra3m4/feature/teachers_management/presentation/pages/teachers_list_screen.dart';
import 'package:albra3m4/injection.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/app_colors.dart';
import 'feature/auth/presentation/manger/login_cubit.dart';
import 'feature/auth/presentation/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AttendanceCubit>(create: (_) => sl<AttendanceCubit>()),
        BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>()),
        BlocProvider<TeacherCubit>(create: (_) => sl<TeacherCubit>()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              fontFamily: AppFont.primary,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: const TeachersListScreen(),
        ),
      ),
    );
  }
}
