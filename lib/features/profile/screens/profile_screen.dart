import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';
import 'package:ludo_vibe/shared/widgets/league_rank_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFDCD2FD), // Soft purple background matching mockup
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Banner + Avatar Header
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Dark Purple Patterned Header Banner
                  Container(
                    height: 175 * scale,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D0F64), Color(0xFF4C1895), Color(0xFF5D1CA8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern simulation (diamond grid)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.12,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                              ),
                              itemCount: 30,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Top close 'X' button
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 10 * scale,
                          right: 16 * scale,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: EdgeInsets.all(4 * scale),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 26 * scale,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar & Action Buttons Section
                  Padding(
                    padding: EdgeInsets.only(top: 105 * scale),
                    child: Column(
                      children: [
                        // Row with Cloth icon, Avatar, Edit icon
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40 * scale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left Cloth Button (T-Shirt icon)
                              GestureDetector(
                                onTap: () => showClothMenuPopover(context, ref),
                                child: Container(
                                  width: 44 * scale,
                                  height: 44 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DEFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC7B3FF),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x29000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.checkroom,
                                    color: const Color(0xFFC06BEE),
                                    size: 24 * scale,
                                  ),
                                ),
                              ),

                              SizedBox(width: 20 * scale),

                              // Profile Avatar with Gold Frame
                              AvatarDisplay(
                                avatarIndex: profileState.avatarIndex,
                                size: 96 * scale,
                                borderWidth: 3.5 * scale,
                              ),

                              SizedBox(width: 20 * scale),

                              // Right Edit Button
                              GestureDetector(
                                onTap: () => context.push(AppConstants.editProfileRoute),
                                child: Container(
                                  width: 44 * scale,
                                  height: 44 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DEFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC7B3FF),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x29000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: const Color(0xFFC06BEE),
                                    size: 22 * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12 * scale),

                        // Username & User ID
                        Text(
                          profileState.username,
                          style: TextStyle(
                            fontSize: 19 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 3 * scale),
                        Text(
                          'ID:${profileState.userId}',
                          style: TextStyle(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7565A4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16 * scale),

              // Content Cards Container
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                child: Column(
                  children: [
                    // Level Section Card
                    _buildLevelCard(scale),
                    SizedBox(height: 16 * scale),

                    // Game Section Card
                    _buildGameCard(context, scale),
                    SizedBox(height: 16 * scale),

                    // Achievement Section Card
                    _buildAchievementCard(context, scale),
                    SizedBox(height: 24 * scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Level Card Matching Mockup
  Widget _buildLevelCard(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DEFF),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF260D5C),
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              // Shield Level Badge Icon
              Container(
                width: 28 * scale,
                height: 32 * scale,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B2CBF), Color(0xFF5A189A)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4),
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              // Level Progress Bar
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 14 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBCAAA4).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 30 * scale,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                          ),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                      ),
                    ),
                    Text(
                      '0/5',
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Game Stats Card Matching Mockup
  Widget _buildGameCard(BuildContext context, double scale) {
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
          // Purple Folding Ribbon Header "Game"
          _buildRibbonHeader('Game', scale),
          SizedBox(height: 12 * scale),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            child: Column(
              children: [
                // Total Games & Total %
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                          ),
                          children: const [
                            TextSpan(text: 'Total '),
                            TextSpan(
                              text: '2',
                              style: TextStyle(color: Color(0xFFFF8F00)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                          ),
                          children: const [
                            TextSpan(text: 'Total '),
                            TextSpan(
                              text: '0.0%',
                              style: TextStyle(color: Color(0xFFFF8F00)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16 * scale),

                // League Section
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LeagueRankDialog(initialTab: 0),
                    );
                  },
                  child: Row(
                    children: [
                    Text(
                      'League',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF260D5C),
                      ),
                    ),
                    SizedBox(width: 24 * scale),

                    // Current League
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: const Color(0xFFC06BEE),
                          size: 22 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF260D5C),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 24 * scale),

                    // Highest League
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: const Color(0xFFC06BEE),
                          size: 22 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Highest',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF260D5C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
                SizedBox(height: 8 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Achievement Card Matching Mockup
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
          // Purple Folding Ribbon Header "Achievement"
          _buildRibbonHeader('Achievement', scale),
          SizedBox(height: 10 * scale),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
            child: Column(
              children: [
                // Royal Level Row
                InkWell(
                  onTap: () => context.push(AppConstants.royalLevelRoute),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    child: Row(
                      children: [
                        Text(
                          'Royal Level',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.workspace_premium,
                          color: const Color(0xFF7B1FA2),
                          size: 20 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Royal 0',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7B1FA2),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Icon(
                          Icons.keyboard_double_arrow_right,
                          color: const Color(0xFFB388FF),
                          size: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ),

                // Badges Row
                InkWell(
                  onTap: () => context.push(AppConstants.badgesRoute),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    child: Row(
                      children: [
                        Text(
                          'Badges',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_double_arrow_right,
                          color: const Color(0xFFB388FF),
                          size: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ),

                // My favourite dice Row
                InkWell(
                  onTap: () => context.push(AppConstants.favouriteDiceRoute),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    child: Row(
                      children: [
                        Text(
                          'My favourite dice',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF260D5C),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_double_arrow_right,
                          color: const Color(0xFFB388FF),
                          size: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ribbon Tag Widget matching game theme ribbon style
  Widget _buildRibbonHeader(String title, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15 * scale),
          bottomRight: Radius.circular(15 * scale),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
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

}
