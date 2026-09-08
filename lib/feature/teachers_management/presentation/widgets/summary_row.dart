import 'package:albra3m4/feature/attendance/domain/entities/teacher_attendance_entity.dart';
import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final List<TeacherAttendanceEntity> records;

  const SummaryRow({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final present = records.where((r) => r.status == 'حاضر').length;
    final late = records.where((r) => r.status == 'متأخر').length;
    final absent = records.where((r) => r.status == 'غائب').length;

    if (records.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        _SummaryBadge(
          label: 'حاضر',
          count: present,
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 10),
        _SummaryBadge(
          label: 'متأخر',
          count: late,
          color: const Color(0xFFE65100),
        ),
        const SizedBox(width: 10),
        _SummaryBadge(
          label: 'غائب',
          count: absent,
          color: const Color(0xFFC62828),
        ),
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
