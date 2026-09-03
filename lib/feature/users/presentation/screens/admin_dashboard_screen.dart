import 'dart:ui';

import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/feature/users/presentation/manager/admin_dashboard_cubit.dart'
    show AdminDashboardCubit, AdminSection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_font.dart';
import '../widgets/admin_dashboard_drawer.dart';
import '../widgets/coming_soon_view.dart';
import '../widgets/user_management/user_management_view.dart';

/// شاشة لوحة تحكم المشرف التقني (Super Admin Dashboard).
/// تعرض Drawer بأقسام النظام، وتبدّل المحتوى حسب القسم المختار عبر
/// [AdminDashboardCubit] دون إعادة بناء الشاشة بالكامل.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  String _titleFor(AdminSection section) {
    switch (section) {
      case AdminSection.userManagement:
        return 'إدارة المستخدمين';
      case AdminSection.attendanceOverview:
        return 'إحصائيات الحضور';
      case AdminSection.systemSettings:
        return 'إعدادات النظام';
      case AdminSection.aboutApp:
        return 'عن التطبيق';
    }
  }

  Widget _bodyFor(AdminSection section) {
    switch (section) {
      case AdminSection.userManagement:
        return const UserManagementView();
      case AdminSection.attendanceOverview:
        return const ComingSoonView(
          title: 'إحصائيات الحضور',
          icon: Icons.bar_chart_rounded,
        );
      case AdminSection.systemSettings:
        return const ComingSoonView(
          title: 'إعدادات النظام',
          icon: Icons.settings_rounded,
        );
      case AdminSection.aboutApp:
        return const ComingSoonView(
          title: 'عن التطبيق',
          icon: Icons.info_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = context.watch<AdminDashboardCubit>().state.selectedSection;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D2D3A),
        centerTitle: true,
        title: Text(
          _titleFor(section),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            fontFamily: AppFont.primary,
          ),
        ),
      ),
      drawer: AdminDashboardDrawer(onLogout: () => _handleLogout(context)),
      body: AppBackground(child: SafeArea(child: _bodyFor(section))),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: استدعاء AuthCubit الموجود في feature الـ auth لتنفيذ signOut()
              // ثم الانتقال عبر context.go(AppRoutes.login) — go_router هو
              // المصدر الوحيد للتنقل حسب المبدأ المتبع في المشروع.
            },
            child: const Text('خروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
