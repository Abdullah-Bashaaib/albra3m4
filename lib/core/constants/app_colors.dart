import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const Color primary = Color(0xFF4FC3F7); // light blue
  static const Color primaryLight = Color(0xFFE1F5FE); // pale blue bg
  static const Color primaryDark = Color(0xFF0277BD); // deep blue text

  // Accent
  static const Color apricot = Color(0xFFFFB74D); // warm amber/apricot

  // Background & Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cream = Color(0xFFFDFCF8); // warm off-white
  static const Color card = Color(0xFFFFFFFF); // card background

  // Text
  static const Color ink = Color(0xFF1A1A2E); // near-black main text
  static const Color muted = Color(0xFF8E8E9A); // secondary/hint text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Borders & Dividers
  static const Color line = Color(0xFFEAEAF0); // subtle separator
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);

  // Danger (delete / destructive actions)
  static const Color danger = Color(0xFFE53935); // solid red button
  static const Color dangerBg = Color(0xFFFFEBEE); // light red background
  static const Color dangerFg = Color(0xFFB71C1C); // dark red text/icon
}
