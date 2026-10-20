import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/widgets/app_background.dart';
import '../../../../core/utils/widgets/app_drawer.dart';
import '../../../attendance/presentation/cubit/attendance_cubit.dart';
import '../../../attendance/presentation/pages/attendance_q_r_view.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../teachers_management/presentation/pages/teacher_attendance_screen.dart';
import '../../../teachers_management/presentation/widgets/decorative_circle.dart';
import '../manager/users_cubit.dart';
import '../manager/users_state.dart';
import 'user_management_screen.dart';

/// شاشة لوحة تحكم المشرف التقني (Super Admin Dashboard).
///
/// تصميم متناسق ومطابق لأحدث لوحات التحكم في التطبيق (لوحة المديرة ولوحة المعلمة).
class AdminDashboardScreen extends StatefulWidget {
  final UserEntity user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersCubit>().getAllUsers();
    });
  }

  void _onDrawerItemSelected(String key) {
    switch (key) {
      case 'adminDashboard':
        // نحن هنا بالفعل
        break;
      case 'userManagement':
        _navigateToUserManagement();
        break;
      case 'printQR':
        _navigateToPrintQR();
        break;
      case 'attendanceOverview':
        _navigateToAttendanceOverview();
        break;
      case 'systemSettings':
        _showComingSoonDialog('إعدادات النظام');
        break;
      case 'aboutApp':
        _showAboutAppDialog();
        break;
    }
  }

  void _navigateToUserManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UserManagementScreen(),
      ),
    );
  }

  void _navigateToPrintQR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AttendanceCubit>(),
          child: AttendanceQRView(user: widget.user),
        ),
      ),
    );
  }

  void _navigateToAttendanceOverview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AttendanceCubit>(),
          child: const TeacherAttendanceScreen(),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFF0D47A1)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'هذه الميزة قيد التطوير حالياً، وستكون متاحة في التحديث القادم بمشيئة الله.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_rounded, color: Color(0xFF0D47A1)),
            SizedBox(width: 10),
            Text(
              'عن التطبيق',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نظام إدارة روضة البراعم الذكي',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'منظومة رقمية شاملة لإدارة الحضور، المعلمات، الطلاب والتواصل مع أولياء الأمور.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF0D47A1), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'الإصدار 1.0.0 — بيئة الإنتاج',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'هل تريد بالتأكيد تسجيل الخروج من حساب المشرف التقني؟',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: AppDrawer(
        user: widget.user,
        onLogout: () => _handleLogout(context),
        selectedItemKey: 'adminDashboard',
        onItemSelected: _onDrawerItemSelected,
      ),
      body: AppBackground(
        child: RefreshIndicator(
          color: const Color(0xFF0D47A1),
          onRefresh: () async {
            await context.read<UsersCubit>().getAllUsers();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── 1. بطاقة الترحيب ────────────────────────────────
                    _AdminWelcomeCard(user: widget.user),

                    const SizedBox(height: 26),

                    // ── 2. إحصائيات النظام الشاملة ──────────────────────
                    _SectionTitle(
                      title: 'إحصائيات النظام',
                      trailing: GestureDetector(
                        onTap: _navigateToUserManagement,
                        child: const Row(
                          children: [
                            Text(
                              'تفاصيل أكثر',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFF0D47A1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AdminStatsSection(onViewAll: _navigateToUserManagement),

                    const SizedBox(height: 30),

                    // ── 3. الخدمات والإجراءات السريعة ───────────────────
                    const _SectionTitle(title: 'الخدمات والإجراءات السريعة'),
                    const SizedBox(height: 14),
                    _AdminQuickServicesGrid(
                      onUserManagementTap: _navigateToUserManagement,
                      onPrintQRTap: _navigateToPrintQR,
                      onAttendanceOverviewTap: _navigateToAttendanceOverview,
                      onSettingsTap: () => _showComingSoonDialog('إعدادات النظام'),
                    ),

                    const SizedBox(height: 30),

                    // ── 4. حالة النظام والأمان ──────────────────────────
                    const _SectionTitle(title: 'حالة النظام والأمان'),
                    const SizedBox(height: 14),
                    const _SystemHealthCard(),

                    const SizedBox(height: 30),

                    // ── 5. أحدث المستخدمين المسجلين ─────────────────────
                    _SectionTitle(
                      title: 'أحدث المستخدمين المسجلين',
                      trailing: GestureDetector(
                        onTap: _navigateToUserManagement,
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RecentUsersSection(onViewAll: _navigateToUserManagement),

                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SliverAppBar مخصص للمشرف التقني بتدرج أزرق ملكي داكن ودوائر زخرفية
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0D47A1),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Stack(
            children: [
              Positioned(
                top: -30,
                left: -30,
                child: DecorativeCircle(size: 160, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: DecorativeCircle(size: 120, opacity: 0.12),
              ),
              Positioned(
                top: 25,
                right: 35,
                child: DecorativeCircle(size: 50, opacity: 0.06),
              ),
            ],
          ),
        ),
        title: const Text(
          'لوحة تحكم المشرف',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// بطاقة الترحيب بالمشرف التقني
// ──────────────────────────────────────────────────────────────

class _AdminWelcomeCard extends StatelessWidget {
  final UserEntity user;
  const _AdminWelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير 🌤'
        : hour < 17
            ? 'مساء الخير ☀️'
            : 'مساء النور 🌙';

    final initial = user.fullName.isNotEmpty
        ? user.fullName.trimLeft()[0]
        : 'م';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // الرمز الشخصي للمشرف
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: Color(0xFF0D47A1),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'المشرف التقني — كامل الصلاحيات',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// قسم إحصائيات المستخدمين
// ──────────────────────────────────────────────────────────────

class _AdminStatsSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const _AdminStatsSection({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state is UsersLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
            ),
          );
        }

        final int total = state is UsersLoaded ? state.totalCount : 0;
        final int active = state is UsersLoaded ? state.activeCount : 0;
        final int teachers = state is UsersLoaded ? state.teacherCount : 0;
        final int parents = state is UsersLoaded ? state.parentCount : 0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    label: 'إجمالي المستخدمين',
                    value: '$total',
                    icon: Icons.groups_rounded,
                    gradientColors: const [
                      Color(0xFF1565C0),
                      Color(0xFF42A5F5),
                    ],
                    sublabel: 'في النظام',
                    onTap: onViewAll,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AdminStatCard(
                    label: 'الحسابات النشطة',
                    value: '$active',
                    icon: Icons.verified_user_rounded,
                    gradientColors: const [
                      Color(0xFF2E7D32),
                      Color(0xFF66BB6A),
                    ],
                    sublabel: 'مفعلة',
                    onTap: onViewAll,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    label: 'المعلمات',
                    value: '$teachers',
                    icon: Icons.school_rounded,
                    gradientColors: const [
                      Color(0xFFE65100),
                      Color(0xFFFFB74D),
                    ],
                    sublabel: 'كادر التدريس',
                    onTap: onViewAll,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AdminStatCard(
                    label: 'أولياء الأمور',
                    value: '$parents',
                    icon: Icons.family_restroom_rounded,
                    gradientColors: const [
                      Color(0xFF00838F),
                      Color(0xFF26C6DA),
                    ],
                    sublabel: 'مرتبطون',
                    onTap: onViewAll,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// بطاقة إحصائية مخصصة للمشرف
// ──────────────────────────────────────────────────────────────

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final String? sublabel;
  final VoidCallback? onTap;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  if (sublabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        sublabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// شبكة الخدمات السريعة
// ──────────────────────────────────────────────────────────────

class _AdminQuickServicesGrid extends StatelessWidget {
  final VoidCallback onUserManagementTap;
  final VoidCallback onPrintQRTap;
  final VoidCallback onAttendanceOverviewTap;
  final VoidCallback onSettingsTap;

  const _AdminQuickServicesGrid({
    required this.onUserManagementTap,
    required this.onPrintQRTap,
    required this.onAttendanceOverviewTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      _AdminServiceItem(
        icon: Icons.manage_accounts_rounded,
        label: 'إدارة المستخدمين',
        subtitle: 'الصلاحيات والأدوار',
        color: const Color(0xFF1565C0),
        onTap: onUserManagementTap,
      ),
      _AdminServiceItem(
        icon: Icons.qr_code_2_rounded,
        label: 'باركود الحضور',
        subtitle: 'طباعة رمز QR اليومي',
        color: const Color(0xFF2E7D32),
        onTap: onPrintQRTap,
      ),
      _AdminServiceItem(
        icon: Icons.how_to_reg_rounded,
        label: 'حضور المعلمات',
        subtitle: 'سجلات وتقارير الحضور',
        color: const Color(0xFFE65100),
        onTap: onAttendanceOverviewTap,
      ),
      _AdminServiceItem(
        icon: Icons.tune_rounded,
        label: 'إعدادات النظام',
        subtitle: 'تفضيلات الأمان والنظام',
        color: const Color(0xFF6A1B9A),
        comingSoon: true,
        onTap: onSettingsTap,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: services.map((s) => _AdminServiceCard(service: s)).toList(),
    );
  }
}

class _AdminServiceItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool comingSoon;
  final VoidCallback onTap;

  const _AdminServiceItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.comingSoon = false,
    required this.onTap,
  });
}

class _AdminServiceCard extends StatelessWidget {
  final _AdminServiceItem service;

  const _AdminServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: service.color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: service.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: service.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(service.icon, color: service.color, size: 24),
                    ),
                    if (service.comingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'قريباً',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  service.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// بطاقة حالة النظام والأمان
// ──────────────────────────────────────────────────────────────

class _SystemHealthCard extends StatelessWidget {
  const _SystemHealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خوادم التطبيق نشطة وتعمل بكفاءة',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'الاتصال بقاعدة بيانات Cloud Firestore مباشر ومستقر',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HealthBadge(
                label: 'حالة السيرفر',
                value: 'متصل 🟢',
                color: Color(0xFF2E7D32),
              ),
              _HealthBadge(
                label: 'قاعدة البيانات',
                value: 'متزامنة ☁️',
                color: Color(0xFF1565C0),
              ),
              _HealthBadge(
                label: 'مستوى الأمان',
                value: 'مشدد 🛡️',
                color: Color(0xFF6A1B9A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HealthBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// قسم أحدث المستخدمين المسجلين
// ──────────────────────────────────────────────────────────────

class _RecentUsersSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const _RecentUsersSection({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state is! UsersLoaded || state.users.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'لا يوجد مستخدمون مسجلون حالياً',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
          );
        }

        // عرض أحدث 4 مستخدمين مسجلين
        final recentUsers = state.users.take(4).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ...recentUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                final isLast = index == recentUsers.length - 1;

                final roleColor = switch (user.role) {
                  UserRole.superAdmin => const Color(0xFF6A1B9A),
                  UserRole.manager => const Color(0xFF0D47A1),
                  UserRole.teacher => const Color(0xFFE65100),
                  UserRole.parent => const Color(0xFF00838F),
                };

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: roleColor.withValues(alpha: 0.12),
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName.trimLeft()[0]
                              : '؟',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                          ),
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.arabicLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, color: AppColors.line),
                  ],
                );
              }),
              const Divider(height: 1, color: AppColors.line),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'عرض وإدارة كافة المستخدمين',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${state.totalCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// عنوان القسم بعلامة لونية جانبية
// ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
