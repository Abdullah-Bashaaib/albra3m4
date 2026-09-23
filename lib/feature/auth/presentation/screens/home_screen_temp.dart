import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manger/login_cubit.dart';

/// شاشة مؤقتة (Placeholder) — تُستبدل لاحقاً بـ Dashboard حسب الدور
/// (role-based navigation — UC-003): /admin, /manager, /teacher, /parent.
///
/// ملاحظة: تم حذف الـ BlocListener الذي كان يستمع لـ LoginSuccess هنا —
/// لم يكن ممكناً أن يعمل أصلاً لأن هذه الشاشة تُبنى بسبب أن الحالة
/// أصبحت LoginSuccess (وليس نتيجة تغيّر لاحق)، فلا يوجد transition
/// جديد ليلتقطه الـ Listener. رسالة النجاح تُعرض الآن من الشاشة التي
/// اكتشفت النجاح فعلياً (LoginScreen أو CompleteGoogleProfileScreen)
/// قبل التنقّل إلى هنا عبر go_router.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.primary,
              ),
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
              BlocSelector<LoginCubit, LoginState, UserRole>(
                selector: (state) {
                  if (state is LoginSuccess) {
                    return state.user.role;
                  }
                  if (state is AuthAuthenticated) {
                    return state.user.role;
                  }
                  return UserRole.parent;
                  // TODO: return selected state
                },
                builder: (context, userRole) {
                  return Text(
                    '(شاشة مؤقتة — سيتم استبدالها بلوحة التحكم الفعلية\n حسب الدور: ${userRole.name})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFont.primary,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
