import 'package:albra3m4/feature/users/presentation/manager/admin_dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawer_header_widget.dart';
import 'drawer_menu_item.dart';

class AdminDashboardDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminDashboardDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AdminDashboardCubit>().state.selectedSection;
    final cubit = context.read<AdminDashboardCubit>();

    void select(AdminSection section) {
      cubit.selectSection(section);
      Navigator.of(context).pop();
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // TODO: استبدل هذه القيم بالاسم/البريد الفعليين من AuthCubit / UserEntity
            const DrawerHeaderWidget(
              adminName: 'المشرف التقني',
              adminEmail: 'admin@albaraem.com',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerMenuItem(
                    icon: Icons.people_alt_rounded,
                    label: 'إدارة المستخدمين',
                    isSelected: selected == AdminSection.userManagement,
                    onTap: () => select(AdminSection.userManagement),
                  ),
                  DrawerMenuItem(
                    icon: Icons.qr_code,
                    label: 'طباعة رمز الـ QR',
                    isSelected: selected == AdminSection.printQR,
                    onTap: () => select(AdminSection.printQR),
                  ),
                  DrawerMenuItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'إحصائيات الحضور',
                    isSelected: selected == AdminSection.attendanceOverview,
                    comingSoon: false,
                    onTap: () => select(AdminSection.attendanceOverview),
                  ),
                  DrawerMenuItem(
                    icon: Icons.settings_rounded,
                    label: 'إعدادات النظام',
                    isSelected: selected == AdminSection.systemSettings,
                    comingSoon: true,
                    onTap: () => select(AdminSection.systemSettings),
                  ),
                  DrawerMenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'عن التطبيق',
                    isSelected: selected == AdminSection.aboutApp,
                    onTap: () => select(AdminSection.aboutApp),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: DrawerMenuItem(
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
}
