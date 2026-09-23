import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:flutter/material.dart';

class TeacherAttendanceCard extends StatelessWidget {
  final TeacherAttendanceEntity attendance;

  const TeacherAttendanceCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(attendance.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusInfo.color.withValues(alpha: 0.7),
                  statusInfo.color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                attendance.name.isNotEmpty ? attendance.name[0] : '؟',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name + Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                if (attendance.status != 'غائب' &&
                    attendance.timeOfArrival.isNotEmpty &&
                    attendance.timeOfArrival != '0')
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'وصلت: ${attendance.timeOfArrival}',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                if (attendance.status != 'غائب' &&
                    attendance.departureTime!.isNotEmpty &&
                    attendance.departureTime != '0')
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'غادرت: ${attendance.departureTime}',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  )
                else if (attendance.status == 'غائب')
                  Text(
                    'لم يسجل حضوره',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusInfo.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusInfo.icon, size: 14, color: statusInfo.color),
                const SizedBox(width: 5),
                Text(
                  attendance.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusInfo.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'حاضر':
        return _StatusInfo(
          color: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
        );
      case 'متأخر':
        return _StatusInfo(
          color: const Color(0xFFE65100),
          icon: Icons.watch_later_rounded,
        );
      case 'غائب':
      default:
        return _StatusInfo(
          color: const Color(0xFFC62828),
          icon: Icons.cancel_rounded,
        );
    }
  }
}

// ─────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────

class _StatusInfo {
  final Color color;
  final IconData icon;
  const _StatusInfo({required this.color, required this.icon});
}
