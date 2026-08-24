import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة مؤقتة (Placeholder) — تُستبدل لاحقاً بـ Dashboard حسب الدور
/// (role-based navigation — UC-003): /admin, /manager, /teacher, /parent.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          CustomSnackBar.showSuccess(context, 'تم تسجيل الدخول بنجاح');
        }
      },
      child: Scaffold(
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
        ),
      ),
    );
  }
}
