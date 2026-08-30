import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor:
          const Color(0xFFDCD2FD), // Light lavender matching mockup
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Arrow and Title
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale, vertical: 12 * scale),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: const Color(0xFF260D5C),
                      size: 22 * scale,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF260D5C),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: 18 * scale, vertical: 8 * scale),
                child: Column(
                  children: [
                    // Card 1: Achievement Section (matching iPhone 16 - 108)
                    _buildAchievementCard(context, scale),
                    SizedBox(height: 16 * scale),

                    // Card 2: Social Section (matching iPhone 16 - 108)
                    _buildSocialCard(context, scale),
                    SizedBox(height: 24 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Folded Purple Ribbon Header "Achievement" Section
  Widget _buildAchievementCard(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8DEFF),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purple Ribbon Tag
          _buildRibbonHeader('Achievement', scale),
          SizedBox(height: 8 * scale),

          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 4 * scale),
            child: Column(
              children: [
                // Royal Level
                _buildSettingRow(
                  title: 'Royal Level',
                  rightWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: const Color(0xFF7B1FA2),
                        size: 18 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Royal 0',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                  scale: scale,
                  onTap: () => context.push(AppConstants.royalLevelRoute),
                ),
                _buildDivider(),

                // Badges
                _buildSettingRow(
                  title: 'Badges',
                  rightWidget: _buildPlusSlots(3, scale),
                  scale: scale,
                  onTap: () => context.push(AppConstants.badgesRoute),
                ),
                _buildDivider(),

                // My favourite dice
                _buildSettingRow(
                  title: 'My favourite dice',
                  rightWidget: _buildPlusSlots(3, scale),
                  scale: scale,
                  onTap: () => context.push(AppConstants.favouriteDiceRoute),
                ),
                _buildDivider(),

                // Name Plates
                _buildSettingRow(
                  title: 'Name Plates',
                  rightWidget: _buildPlusSlots(1, scale),
                  scale: scale,
                  onTap: () => context.push(AppConstants.namePlatesRoute),
                ),
                _buildDivider(),

                // Gifts
                _buildSettingRow(
                  title: 'Gifts',
                  rightWidget: _buildPlusSlots(3, scale),
                  scale: scale,
                  onTap: () => context.push(AppConstants.giftsRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Folded Purple Ribbon Header "Social" Section
  Widget _buildSocialCard(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8DEFF),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purple Ribbon Tag
          _buildRibbonHeader('Social', scale),
          SizedBox(height: 8 * scale),

          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 4 * scale),
            child: Column(
              children: [
                // Chat Room
                _buildSettingRow(
                  title: 'Chat Room',
                  rightWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: const Color(0xFF7565A4),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      _buildPlusCircle(scale),
                    ],
                  ),
                  scale: scale,
                  onTap: () => context.push(AppConstants.chatRoomRoute),
                ),
                _buildDivider(),

                // Supported Room
                _buildSettingRow(
                  title: 'Supported Room',
                  rightWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Not Set',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: const Color(0xFF7565A4),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      _buildPlusCircle(scale),
                    ],
                  ),
                  scale: scale,
                  onTap: () => context.push(AppConstants.supportedRoomRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRibbonHeader(String title, double scale) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15 * scale),
          bottomRight: Radius.circular(15 * scale),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required Widget rightWidget,
    required double scale,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF260D5C),
              ),
            ),
            const Spacer(),
            rightWidget,
            SizedBox(width: 8 * scale),
            Icon(
              Icons.keyboard_arrow_right,
              color: const Color(0xFFB388FF),
              size: 20 * scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusSlots(int count, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          count,
          (index) => Padding(
                padding: EdgeInsets.only(left: 6 * scale),
                child: _buildPlusCircle(scale),
              )),
    );
  }

  Widget _buildPlusCircle(double scale) {
    return Container(
      width: 22 * scale,
      height: 22 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD6C7FF),
        border: Border.all(color: const Color(0xFFB388FF), width: 1),
      ),
      child: Icon(
        Icons.add,
        color: const Color(0xFF7C4DFF),
        size: 14 * scale,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFDCD2FD),
      height: 1,
    );
  }
}
