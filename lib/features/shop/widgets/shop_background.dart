import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A rich, high-performance custom background matching the purple spotlight gradient
/// with luminous overhead lighting and subtle ambient particle sparks.
class ShopSpotlightBackground extends StatelessWidget {
  final Widget child;

  const ShopSpotlightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Deep purple to midnight base linear gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8E17D8), // Vibrant upper purple
                  Color(0xFF550C9E), // Mid rich violet
                  Color(0xFF2C0558), // Deep purple
                  Color(0xFF150130), // Dark violet
                  Color(0xFF0A001C), // Midnight navy
                ],
                stops: [0.0, 0.22, 0.48, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // 2. Overhead glowing spotlight flare (Radial spotlight at top center)
        Positioned(
          top: -60,
          left: 0,
          right: 0,
          height: 380,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.6),
                radius: 0.85,
                colors: [
                  Color(0xFFFFA6FF), // Brilliant white-pink core
                  Color(0xFFEA54F6), // Neon magenta ring
                  Color(0xFFAC25E6), // Purple dispersion
                  Colors.transparent, // Smooth fade into background
                ],
                stops: [0.0, 0.25, 0.58, 1.0],
              ),
            ),
          ),
        ),

        // 3. Subtle ambient dust / sparkle particle layer
        Positioned.fill(
          child: CustomPaint(
            painter: _SparkleParticlePainter(),
          ),
        ),

        // 4. Foreground Content
        child,
      ],
    );
  }
}

class _SparkleParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random =
        math.Random(42); // Fixed seed for stable sparkle distribution
    final paint = Paint()..style = PaintingStyle.fill;

    const particleCount = 45;
    for (int i = 0; i < particleCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.8 + random.nextDouble() * 1.8;
      final opacity =
          0.15 + (1.0 - (dy / size.height)) * 0.45 * random.nextDouble();

      // Top particles are more pinkish, lower ones softer lavender
      final isPinkish = random.nextBool();
      paint.color =
          (isPinkish ? const Color(0xFFFFB8FF) : const Color(0xFFE2C4FF))
              .withOpacity(opacity.clamp(0.0, 0.7));

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
