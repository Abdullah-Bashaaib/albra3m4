import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final _SnackBarStyle style = _resolveStyle(type);

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: style.backgroundColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Icon(style.icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    fontFamily: AppFont.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }

  /// اختصار لرسائل النجاح — مثال: "تم تسجيل حضورك بنجاح ✅"
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  /// اختصار لرسائل الخطأ — مثال: مباشرة من Failure.message عبر BlocListener
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  static _SnackBarStyle _resolveStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarStyle(
          backgroundColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return _SnackBarStyle(
          backgroundColor: const Color(0xFFD32F2F),
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return _SnackBarStyle(
          backgroundColor: const Color(0xFFF57C00),
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
        return _SnackBarStyle(
          backgroundColor: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarStyle {
  const _SnackBarStyle({required this.backgroundColor, required this.icon});

  final Color backgroundColor;
  final IconData icon;
}
