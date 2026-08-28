import '../../feature/auth/domain/entities/user.dart';
import 'app_routes.dart';

/// يحوّل دور المستخدم (UserRole) إلى مسار الـ Dashboard الخاص به.
///
/// هذا هو المكان الوحيد في المشروع اللي بيقرر "أي دور يروح لأي مسار".
/// أي شاشة محتاجة توجّه المستخدم بعد تسجيل الدخول بناءً على دوره
/// تستخدم `role.dashboardRoute` بدل ما تكرر switch/if بنفسها —
/// لو ضفت دور جديد أو غيّرت مسار Dashboard، التعديل هنا بس.
extension RoleRoute on UserRole {
  String get dashboardRoute => switch (this) {
    UserRole.superAdmin => AppRoutes.adminDashboard,
    UserRole.manager => AppRoutes.managerDashboard,
    UserRole.teacher => AppRoutes.teacherDashboard,
    UserRole.parent => AppRoutes.parentDashboard,
  };
}
