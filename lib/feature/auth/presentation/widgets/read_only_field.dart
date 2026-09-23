import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:flutter/material.dart';

/// حقل للعرض فقط (بيانات جاهزة من Google) — بنفس الشكل البصري لباقي
/// الحقول، لكن غير قابل للتعديل، ليبقى للمستخدم واضح أن هذه بياناته
/// الحقيقية من حساب Google الذي سجّل به للتو.
class ReadOnlyField extends StatelessWidget {
  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFont.primary,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppFont.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}
