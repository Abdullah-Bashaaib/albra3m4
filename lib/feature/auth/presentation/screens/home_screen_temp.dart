import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:flutter/material.dart';

/// شاشة مؤقتة (Placeholder) — تُستبدل لاحقاً بـ Dashboard حسب الدور
/// (role-based navigation — UC-003): /admin, /manager, /teacher, /parent.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'تم تسجيل الدخول بنجاح ✅',
              style: TextStyle(
                fontFamily: AppFont.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(شاشة مؤقتة — سيتم استبدالها بلوحة التحكم الفعلية حسب الدور)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFont.primary,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}