import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/app_drawer.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/dashboard_attendance_ring.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/dashboard_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_font.dart';

/// صفحة داشبورد المديرة — تعرض الإحصائيات الرئيسية للروضة
class ManagerDashboardScreen extends StatelessWidget {
  final UserEntity user;
  const ManagerDashboardScreen({super.key, required this.user});

  // ──────────────────────────────────────────────────
  // بيانات ثابتة مؤقتة للطلاب (استبدليها بـ Cubit لاحقًا)
  // ──────────────────────────────────────────────────
  static const int _demoStudentCount = 87;
  static const double _demoTeacherAttendance = 0.92; // 92 %
  static const double _demoStudentAttendance = 0.78; // 78 %

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: AppDrawer(user: user, onLogout: () {}),
      body: AppBackground(
        child: BlocBuilder<TeacherCubit, TeacherState>(
          builder: (context, state) {
            final teacherCount = state.teachers.length;
            final activeTeachers = state.teachers
                .where((t) => t.isActive)
                .length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── AppBar ──────────────────────────────────────────
                _buildSliverAppBar(context),

                // ── محتوى الصفحة ────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── رسالة ترحيب ──────────────────────────────
                      _WelcomeBanner(),

                      const SizedBox(height: 28),

                      // ── عنوان قسم ────────────────────────────────
                      _SectionTitle(title: 'الأعداد'),

                      const SizedBox(height: 14),

                      // ── بطاقتا العدد (معلمات / طلاب) ─────────────
                      Row(
                        children: [
                          Expanded(
                            child: DashboardStatCard(
                              label: 'عدد المعلمات',
                              value: '$teacherCount',
                              icon: Icons.school_rounded,
                              gradientColors: const [
                                Color(0xFF4FC3F7),
                                Color(0xFF0277BD),
                              ],
                              iconBgColor: Colors.white.withValues(alpha: 0.25),
                              sublabel: '$activeTeachers نشطة',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DashboardStatCard(
                              label: 'عدد الطلاب',
                              value: '$_demoStudentCount',
                              icon: Icons.child_care_rounded,
                              gradientColors: const [
                                Color(0xFFFFB74D),
                                Color(0xFFE65100),
                              ],
                              iconBgColor: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── عنوان قسم الحضور ──────────────────────────
                      _SectionTitle(title: 'نسب الحضور'),

                      const SizedBox(height: 14),

                      // ── بطاقة نسب الحضور ──────────────────────────
                      _AttendanceCard(
                        teacherAttendance: _demoTeacherAttendance,
                        studentAttendance: _demoStudentAttendance,
                      ),

                      const SizedBox(height: 28),

                      // ── بطاقة ملخص سريع ───────────────────────────
                      _QuickSummaryCard(
                        teacherCount: teacherCount,
                        studentCount: _demoStudentCount,
                        teacherAttendance: _demoTeacherAttendance,
                        studentAttendance: _demoStudentAttendance,
                      ),
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

  /// SliverAppBar مخصص بتصميم متدرج
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // دوائر زخرفية
              Positioned(
                top: -30,
                left: -30,
                child: _DecorativeCircle(size: 160, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: _DecorativeCircle(size: 120, opacity: 0.12),
              ),
            ],
          ),
        ),
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontFamily: AppFont.primary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ويدجات داخلية خاصة بالصفحة
// ──────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير 🌤'
        : hour < 17
        ? 'مساء الخير ☀️'
        : 'مساء النور 🌙';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
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
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'إليكِ ملخص اليوم لروضتكِ',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: AppColors.primary,
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

/// بطاقة خاصة بنسب الحضور مع حلقتين
class _AttendanceCard extends StatelessWidget {
  final double teacherAttendance;
  final double studentAttendance;

  const _AttendanceCard({
    required this.teacherAttendance,
    required this.studentAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DashboardAttendanceRing(
            percentage: teacherAttendance,
            ringColor: const Color(0xFF0277BD),
            trackColor: const Color(0xFFE1F5FE),
            label: 'حضور المعلمات',
            size: 120,
          ),

          // خط فاصل عمودي
          Container(width: 1, height: 100, color: AppColors.line),

          DashboardAttendanceRing(
            percentage: studentAttendance,
            ringColor: const Color(0xFFE65100),
            trackColor: const Color(0xFFFFF3E0),
            label: 'حضور الطلاب',
            size: 120,
          ),
        ],
      ),
    );
  }
}

/// بطاقة ملخص سريع بالأرقام والنسب
class _QuickSummaryCard extends StatelessWidget {
  final int teacherCount;
  final int studentCount;
  final double teacherAttendance;
  final double studentAttendance;

  const _QuickSummaryCard({
    required this.teacherCount,
    required this.studentCount,
    required this.teacherAttendance,
    required this.studentAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊  ملخص سريع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.school_rounded,
            iconColor: AppColors.primary,
            label: 'إجمالي المعلمات',
            value: '$teacherCount معلمة',
          ),
          _SummaryRow(
            icon: Icons.child_care_rounded,
            iconColor: AppColors.apricot,
            label: 'إجمالي الطلاب',
            value: '$studentCount طالب',
          ),
          _SummaryRow(
            icon: Icons.how_to_reg_rounded,
            iconColor: const Color(0xFF66BB6A),
            label: 'حضور المعلمات اليوم',
            value: '${(teacherAttendance * 100).toStringAsFixed(0)}%',
          ),
          _SummaryRow(
            icon: Icons.emoji_people_rounded,
            iconColor: const Color(0xFFFFB74D),
            label: 'حضور الطلاب اليوم',
            value: '${(studentAttendance * 100).toStringAsFixed(0)}%',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
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
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

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
