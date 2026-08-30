import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class SupportedRoomScreen extends StatelessWidget {
  const SupportedRoomScreen({super.key});

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
                        'SUPPORTED ROOMS',
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

                      // No Supported Rooms State
                      Container(
                        padding: EdgeInsets.all(40 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C073E).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: AppColors.primaryBorder.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              color: Colors.white30,
                              size: 64 * scale,
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              'No Supported Rooms',
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 18 * scale,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            Text(
                              'You haven\'t supported any rooms yet',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12 * scale,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 24 * scale),
                            Container(
                              width: double.infinity,
                              padding:
                                  EdgeInsets.symmetric(vertical: 14 * scale),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFD369),
                                    const Color(0xFFF97023),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Text(
                                'EXPLORE ROOMS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14 * scale,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * scale),

                      // How It Works Section
                      Text(
                        'HOW IT WORKS',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          fontSize: 14 * scale,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12 * scale),

                      _buildInfoItem(
                        icon: Icons.search_rounded,
                        title: 'Find Rooms',
                        description: 'Browse and discover chat rooms',
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildInfoItem(
                        icon: Icons.favorite_rounded,
                        title: 'Support Rooms',
                        description: 'Support your favorite rooms',
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildInfoItem(
                        icon: Icons.star_rounded,
                        title: 'Get Benefits',
                        description: 'Unlock exclusive perks and rewards',
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

  Widget _buildInfoItem({
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
