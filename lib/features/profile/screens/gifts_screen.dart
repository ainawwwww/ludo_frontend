import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

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
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'GIFTS',
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

                      // Gifts Grid
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
                          return _buildGiftItem(index, scale);
                        },
                      ),
                      SizedBox(height: 24 * scale),

                      // Add New Gift Button
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
                              'Unlock More Gifts',
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

  Widget _buildGiftItem(int index, double scale) {
    final giftIcons = [
      Icons.card_giftcard_rounded,
      Icons.favorite_rounded,
      Icons.celebration_rounded,
      Icons.star_rounded,
      Icons.emoji_emotions_rounded,
      Icons.local_florist_rounded,
    ];

    final giftNames = [
      'Gift Box',
      'Heart',
      'Party',
      'Star',
      'Smile',
      'Flower',
    ];

    final giftColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFE91E63),
      const Color(0xFFFFD369),
      const Color(0xFFFFD700),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
    ];

    final isUnlocked = index < 4; // First 4 gifts are unlocked

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? giftColors[index].withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isUnlocked ? giftColors[index] : Colors.grey,
          width: isUnlocked ? 1.5 * scale : 1 * scale,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? giftIcons[index] : Icons.lock_outline,
            color: isUnlocked ? giftColors[index] : Colors.grey,
            size: 32 * scale,
          ),
          SizedBox(height: 8 * scale),
          Text(
            giftNames[index],
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
