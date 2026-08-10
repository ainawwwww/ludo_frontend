import 'dart:math';
import 'package:flutter/material.dart';

class GridBackgroundPainter extends CustomPainter {
  GridBackgroundPainter({
    this.gridSize = 60.0,
    this.sparkleCount = 18,
    this.animationValue = 0.0,
  });

  final double gridSize;
  final int sparkleCount;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGradientBackground(canvas, size);
    _drawGridLines(canvas, size);
    _drawSparkles(canvas, size);
  }

  void _drawGradientBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF5641F8),
        Color(0xFF4A35E0),
        Color(0xFF3C00A5),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cols = (size.width / gridSize).ceil() + 1;
    final rows = (size.height / gridSize).ceil() + 1;

    for (int i = 0; i <= cols; i++) {
      final x = i * gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int j = 0; j <= rows; j++) {
      final y = j * gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final innerPaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i <= cols; i++) {
      final x = i * gridSize + gridSize / 2;
      if (x <= size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), innerPaint);
      }
    }

    for (int j = 0; j <= rows; j++) {
      final y = j * gridSize + gridSize / 2;
      if (y <= size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), innerPaint);
      }
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < sparkleCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final baseRadius = 1.0 + rng.nextDouble() * 1.5;
      final phase = rng.nextDouble() * 2 * pi;
      final pulse = 0.5 + 0.5 * sin(animationValue * 2 * pi + phase);
      final radius = baseRadius * (0.6 + 0.4 * pulse);
      final opacity = (0.3 + 0.7 * pulse).clamp(0.0, 1.0);

      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(x, y), radius, sparklePaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), radius * 0.4, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.gridSize != gridSize;
}

class SplashPatternPainter extends CustomPainter {
  SplashPatternPainter({this.animationValue = 0.0});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGradient(canvas, size);
    _drawDominoPattern(canvas, size);
  }

  void _drawGradient(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 1.2,
      colors: const [Color(0xFF5E17EB), Color(0xFF3D00A5)],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawDominoPattern(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-15 * pi / 180);
    canvas.translate(-size.width / 2, -size.height / 2);

    const tileW = 70.0;
    const tileH = 120.0;
    const gap = 20.0;
    const dotRadius = 5.0;

    final tilePaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..style = PaintingStyle.fill;

    final tileBorderPaint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.fill;

    final dividerPaint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;

    final cols = (size.width * 1.5 / (tileW + gap)).ceil() + 2;
    final rows = (size.height * 1.5 / (tileH + gap)).ceil() + 2;

    final startX = -size.width * 0.3;
    final startY = -size.height * 0.3;

    final rng = Random(99);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = startX + c * (tileW + gap);
        final y = startY + r * (tileH + gap);

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, tileW, tileH),
          const Radius.circular(8),
        );
        canvas.drawRRect(rrect, tilePaint);
        canvas.drawRRect(rrect, tileBorderPaint);

        canvas.drawLine(
          Offset(x + 8, y + tileH / 2),
          Offset(x + tileW - 8, y + tileH / 2),
          dividerPaint,
        );

        final topDots = 1 + rng.nextInt(4);
        _drawDominoDots(canvas, dotPaint, x, y, tileW, tileH / 2, topDots, dotRadius);

        final bottomDots = 1 + rng.nextInt(4);
        _drawDominoDots(canvas, dotPaint, x, y + tileH / 2, tileW, tileH / 2, bottomDots, dotRadius);
      }
    }

    canvas.restore();
  }

  void _drawDominoDots(Canvas canvas, Paint paint, double x, double y,
      double w, double h, int count, double radius) {
    final cx = x + w / 2;
    final cy = y + h / 2;
    final ox = w * 0.25;
    final oy = h * 0.3;

    switch (count) {
      case 1:
        canvas.drawCircle(Offset(cx, cy), radius, paint);
        break;
      case 2:
        canvas.drawCircle(Offset(cx - ox * 0.6, cy - oy * 0.4), radius, paint);
        canvas.drawCircle(Offset(cx + ox * 0.6, cy + oy * 0.4), radius, paint);
        break;
      case 3:
        canvas.drawCircle(Offset(cx, cy), radius, paint);
        canvas.drawCircle(Offset(cx - ox * 0.6, cy - oy * 0.5), radius, paint);
        canvas.drawCircle(Offset(cx + ox * 0.6, cy + oy * 0.5), radius, paint);
        break;
      case 4:
        canvas.drawCircle(Offset(cx - ox * 0.5, cy - oy * 0.4), radius, paint);
        canvas.drawCircle(Offset(cx + ox * 0.5, cy - oy * 0.4), radius, paint);
        canvas.drawCircle(Offset(cx - ox * 0.5, cy + oy * 0.4), radius, paint);
        canvas.drawCircle(Offset(cx + ox * 0.5, cy + oy * 0.4), radius, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant SplashPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
