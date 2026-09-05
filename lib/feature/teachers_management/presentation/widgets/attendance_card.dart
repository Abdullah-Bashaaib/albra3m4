import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/dashboard_attendance_ring.dart';
import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final double teacherAttendance;
  final double studentAttendance;

  /// عند true تُعرض مؤشر تحميل بدل نسبة المعلمات
  final bool isLoadingTeachers;

  const AttendanceCard({
    super.key,
    required this.teacherAttendance,
    required this.studentAttendance,
    this.isLoadingTeachers = false,
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
          // ── حضور المعلمات (حقيقي) ──────────────────
          isLoadingTeachers
              ? SizedBox(
                  width: 120,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF0277BD),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'جارٍ التحميل...',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              : DashboardAttendanceRing(
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
