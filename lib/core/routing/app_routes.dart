/// أسماء ومسارات الشاشات — مصدر واحد للحقيقة تمنع الأخطاء الإملائية
/// عند استخدام context.go() / context.push() في أي مكان بالتطبيق.
abstract class AppRoutes {
  const AppRoutes._();

  static const String authCheck = '/auth-check';
  static const String login = '/login';
  static const String completeGoogleProfile = '/complete-google-profile';
  static const String home = '/home';

  // Role-based dashboards (UC-003 — التوجيه حسب الدور بعد تسجيل الدخول)
  static const String adminDashboard = '/admin/dashboard';
  static const String managerDashboard = '/manager/dashboard';
  static const String teacherDashboard = '/teacher/dashboard';
  static const String parentDashboard = '/parent/dashboard';
}