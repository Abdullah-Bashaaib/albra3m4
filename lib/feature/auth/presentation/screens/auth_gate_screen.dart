import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/feature/attendance/presentation/pages/teacher_scanning_q_r.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:albra3m4/feature/auth/presentation/screens/complete_google_profile_screen.dart';
import 'package:albra3m4/feature/auth/presentation/screens/home_screen_temp.dart';
import 'package:albra3m4/feature/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state is AuthCheckingSession || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جارٍ التحقق من حالة تسجيل الدخول...'),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated || state is LoginSuccess) {
          return const TeacherScanningQR();
        }
        if (state is LoginGoogleProfileIncomplete) {
          return CompleteGoogleProfileScreen(user: state.user);
        }
        if (state is AuthUnauthenticated || state is LoginFailure) {
          return const LoginScreen();
        }

        return const Scaffold(
          body: Center(
            child: AppBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جارٍ التحقق من حالة تسجيل الدخول...'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
