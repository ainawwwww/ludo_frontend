import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

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
                        'CHAT ROOM',
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

                      // Create Chat Room Card
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
                            Icon(
                              Icons.chat_bubble_outline,
                              color: const Color(0xFFFFD369),
                              size: 48 * scale,
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Create Chat Room',
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 18 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            Text(
                              'Create your own chat room and invite friends',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12 * scale,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 20 * scale),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14 * scale),
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
                                'CREATE ROOM',
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

                      // Existing Chat Rooms
                      Text(
                        'MY CHAT ROOMS',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          fontSize: 14 * scale,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12 * scale),

                      _buildChatRoomItem(
                        title: 'Ludo Champions',
                        members: '24 members',
                        isActive: true,
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      _buildChatRoomItem(
                        title: 'Dice Masters',
                        members: '18 members',
                        isActive: false,
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

  Widget _buildChatRoomItem({
    required String title,
    required String members,
    required bool isActive,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0C073E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isActive ? const Color(0xFFFFD369) : AppColors.primaryBorder.withOpacity(0.4),
          width: isActive ? 1.5 * scale : 1 * scale,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5641F8),
                  const Color(0xFF36289E),
                ],
              ),
            ),
            child: Icon(
              Icons.chat_rounded,
              color: Colors.white,
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
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: Colors.white60,
                      size: 14 * scale,
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      members,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white60,
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(width: 8 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8 * scale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white60,
            size: 16 * scale,
          ),
        ],
      ),
    );
  }
}
