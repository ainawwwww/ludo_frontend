import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    this.coinsLost = 500,
    this.rank = 4,
  });

  final int coinsLost;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Container(
                padding: EdgeInsets.all(24 * scale),
                decoration: BoxDecoration(
                  gradient: AppColors.modalInnerGradient,
                  borderRadius: BorderRadius.circular(32 * scale),
                  border: Border.all(
                    color: const Color(0xFFE31E24),
                    width: 2 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE31E24).withOpacity(0.3),
                      blurRadius: 20 * scale,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Defeat Icon
                    Container(
                      width: 90 * scale,
                      height: 90 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE31E24).withOpacity(0.2),
                        border: Border.all(color: const Color(0xFFE31E24), width: 2 * scale),
                      ),
                      child: Icon(
                        Icons.sentiment_very_dissatisfied_rounded,
                        size: 56 * scale,
                        color: const Color(0xFFE31E24),
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    // Defeat Title
                    Text(
                      'GAME OVER',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: 30 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE31E24),
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'RANK #$rank — BETTER LUCK NEXT TIME!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Coins Lost Summary
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 10 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C073E).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/graphics/icon_coins.png', width: 26 * scale, height: 26 * scale),
                          SizedBox(width: 8 * scale),
                          Text(
                            '- $coinsLost COINS',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE31E24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28 * scale),

                    // Action Buttons
                    OrangeButton(
                      text: 'REMATCH',
                      onPressed: () => context.go(AppConstants.ludoLobbyRoute),
                      width: double.infinity,
                      height: 48 * scale,
                    ),
                    SizedBox(height: 12 * scale),
                    TextButton(
                      onPressed: () => context.go(AppConstants.homeRoute),
                      child: Text(
                        'EXIT TO HOME',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
