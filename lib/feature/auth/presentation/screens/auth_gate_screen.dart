import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/role_route_mapper.dart';

/// نقطة الدخول الوحيدة عند تشغيل التطبيق.
///
/// مسؤوليتها الوحيدة والحصرية: التحقق من حالة الجلسة المحفوظة،
/// ثم توجيه المستخدم عبر go_router للمسار الصحيح — الـ Dashboard
/// المناسب لدوره (عبر role_route_mapper.dart) أو شاشة الدخول.
///
/// ⚠️ لا تبني أي شاشة أخرى مباشرة. كل تنقّل يتم فقط عبر context.go().
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: _handleNavigation,
      child: const Scaffold(
        body: AppBackground(
          child: Center(
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
      ),
    );
  }

  void _handleNavigation(BuildContext context, LoginState state) {
    // لسه بيتحقق من الجلسة المحفوظة — يبقى المستخدم على شاشة التحميل
    if (state is AuthCheckingSession || state is AuthInitial) {
      return;
    }

    if (state is AuthAuthenticated) {
      context.go(state.user.role.dashboardRoute);
      return;
    }

    if (state is LoginSuccess) {
      context.go(state.user.role.dashboardRoute);
      return;
    }

    if (state is LoginGoogleProfileIncomplete) {
      // ملاحظة: هنا go() مقصودة (مش push()) — عكس اللي بيحصل في
      // LoginScreen، لأن دي أول شاشة تظهر عند فتح التطبيق، فمفيش
      // شاشة "دخول" قبلها في الـ stack يرجع لها المستخدم بزر الرجوع.
      context.go(AppRoutes.completeGoogleProfile, extra: state.user);
      return;
    }

    if (state is AuthUnauthenticated) {
      CustomSnackBar.showError(context, 'User Unauthenticated');
    }
    // AuthUnauthenticated / LoginFailure / أي حالة غير متوقعة أخرى
    context.go(AppRoutes.login);
  }
}