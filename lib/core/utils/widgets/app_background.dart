import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // الخلفية
        Image.asset('assets/images/background.jpg', fit: BoxFit.cover),

        // محتوى الصفحة
        child,
      ],
    );
  }
}
