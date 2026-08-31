import 'package:albra3m4/feature/auth/presentation/screens/auth_gate_screen.dart';
import 'package:albra3m4/feature/auth/presentation/screens/home_screen_temp.dart';
import 'package:go_router/go_router.dart';

import '../../feature/auth/domain/entities/user.dart';
import '../../feature/auth/presentation/screens/complete_google_profile_screen.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import 'app_routes.dart';

/// إعداد go_router للتطبيق.
///
/// مسارات الـ Dashboards الأربعة (admin/manager/teacher/parent) مضافة
/// هنا بالفعل ومربوطة بـ UserRole عبر role_route_mapper.dart، لكنها
/// تُبنى حالياً بـ HomeScreen المؤقتة كـ placeholder — استبدل كل
/// builder بشاشة الـ Dashboard الفعلية بمجرد بنائها، بدون أي حاجة
/// لتعديل منطق التوجيه في auth_gate_screen.dart / login_screen.dart.
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
          // يُمرَّر المستخدم عبر `extra` — راجع login_cubit.dart / login_state.dart.
          final user = state.extra as UserEntity;
          return CompleteGoogleProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Role-based dashboards (UC-003) ──────────────────────────
      // TODO: استبدل HomeScreen() بشاشة الـ Dashboard الفعلية لكل دور
      // بمجرد بنائها. الـ path والتوجيه جاهزين ومربوطين بالفعل.
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: AppRoutes.adminDashboard,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.managerDashboard,
        name: AppRoutes.managerDashboard,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: AppRoutes.teacherDashboard,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentDashboard,
        name: AppRoutes.parentDashboard,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}