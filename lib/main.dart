import 'package:albra3m4/core/constants/app_font.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'feature/auth/presentation/manger/login_cubit.dart';
import 'feature/auth/presentation/screens/login_screen.dart';
import 'firebase_options.dart';
import 'injection.dart';

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
        BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>()),
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
        child: const LoginScreen(),
      ),
      ),);
  }
}
