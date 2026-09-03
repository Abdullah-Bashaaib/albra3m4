import 'dart:ui';

import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/app_drawer.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/presentation/manager/admin_dashboard_cubit.dart'
    show AdminDashboardCubit, AdminSection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_font.dart';
import '../widgets/coming_soon_view.dart';
import '../widgets/user_management/user_management_view.dart';

/// شاشة لوحة تحكم المشرف التقني (Super Admin Dashboard).
/// تعرض Drawer بأقسام النظام، وتبدّل المحتوى حسب القسم المختار عبر
/// [AdminDashboardCubit] دون إعادة بناء الشاشة بالكامل.
class AdminDashboardScreen extends StatelessWidget {
  /// المستخدم الحالي — يُمرَّر من الـ Router عبر `state.extra`
  final UserEntity user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit(),
      child: _AdminDashboardView(user: user),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  final UserEntity user;
  const _AdminDashboardView({required this.user});

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
      drawer: AppDrawer(
        user: user,
        onLogout: () => _handleLogout(context),
        selectedItemKey: _sectionToKey(section),
        onItemSelected: (key) => context
            .read<AdminDashboardCubit>()
            .selectSection(_keyToSection(key)),
      ),
      body: AppBackground(child: SafeArea(child: _bodyFor(section))),
    );
  }

  String _sectionToKey(AdminSection section) {
    switch (section) {
      case AdminSection.userManagement:
        return 'userManagement';
      case AdminSection.attendanceOverview:
        return 'attendanceOverview';
      case AdminSection.systemSettings:
        return 'systemSettings';
      case AdminSection.aboutApp:
        return 'aboutApp';
    }
  }

  AdminSection _keyToSection(String key) {
    switch (key) {
      case 'userManagement':
        return AdminSection.userManagement;
      case 'attendanceOverview':
        return AdminSection.attendanceOverview;
      case 'systemSettings':
        return AdminSection.systemSettings;
      case 'aboutApp':
        return AdminSection.aboutApp;
      default:
        return AdminSection.userManagement;
    }
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
