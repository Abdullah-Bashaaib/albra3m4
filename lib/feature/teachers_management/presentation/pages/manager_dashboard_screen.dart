import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/app_drawer.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/pages/attendance_q_r_view.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';
import 'package:albra3m4/feature/teachers_management/presentation/pages/teacher_attendance_screen.dart';
import 'package:albra3m4/feature/teachers_management/presentation/pages/teachers_list_screen.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/attendance_card.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/dashboard_stat_card.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/decorative_circle.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/quick_summary_card.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/welcome_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// صفحة داشبورد المديرة — تعرض الإحصائيات الرئيسية للروضة
class ManagerDashboardScreen extends StatefulWidget {
  final UserEntity user;
  const ManagerDashboardScreen({super.key, required this.user});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  // بيانات ثابتة مؤقتة للطلاب
  static const int _demoStudentCount = 87;
  static const double _demoStudentAttendance = 0.78;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().loadTeacherAttendanceByDate(
        DateTime.now(),
      );
    });
  }

  void _onDrawerItemSelected(String key) {
    switch (key) {
      case 'teacherAttendance':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AttendanceCubit>(),
              child: const TeacherAttendanceScreen(),
            ),
          ),
        );
        break;
      case 'teacherList':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AttendanceCubit>(),
              child: const TeachersListScreen(),
            ),
          ),
        );
        break;
      case 'QRTeacher':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AttendanceCubit>(),
              child: AttendanceQRView(user: widget.user),
            ),
          ),
        );
        break;
      case 'managerDashboard':
        // نحن هنا بالفعل — لا شيء
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      drawer: AppDrawer(
        user: widget.user,
        onLogout: () {},
        onItemSelected: _onDrawerItemSelected,
        selectedItemKey: 'managerDashboard',
      ),
      body: AppBackground(
        child: BlocBuilder<TeacherCubit, TeacherState>(
          builder: (context, teacherState) {
            final teacherCount = teacherState.teachers.length;
            final activeTeachers = teacherState.teachers
                .where((t) => t.isActive)
                .length;

            return BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, attendanceState) {
                // ── الحسبة الحقيقية لنسبة الحضور ────────────────
                final attended = attendanceState.teacherAttendanceList
                    .where((r) => r.status == 'حاضر' || r.status == 'متأخر')
                    .length;
                final double teacherAttendanceRatio = teacherCount > 0
                    ? (attended / teacherCount).clamp(0.0, 1.0)
                    : 0.0;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(context),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          WelcomeBanner(),
                          const SizedBox(height: 28),
                          SectionTitle(title: 'الأعداد'),
                          const SizedBox(height: 14),
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
                                  iconBgColor: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                  // sublabel: '$activeTeachers نشطة',
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
                                  iconBgColor: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SectionTitle(title: 'نسب الحضور'),
                          const SizedBox(height: 14),
                          // ── بطاقة نسب الحضور (حقيقية) ───────────
                          AttendanceCard(
                            teacherAttendance: teacherAttendanceRatio,
                            studentAttendance: _demoStudentAttendance,
                            isLoadingTeachers:
                                attendanceState.isLoadingAttendanceList,
                          ),
                          const SizedBox(height: 28),
                          // ── ملخص سريع (حقيقي) ───────────────────
                          QuickSummaryCard(
                            teacherActiveCount: activeTeachers,
                            studentCount: _demoStudentCount,
                            teacherAttendance: teacherAttendanceRatio,
                            studentAttendance: _demoStudentAttendance,
                          ),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                );
              },
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
                child: DecorativeCircle(size: 160, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: DecorativeCircle(size: 120, opacity: 0.12),
              ),
            ],
          ),
        ),
        title: const Text(
          'لوحة التحكم',
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
