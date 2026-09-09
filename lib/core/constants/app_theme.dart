import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font.dart';

/// ثيم موحّد لكافة شاشات ومكونات التطبيق يعتمد خط [AppFont.primary] ('Somar')
/// مصدراً وحيداً وشاملاً لكافة النصوص والأزرار والحوارات والقوائم.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppFont.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
    );

    final unifiedTextTheme = base.textTheme.apply(
      fontFamily: AppFont.primary,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final unifiedPrimaryTextTheme = base.primaryTextTheme.apply(
      fontFamily: AppFont.primary,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      textTheme: unifiedTextTheme,
      primaryTextTheme: unifiedPrimaryTextTheme,
      typography: Typography.material2021(
        platform: TargetPlatform.android,
        black: Typography.material2021().black.apply(fontFamily: AppFont.primary),
        white: Typography.material2021().white.apply(fontFamily: AppFont.primary),
        englishLike: Typography.material2021().englishLike.apply(fontFamily: AppFont.primary),
        dense: Typography.material2021().dense.apply(fontFamily: AppFont.primary),
        tall: Typography.material2021().tall.apply(fontFamily: AppFont.primary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      dialogTheme: const DialogThemeData(
        titleTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFDFCF8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFont.primary,
          color: AppColors.textHint,
          fontSize: 13.5,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppFont.primary,
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFont.primary,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFont.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: AppFont.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 13.5,
          color: Colors.white,
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: const TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: AppFont.primary,
          fontSize: 12,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
