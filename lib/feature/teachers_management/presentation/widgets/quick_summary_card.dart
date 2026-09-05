import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class QuickSummaryCard extends StatelessWidget {
  final int teacherCount;
  final int studentCount;
  final double teacherAttendance;
  final double studentAttendance;

  const QuickSummaryCard({super.key, 
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
