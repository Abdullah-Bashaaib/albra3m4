/// أسماء ومسارات الشاشات — مصدر واحد للحقيقة تمنع الأخطاء الإملائية
/// عند استخدام context.go() / context.push() في أي مكان بالتطبيق.
abstract class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String completeGoogleProfile = '/complete-google-profile';
  static const String home = '/home';
}