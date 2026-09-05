import 'package:flutter/material.dart';

class DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const DecorativeCircle({super.key, required this.size, required this.opacity});

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
