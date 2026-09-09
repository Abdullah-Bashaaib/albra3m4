import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

import 'app_drawer_header.dart';
import 'app_drawer_menu_item.dart';

class AppDrawer extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onLogout;

  /// القسم المحدد حالياً (اختياري — لتحديد العنصر النشط في القائمة)
  final String? selectedItemKey;

  /// callback عند اختيار أي عنصر — يُمرَّر مفتاح العنصر (key)
  final void Function(String key)? onItemSelected;

  const AppDrawer({
    super.key,
    required this.user,
    required this.onLogout,
    this.selectedItemKey,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = _itemsForRole(user.role);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            AppDrawerHeader(
              name: user.fullName,
              email: user.email,
              roleLabel: user.role.arabicLabel,
            ),

            const SizedBox(height: 12),

            // ── قائمة الصفحات ────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: items.map((item) {
                  return AppDrawerMenuItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: selectedItemKey == item.key,
                    comingSoon: item.comingSoon,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemSelected?.call(item.key);
                    },
                  );
                }).toList(),
              ),
            ),

            // ── تسجيل الخروج ─────────────────────────────────
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: AppDrawerMenuItem(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                onTap: () {
                  Navigator.of(context).pop();
                  onLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني قائمة العناصر حسب دور المستخدم
  List<_DrawerItem> _itemsForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [
          _DrawerItem(
            key: 'adminDashboard',
            icon: Icons.dashboard_rounded,
            label: 'لوحة التحكم',
          ),
          _DrawerItem(
            key: 'userManagement',
            icon: Icons.people_alt_rounded,
            label: 'إدارة المستخدمين',
          ),
          _DrawerItem(
            key: 'attendanceOverview',
            icon: Icons.bar_chart_rounded,
            label: 'إحصائيات الحضور',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'printQR',
            icon: Icons.qr_code,
            label: 'طباعة رمز الـ QR',
            comingSoon: false,
          ),
          _DrawerItem(
            key: 'systemSettings',
            icon: Icons.settings_rounded,
            label: 'إعدادات النظام',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'aboutApp',
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
          ),
        ];

      case UserRole.manager:
        return [
          _DrawerItem(
            key: 'managerDashboard',
            icon: Icons.dashboard_rounded,
            label: 'لوحة التحكم',
          ),
          _DrawerItem(
            key: 'QRTeacher',
            icon: Icons.qr_code,
            label: 'باركود الحضور',
          ),
          _DrawerItem(
            key: 'teacherAttendance',
            icon: Icons.how_to_reg_rounded,
            label: 'حضور المعلمات',
          ),
          _DrawerItem(
            key: 'viewStudents',
            icon: Icons.info_outline_rounded,
            label: 'عرض الطلاب',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'viewStudentsAttendance',
            icon: Icons.info_outline_rounded,
            label: 'حضور الطلاب',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'aboutApp',
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
            comingSoon: true,
          ),
        ];

      case UserRole.teacher:
        return [
          _DrawerItem(
            key: 'teacherDashboard',
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
          ),
          _DrawerItem(
            key: 'teacherAttendanceScanning',
            icon: Icons.qr_code_scanner_rounded,
            label: 'تسجيل الحضور',
          ),
          _DrawerItem(
            key: 'schedule',
            icon: Icons.calendar_today_rounded,
            label: 'جدولي',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'aboutApp',
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
            comingSoon: true,
          ),
        ];

      case UserRole.parent:
        return [
          _DrawerItem(
            key: 'childTracking',
            icon: Icons.child_care_rounded,
            label: 'متابعة الطفل',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'notifications',
            icon: Icons.notifications_rounded,
            label: 'الإشعارات',
            comingSoon: true,
          ),
          _DrawerItem(
            key: 'aboutApp',
            icon: Icons.info_outline_rounded,
            label: 'عن التطبيق',
            comingSoon: true,
          ),
        ];
    }
  }
}

/// نموذج بيانات عنصر الدراور — خاص بهذا الملف
class _DrawerItem {
  final String key;
  final IconData icon;
  final String label;
  final bool comingSoon;

  const _DrawerItem({
    required this.key,
    required this.icon,
    required this.label,
    this.comingSoon = false,
  });
}
