import 'package:albra3m4/feature/auth/presentation/screens/auth_gate_screen.dart';
import 'package:albra3m4/feature/auth/presentation/screens/home_screen_temp.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth/domain/entities/user.dart';
import '../../feature/auth/presentation/screens/complete_google_profile_screen.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import 'app_routes.dart';

/// إعداد go_router للتطبيق — حالياً 3 مسارات فقط (Phase 1):
/// تسجيل الدخول، إكمال الملف الشخصي بعد Google، والشاشة الرئيسية المؤقتة.
/// أضف باقي المسارات (register, otp-verification, dashboards حسب الدور...)
/// هنا لاحقاً بنفس النمط.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.authCheck,
    routes: [
      GoRoute(
        path: AppRoutes.authCheck,
        name: AppRoutes.authCheck,
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeGoogleProfile,
        name: AppRoutes.completeGoogleProfile,
        builder: (context, state) {
          // يُمرَّر المستخدم عبر `extra` من login_screen.dart بعد
          // LoginGoogleProfileIncomplete — راجع login_cubit.dart / login_state.dart.
          final user = state.extra as UserEntity;
          return CompleteGoogleProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
