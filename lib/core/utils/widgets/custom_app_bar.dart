import 'dart:ui';

import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? action;

  const CustomAppBar(this.title, {super.key, this.action});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.black.withAlpha(200),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: AppFont.primary,
            ),
          ),
          actions: action,
        ),
      ),
    );
  }
}
