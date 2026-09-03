import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';

class TeacherInfoCard extends StatelessWidget {
  final List<Widget> children;

  const TeacherInfoCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),

      child: Column(children: children),
    );
  }
}
