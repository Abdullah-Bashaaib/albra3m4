import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ويدجت حلقة دائرية تعرض نسبة الحضور مع رسوم متحركة
class DashboardAttendanceRing extends StatefulWidget {
  final double percentage; // 0.0 → 1.0
  final Color ringColor;
  final Color trackColor;
  final String label;
  final double size;

  const DashboardAttendanceRing({
    super.key,
    required this.percentage,
    required this.ringColor,
    required this.trackColor,
    required this.label,
    this.size = 110,
  });

  @override
  State<DashboardAttendanceRing> createState() =>
      _DashboardAttendanceRingState();
}

class _DashboardAttendanceRingState extends State<DashboardAttendanceRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final pct = _animation.value;
        return Column(
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _RingPainter(
                  percentage: pct,
                  ringColor: widget.ringColor,
                  trackColor: widget.trackColor,
                ),
                child: Center(
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: widget.ringColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color ringColor;
  final Color trackColor;

  _RingPainter({
    required this.percentage,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percentage != percentage ||
      old.ringColor != ringColor ||
      old.trackColor != trackColor;
}
