import 'package:flutter/material.dart';
import 'package:albra3m4/core/constants/app_colors.dart';
import '../../domain/entities/student_entity.dart';
import 'student_avatar.dart';
import 'classroom_badge.dart';

class StudentCard extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;
  final int? rankInClass;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    this.rankInClass,
  });

  @override
  Widget build(BuildContext context) {
    final avg = student.overallAverage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // صورة الطالب
            StudentAvatar(initials: student.initials),
            const SizedBox(width: 12),

            // معلومات الطالب
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rankInClass != null && rankInClass! <= 3)
                        _RankEmoji(rank: rankInClass!),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ClassroomBadge(classroom: student.classroom, small: true),
                      const SizedBox(width: 8),
                      Icon(
                        student.gender == StudentGender.male
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                        size: 14,
                        color: student.gender == StudentGender.male
                            ? AppColors.primary
                            : const Color(0xFFEC407A),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // متوسط الدرجات
            if (student.grades.isNotEmpty) _AverageChip(average: avg),
          ],
        ),
      ),
    );
  }
}

class _RankEmoji extends StatelessWidget {
  final int rank;
  const _RankEmoji({required this.rank});

  @override
  Widget build(BuildContext context) {
    final emoji = rank == 1
        ? '🥇'
        : rank == 2
        ? '🥈'
        : '🥉';
    return Text(emoji, style: const TextStyle(fontSize: 16));
  }
}

class _AverageChip extends StatelessWidget {
  final double average;
  const _AverageChip({required this.average});

  @override
  Widget build(BuildContext context) {
    final pct = (average * 100).toStringAsFixed(0);
    Color color;
    if (average >= 0.85) {
      color = const Color(0xFF2E7D32);
    } else if (average >= 0.60) {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
