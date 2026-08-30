import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class WelcomePopup extends StatelessWidget {
  const WelcomePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Container(
        width: double.infinity,
        height: 210 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5641F8),
              Color(0xFF7B4BCD),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2.0 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5641F8).withOpacity(0.5),
              blurRadius: 24 * scale,
              spreadRadius: 4 * scale,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22 * scale),
          child: Stack(
            children: [
              // Sparkle particles behind
              Positioned(
                top: 15 * scale,
                right: 25 * scale,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white24,
                  size: 24 * scale,
                ),
              ),
              Positioned(
                bottom: 25 * scale,
                left: 140 * scale,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white12,
                  size: 16 * scale,
                ),
              ),
              // Main content row
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 16 * scale),
                child: Row(
                  children: [
                    // LEFT: Mascot or premium placeholder unicorn
                    _MascotSection(scale: scale),
                    SizedBox(width: 16 * scale),
                    // RIGHT: Column with text and button
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to the ludo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          Text(
                            'Have you ever played Ludo?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 14 * scale),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97023),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFFC24906),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24 * scale,
                                vertical: 10 * scale,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50 * scale),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "I'm Expert",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MascotSection extends StatelessWidget {
  const _MascotSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100 * scale,
      child: CircleAvatar(
        radius: 50 * scale,
        backgroundColor: const Color(0xFF3D2DB5),
        child: Icon(
          Icons.sports_esports,
          size: 40 * scale,
          color: Colors.white,
        ),
      ),
    );
  }
}
