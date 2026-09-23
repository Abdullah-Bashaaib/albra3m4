import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';

class StatusPill extends StatelessWidget {
  final bool isActive;

  const StatusPill({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : AppColors.dangerBg,

        borderRadius: BorderRadius.circular(999),
      ),

      child: Text(
        isActive ? 'نشطة' : 'غير نشطة',

        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isActive ? AppColors.primaryDark : AppColors.dangerFg,
        ),
      ),
    );
  }
}
