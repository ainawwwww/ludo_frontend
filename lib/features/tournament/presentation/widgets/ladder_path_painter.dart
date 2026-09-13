import 'dart:math';
import 'package:flutter/material.dart';

class LadderPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;
  final Color glowColor;

  const LadderPathPainter({
    required this.points,
    this.lineColor = const Color(0xFFFFD54A),
    this.glowColor = const Color(0x66FFD54A),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Draw connecting segments from bottom (Round 1) to top (Round 6)
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      // Smooth S-curve control points
      final midY = (p1.dy + p2.dy) / 2;
      path.cubicTo(
        p1.dx,
        midY,
        p2.dx,
        midY,
        p2.dx,
        p2.dy,
      );

      // Draw dashed glow
      _drawDashedPath(canvas, path, glowPaint, 10, 8);
      // Draw dashed line
      _drawDashedPath(canvas, path, linePaint, 10, 8);

      // Draw directional arrow in middle of curve
      final midPoint = Offset((p1.dx + p2.dx) / 2, midY);
      final angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
      _drawArrow(canvas, midPoint, angle, arrowPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = min(dashWidth, metric.length - distance);
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset center, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(6, 0)
      ..lineTo(-6, -5)
      ..lineTo(-3, 0)
      ..lineTo(-6, 5)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LadderPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.glowColor != glowColor;
  }
}
