import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/constants/app_font.dart';

/// زر تسجيل الدخول / إنشاء حساب عبر Google.
///
/// ملاحظة: هذا الملف مسؤول عن الشكل والسلوك (UI/UX) فقط.
/// الربط الفعلي بـ Google Sign-In (google_sign_in package + Firebase)
/// غير مبرمج بعد في auth_remote_data_source_impl.dart — استدعِ
/// [onPressed] لتنفيذ المنطق لاحقًا (عبر الـ Cubit المناسب).
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
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: _isInteractive ? onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GoogleLogo(size: 20, dimmed: isDisabled),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppFont.primary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: isDisabled
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
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

/// شعار Google بألوانه الرسمية الأربعة، مرسوم بـ CustomPaint
/// بدل الاعتماد على asset خارجي (لا يحتاج إضافة صورة للمشروع).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size, this.dimmed = false});

  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Opacity(
        opacity: dimmed ? 0.4 : 1.0,
        child: CustomPaint(painter: _GoogleLogoPainter()),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double r = s * 0.5;
    final Offset center = Offset(s / 2, s / 2);

    // Blue segment (right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -0.45,
      1.35,
      true,
      paint,
    );

    // Green segment (bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      0.9,
      1.55,
      true,
      paint,
    );

    // Yellow segment (left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      2.45,
      1.35,
      true,
      paint,
    );

    // Red segment (top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.8,
      1.65,
      true,
      paint,
    );

    // White inner circle + horizontal bar to form the "G" shape
    final Paint white = Paint()..color = Colors.white;
    canvas.drawCircle(center, r * 0.62, white);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.16, r * 0.95, r * 0.32),
      white,
    );

    // Blue bar (the crossbar of the G)
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + r * 0.02,
        center.dy - r * 0.16,
        r * 0.55,
        r * 0.32,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
