import 'package:flutter/material.dart';

class DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const DecorCircle({super.key, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
