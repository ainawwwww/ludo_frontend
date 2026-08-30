import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class RoyalLevelScreen extends StatelessWidget {
  const RoyalLevelScreen({super.key});

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
                        'ROYAL LEVEL',
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

                      // Royal Level Card
                      Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.modalGradient,
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: AppColors.primaryBorder,
                            width: 1.5 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark,
                              blurRadius: 10 * scale,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Royal Level Icon
                            Container(
                              width: 80 * scale,
                              height: 80 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFD369),
                                    const Color(0xFFF97023),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD369)
                                        .withOpacity(0.4),
                                    blurRadius: 15 * scale,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 40 * scale,
                              ),
                            ),
                            SizedBox(height: 16 * scale),

                            Text(
                              'Royal 0',
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 24 * scale,
                                color: const Color(0xFFFFD369),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8 * scale),

                            Text(
                              'Upgrade to unlock exclusive benefits',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12 * scale,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 20 * scale),

                            // Progress Bar
                            Container(
                              height: 8 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C073E),
                                borderRadius: BorderRadius.circular(4 * scale),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.1,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFFD369),
                                        const Color(0xFFF97023),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(4 * scale),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * scale),

                            Text(
                              '10% to Royal 1',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10 * scale,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * scale),

                      // Benefits Section
                      Text(
                        'ROYAL BENEFITS',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          fontSize: 14 * scale,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12 * scale),

                      _buildBenefitItem(
                        icon: Icons.star_rounded,
                        title: 'Exclusive Profile Frame',
                        description: 'Show off your royal status',
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildBenefitItem(
                        icon: Icons.emoji_events_rounded,
                        title: 'Priority Matching',
                        description: 'Get matched faster in games',
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildBenefitItem(
                        icon: Icons.card_giftcard_rounded,
                        title: 'Daily Rewards',
                        description: 'Bonus coins and gifts',
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildBenefitItem(
                        icon: Icons.people_rounded,
                        title: 'VIP Room Access',
                        description: 'Join exclusive VIP rooms',
                        scale: scale,
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

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0C073E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.primaryBorder.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD369).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFFFFD369),
                width: 1.5 * scale,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD369),
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    fontSize: 14 * scale,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11 * scale,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
