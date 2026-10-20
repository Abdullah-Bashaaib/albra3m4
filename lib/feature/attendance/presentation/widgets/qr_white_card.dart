import 'package:flutter/material.dart';

/// بطاقة بيضاء مستديرة بظل خفيف — حاوية مشتركة في صفحة QR
class QrWhiteCard extends StatelessWidget {
  final Widget child;
  const QrWhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
