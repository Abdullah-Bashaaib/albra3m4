import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';

class TeacherInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  final bool last;

  const TeacherInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),

      margin: EdgeInsets.only(bottom: last ? 0 : 12),

      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),

      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,

            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(9),
            ),

            alignment: Alignment.center,

            child: Icon(icon, size: 16, color: AppColors.primaryDark),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),

                Text(
                  value,

                  textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,

                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
