part of 'admin_dashboard_cubit.dart';

/// أقسام Drawer الخاصة بلوحة تحكم المشرف التقني.
/// حالياً مفعّل: userManagement فقط (UC-007) — الباقي "قريباً" حسب خارطة الطريق.
enum AdminSection {
  dashboard,
  userManagement,
  printQR,
  attendanceOverview,
  systemSettings,
  aboutApp,
}

class AdminDashboardState extends Equatable {
  final AdminSection selectedSection;

  const AdminDashboardState({
    this.selectedSection = AdminSection.dashboard,
  });

  AdminDashboardState copyWith({AdminSection? selectedSection}) {
    return AdminDashboardState(
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }

  @override
  List<Object?> get props => [selectedSection];
}
