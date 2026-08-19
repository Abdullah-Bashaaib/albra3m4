import 'package:albra3m4/core/constants/app_font.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final double fontSize;

  bool get _isInteractive => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? AppColors.primary;
    final Color fgColor =
        foregroundColor ??
        (variant == ButtonVariant.filled ? Colors.white : AppColors.primary);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(bgColor, fgColor),
    );
  }

  Widget _buildButton(Color bgColor, Color fgColor) {
    final Widget child = _buildChild(fgColor);

    switch (variant) {
      case ButtonVariant.filled:
        return ElevatedButton(
          onPressed: _isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            disabledBackgroundColor: bgColor.withOpacity(0.5),
            foregroundColor: fgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        );

      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: _isInteractive ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: fgColor,
            disabledForegroundColor: fgColor.withOpacity(0.5),
            side: BorderSide(
              color: _isInteractive ? bgColor : bgColor.withOpacity(0.4),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: _isInteractive ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: fgColor,
            disabledForegroundColor: fgColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        );
    }
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.primary,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 20),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: AppFont.primary,
      ),
    );
  }
}
