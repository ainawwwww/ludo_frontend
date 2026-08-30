import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class FavouriteDiceScreen extends StatelessWidget {
  const FavouriteDiceScreen({super.key});

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
                        'FAVOURITE DICE',
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

                      // Dice Grid
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
                          return _buildDiceItem(index, scale);
                        },
                      ),
                      SizedBox(height: 24 * scale),

                      // Add New Dice Button
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
                              'Unlock More Dice',
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

  Widget _buildDiceItem(int index, double scale) {
    final diceColors = [
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFD369), // Gold
      const Color(0xFFB173FF), // Purple
      const Color(0xFFFF9800), // Orange
    ];

    final diceNames = [
      'Classic Red',
      'Lucky Green',
      'Ocean Blue',
      'Golden Dice',
      'Royal Purple',
      'Fire Orange',
    ];

    final isSelected = index == 0; // First dice is selected

    return Container(
      decoration: BoxDecoration(
        color: diceColors[index].withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD369) : diceColors[index],
          width: isSelected ? 2.5 * scale : 1.5 * scale,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50 * scale,
                  height: 50 * scale,
                  decoration: BoxDecoration(
                    color: diceColors[index],
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: diceColors[index].withOpacity(0.4),
                        blurRadius: 8 * scale,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  diceNames[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10 * scale,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8 * scale,
              right: 8 * scale,
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFFFFD369),
                size: 20 * scale,
              ),
            ),
        ],
      ),
    );
  }
}
