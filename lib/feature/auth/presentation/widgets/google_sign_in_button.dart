import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_font.dart';

/// زر تسجيل الدخول / إنشاء حساب عبر Google.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'المتابعة باستخدام Google',
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 52,
  });

  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final double height;

  bool get _isInteractive => !isLoading && !isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: _isInteractive ? onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isDisabled
                    ? AppColors.textSecondary.withOpacity(0.25)
                    : AppColors.textSecondary.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFont.primary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: isDisabled
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
