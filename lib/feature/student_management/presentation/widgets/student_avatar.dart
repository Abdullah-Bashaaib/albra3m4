import 'package:flutter/material.dart';
import 'package:albra3m4/core/constants/app_colors.dart';

class StudentAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const StudentAvatar({super.key, required this.initials, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.apricot, Color(0xFFE65100)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.apricot.withValues(alpha: 0.32),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
