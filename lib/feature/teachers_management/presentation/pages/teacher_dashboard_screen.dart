import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/app_drawer.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/pages/teacher_scanning_q_r.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// داشبورد المعلمة — تعرض حالة حضورها اليوم + ملخص معلوماتها
class TeacherDashboardScreen extends StatelessWidget {
  final UserEntity user;
  const TeacherDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: AppDrawer(user: user, onLogout: () {}),
      body: AppBackground(
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── AppBar ──────────────────────────────────────────
                _buildSliverAppBar(context),

                // ── المحتوى ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── بطاقة الترحيب ── ─────────────────────────
                      _WelcomeCard(user: user),

                      const SizedBox(height: 22),

                      // ── حالة الحضور اليوم ────────────────────────
                      _AttendanceStatusCard(state: state),

                      const SizedBox(height: 22),

                      // ── زر تسجيل الحضور (QR) ────────────────────
                      if (!state.attendanceDone)
                        _ScanAttendanceButton(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AttendanceCubit>(),
                                child: const TeacherScanningQR(),
                              ),
                            ),
                          ),
                        ),

                      if (!state.attendanceDone) const SizedBox(height: 22),

                      // ── معلومات المعلمة ──────────────────────────
                      _SectionTitle(title: 'معلوماتي'),
                      const SizedBox(height: 12),
                      _ProfileCard(user: user),

                      const SizedBox(height: 22),

                      // ── بطاقات سريعة ─────────────────────────────
                      _SectionTitle(title: 'الخدمات'),
                      const SizedBox(height: 12),
                      _QuickActionsGrid(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryDark,
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
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: _DecorCircle(size: 180, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: _DecorCircle(size: 120, opacity: 0.12),
              ),
              Positioned(
                top: 30,
                left: 20,
                child: _DecorCircle(size: 60, opacity: 0.06),
              ),
            ],
          ),
        ),
        title: const Text(
          'لوحة المعلمة',
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
// بطاقة الترحيب
// ──────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final UserEntity user;
  const _WelcomeCard({required this.user});

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
        : '؟';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
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
                    fontSize: 14,
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
                ),
                const SizedBox(height: 2),
                Text(
                  user.role.arabicLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w600,
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
// بطاقة حالة الحضور
// ──────────────────────────────────────────────────────────────

class _AttendanceStatusCard extends StatelessWidget {
  final AttendanceState state;
  const _AttendanceStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool done = state.attendanceDone;
    final String status = state.attendanceTStatus ?? '';
    final bool isLate = status == 'متأخر';

    final Color cardColor = done
        ? (isLate ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9))
        : const Color(0xFFFCE4EC);

    final Color accentColor = done
        ? (isLate ? const Color(0xFFE65100) : const Color(0xFF2E7D32))
        : const Color(0xFFC62828);

    final IconData icon = done
        ? (isLate ? Icons.watch_later_rounded : Icons.check_circle_rounded)
        : Icons.cancel_rounded;

    final String title = done
        ? (isLate ? 'تم التسجيل — متأخرة ⏰' : 'حضور مسجّل ✅')
        : 'لم يتم تسجيل الحضور بعد';

    final String subtitle = done
        ? (isLate
              ? 'لقد سجّلتِ حضورك اليوم بتأخير'
              : 'أحسنتِ! سجّلتِ حضورك في الوقت')
        : 'لا تنسي مسح رمز QR لتسجيل حضورك';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor.withValues(alpha: 0.75),
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
// زر تسجيل الحضور
// ──────────────────────────────────────────────────────────────

class _ScanAttendanceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanAttendanceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تسجيل الحضور',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'امسحي رمز QR لتسجيل حضورك الآن',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// بطاقة المعلومات الشخصية
// ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserEntity user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final details = user.tDetails;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_rounded,
            iconColor: const Color(0xFF1976D2),
            label: 'البريد الإلكتروني',
            value: user.email,
          ),
          if (user.phone != null && user.phone!.isNotEmpty)
            _InfoRow(
              icon: Icons.phone_rounded,
              iconColor: const Color(0xFF2E7D32),
              label: 'رقم الجوال',
              value: user.phone!,
            ),
          if (details != null) ...[
            _InfoRow(
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF6A1B9A),
              label: 'التخصص',
              value: details.specialization,
            ),
            _InfoRow(
              icon: Icons.workspace_premium_rounded,
              iconColor: const Color(0xFFE65100),
              label: 'المؤهل العلمي',
              value: details.academicQualification,
              isLast: true,
            ),
          ] else
            _InfoRow(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.muted,
              label: 'ملاحظة',
              value: 'لا توجد بيانات إضافية',
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.line, height: 1),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// الخدمات السريعة (شبكة)
// ──────────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(
        icon: Icons.calendar_month_rounded,
        label: 'جدولي',
        color: const Color(0xFF1976D2),
        comingSoon: true,
      ),
      _QuickItem(
        icon: Icons.people_rounded,
        label: 'طلابي',
        color: const Color(0xFF2E7D32),
        comingSoon: true,
      ),
      _QuickItem(
        icon: Icons.notifications_rounded,
        label: 'الإشعارات',
        color: const Color(0xFFE65100),
        comingSoon: true,
      ),
      _QuickItem(
        icon: Icons.assignment_rounded,
        label: 'التقارير',
        color: const Color(0xFF6A1B9A),
        comingSoon: true,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.4,
      children: items.map((item) => _QuickActionCard(item: item)).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickItem item;
  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.08),
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
          onTap: item.comingSoon ? null : () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                if (item.comingSoon)
                  Text(
                    'قريباً',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool comingSoon;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.color,
    this.comingSoon = false,
  });
}

// ──────────────────────────────────────────────────────────────
// مساعدات مشتركة
// ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A),
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
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
