import 'package:flutter/material.dart';
import 'package:albra3m4/core/constants/app_colors.dart';
import '../../domain/entities/student_entity.dart';

class ClassroomBadge extends StatelessWidget {
  final KindergartenClass classroom;
  final bool small;

  const ClassroomBadge({
    super.key,
    required this.classroom,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color(classroom);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        classroom.shortLabel,
        style: TextStyle(
          fontSize: small ? 10 : 11.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Color _color(KindergartenClass cls) {
    switch (cls) {
      case KindergartenClass.kg1:
        return const Color(0xFF26A69A); // teal
      case KindergartenClass.kg2:
        return AppColors.primary; // blue
      case KindergartenClass.kg3:
        return const Color(0xFF7E57C2); // purple
    }
  }
}
