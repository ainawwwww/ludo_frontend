import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header Bar with Back Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'BADGES',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 12 * scale),

                      // Badges Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12 * scale,
                          mainAxisSpacing: 12 * scale,
                          childAspectRatio: 1,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildBadgeItem(index, scale);
                        },
                      ),
                      SizedBox(height: 24 * scale),

                      // Add New Badge Button
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.modalGradient,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color: AppColors.primaryBorder,
                            width: 1.5 * scale,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFFFFD369),
                              size: 24 * scale,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Unlock More Badges',
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                fontSize: 14 * scale,
                                color: const Color(0xFFFFD369),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeItem(int index, double scale) {
    final badgeColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFF97023), // Orange
      const Color(0xFFB173FF), // Purple
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4CAF50), // Green
    ];

    final badgeIcons = [
      Icons.military_tech_rounded,
      Icons.casino_rounded,
      Icons.mic_rounded,
      Icons.diamond_rounded,
      Icons.emoji_events_rounded,
      Icons.star_rounded,
    ];

    final badgeNames = [
      'Champion',
      'Dice Master',
      'Voice Host',
      'Rich Roller',
      'Winner',
      'Star Player',
    ];

    final isUnlocked = index < 3; // First 3 badges are unlocked

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked 
            ? badgeColors[index].withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isUnlocked ? badgeColors[index] : Colors.grey,
          width: isUnlocked ? 1.5 * scale : 1 * scale,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? badgeIcons[index] : Icons.lock_outline,
            color: isUnlocked ? badgeColors[index] : Colors.grey,
            size: 32 * scale,
          ),
          SizedBox(height: 8 * scale),
          Text(
            badgeNames[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10 * scale,
              color: isUnlocked ? Colors.white70 : Colors.grey,
              fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
