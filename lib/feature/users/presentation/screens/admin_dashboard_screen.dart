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

    // ScrollConfiguration يطبّق _AdminScrollBehavior على كل الشجرة تحته —
    // يعني أي ListView/SingleChildScrollView جوّه الشاشة (قائمة المستخدمين،
    // صف الإحصائيات الأفقي، وحتى قائمة الـ Drawer) ياخذ نفس فيزياء
    // التمرير وشكل الـ Scrollbar تلقائياً، بدون تكرار الإعداد بكل widget.
    return ScrollConfiguration(
      behavior: _AdminScrollBehavior(),
      child: Scaffold(
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
      ),
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

/// ScrollBehavior مخصص للوحة تحكم المشرف:
/// - فيزياء Bouncing تعطي إحساس تمرير أكثر انسيابية (زي iOS) بدل القطع الافتراضي.
/// - Scrollbar دائم الظهور (thumbVisibility) وأسمك وبحواف دائرية، ليكون
///   واضح للعين إن فيه محتوى إضافي تحت/فوق بدل ما يعتمد المستخدم على
///   السحب العشوائي ليكتشف إن القائمة قابلة للتمرير.
/// - يدعم سحب الماوس/التراك باد أيضاً (مفيد لو التطبيق يشتغل على الويب/ديسكتوب).
class _AdminScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 5,
      radius: const Radius.circular(12),
      child: child,
    );
  }
}
