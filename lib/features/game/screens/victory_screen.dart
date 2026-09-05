import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({
    super.key,
    this.coinsWon = 2000,
    this.matchDuration = '04:45',
  });

  final int coinsWon;
  final String matchDuration;

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
                  gradient: AppColors.modalGradient,
                  borderRadius: BorderRadius.circular(32 * scale),
                  border: Border.all(
                    color: const Color(0xFFFFD369),
                    width: 3 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD369).withOpacity(0.4),
                      blurRadius: 24 * scale,
                      spreadRadius: 2 * scale,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy Icon Container
                    Container(
                      width: 100 * scale,
                      height: 100 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD369).withOpacity(0.2),
                        border: Border.all(
                            color: const Color(0xFFFFD369), width: 3 * scale),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 64 * scale,
                        color: const Color(0xFFFFD369),
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    // Victory Title
                    Text(
                      'VICTORY!',
                      style: AppTextStyles.headingLarge.copyWith(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(
                            color: Color(0xFFC24906),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'CONGRATULATIONS! YOU WON THE MATCH!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Coins Won Reward Card
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C073E).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(
                            color: const Color(0xFFFFD369).withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/graphics/icon_coins.png',
                              width: 32 * scale, height: 32 * scale),
                          SizedBox(width: 10 * scale),
                          Text(
                            '+ $coinsWon',
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),

                    // Stats summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVictoryStat('TIME', matchDuration, scale),
                        _buildVictoryStat('TOKENS', '4/4', scale),
                        _buildVictoryStat('KILLS', '3', scale),
                      ],
                    ),
                    SizedBox(height: 28 * scale),

                    // Action Buttons
                    OrangeButton(
                      text: 'PLAY AGAIN',
                      onPressed: () => context.go(AppConstants.ludoLobbyRoute),
                      width: double.infinity,
                      height: 48 * scale,
                    ),
                    SizedBox(height: 12 * scale),
                    TextButton(
                      onPressed: () => context.go(AppConstants.homeRoute),
                      child: Text(
                        'BACK TO HOME',
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

  Widget _buildVictoryStat(String label, String value, double scale) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10 * scale,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
