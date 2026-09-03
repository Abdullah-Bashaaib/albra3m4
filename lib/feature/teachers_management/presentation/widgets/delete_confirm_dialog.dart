import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
// import '../core/app_colors.dart';
// import '../models/teacher.dart';

/// يعرض نافذة تأكيد الحذف ويرجع true إذا أكدت المديرة الحذف
Future<bool> showDeleteTeacherDialog(BuildContext context, UserEntity teacher) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.ink.withOpacity(0.45),
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.delete_outline, color: AppColors.dangerFg, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              'حذف ${teacher.fullName}؟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            const Text(
              'سيتم حذف بيانات المعلمة نهائيًا من النظام ولن تتمكني من التراجع عن هذا الإجراء.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.7),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.line, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('تراجع', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('حذف نهائيًا', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
