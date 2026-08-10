import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  Timer? _timer;
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showLogin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Splash background pattern image
          Image.asset(
            'assets/graphics/bg_splash.png',
            fit: BoxFit.cover,
          ),
          
          if (!_showLogin) ...[
            // Connecting spinner and tip text at the bottom area
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _loadingController,
                        child: CustomPaint(
                          size: Size(32 * scale, 32 * scale),
                          painter: const _DashedCirclePainter(),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Text(
                        'Connecting',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                    child: Text(
                      'Tip: If Your microphone is not working, check the microphone setting in the phone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFCCA3FF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Login panel containing Bind with Apple, Facebook, Email and Guest options!
            Center(
              child: Container(
                width: 310 * scale,
                padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 20 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF160A4F).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24 * scale),
                  border: Border.all(color: const Color(0xFF8C7DF5).withOpacity(0.5), width: 1.5 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20 * scale,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BIND ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    
                    // Bind with Apple Button
                    _buildLoginButton(
                      label: 'Bind with Apple',
                      icon: Icons.apple,
                      color: Colors.black.withOpacity(0.9),
                      borderColor: Colors.white24,
                      scale: scale,
                      onTap: () => context.go(AppConstants.homeRoute),
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Bind with Facebook Button
                    _buildLoginButton(
                      label: 'Bind with Facebook',
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      scale: scale,
                      onTap: () => context.go(AppConstants.homeRoute),
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Bind with Email Button
                    _buildLoginButton(
                      label: 'Bind with Email',
                      icon: Icons.email_rounded,
                      color: const Color(0xFF4C3EC8),
                      borderColor: const Color(0xFF8C7DF5),
                      scale: scale,
                      onTap: () => context.go(AppConstants.homeRoute),
                    ),
                    SizedBox(height: 24 * scale),
                    
                    // Enter as Guest Option
                    GestureDetector(
                      onTap: () {
                        context.go(AppConstants.homeRoute);
                      },
                      child: Text(
                        'Enter as Guest',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCCA3FF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required Color color,
    Color? borderColor,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48 * scale,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24 * scale),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5 * scale) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8 * scale,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22 * scale),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const dashCount = 10;
    const gapAngle = pi / 12;
    const sweepAngle = (2 * pi - dashCount * gapAngle) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (sweepAngle + gapAngle) - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
