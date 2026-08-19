import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const Color primary = Colors.lightBlueAccent;

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);

  // Border / Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
}
