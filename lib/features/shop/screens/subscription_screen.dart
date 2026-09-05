import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 0; // 0 = Knight, 1 = Baron

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                        'VIP MEMBERSHIP PASS',
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

                      // Subscription Crown Graphic Header
                      Container(
                        width: 80 * scale,
                        height: 80 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD369).withOpacity(0.2),
                          border: Border.all(
                              color: const Color(0xFFFFD369), width: 2 * scale),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 52 * scale,
                          color: const Color(0xFFFFD369),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        'CHOOSE YOUR ROYAL RANK',
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16 * scale),

                      // Plan Cards
                      _buildPlanCard(
                        index: 0,
                        title: 'KNIGHT PASS',
                        price: '\$4.99 / Month',
                        color: const Color(0xFF5641F8),
                        perks: const [
                          '2x Daily Bonus Gold Coins',
                          'Knight Silver Profile Frame',
                          'Priority Matchmaking Queue',
                          'Exclusive Voice Room Emotes',
                        ],
                        scale: scale,
                      ),
                      SizedBox(height: 14 * scale),

                      _buildPlanCard(
                        index: 1,
                        title: 'BARON PASS',
                        price: '\$14.99 / Month',
                        color: const Color(0xFFFFD369),
                        badge: 'MOST POPULAR',
                        perks: const [
                          '5x Daily Bonus Gold Coins',
                          'Golden Dragon Animated Profile Frame',
                          'Custom Glowing 3D Dice Skin',
                          'VIP Voice Room Host Privileges',
                          'Zero Match Fees on Tournaments',
                        ],
                        scale: scale,
                      ),
                      SizedBox(height: 24 * scale),

                      // CTA Subscribe button
                      OrangeButton(
                        text: _selectedPlan == 0
                            ? 'SUBSCRIBE KNIGHT PASS'
                            : 'SUBSCRIBE BARON PASS',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Activated ${_selectedPlan == 0 ? "Knight" : "Baron"} Pass!'),
                              backgroundColor: const Color(0xFF56AB2F),
                            ),
                          );
                        },
                        width: double.infinity,
                        height: 50 * scale,
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

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required Color color,
    required List<String> perks,
    required double scale,
    String? badge,
  }) {
    final isSelected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          gradient: AppColors.modalGradient,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 3 * scale : 1 * scale,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 16 * scale,
                spreadRadius: 1 * scale,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color : Colors.white60,
                  size: 24 * scale,
                ),
                SizedBox(width: 10 * scale),
                Text(
                  title,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 16 * scale,
                    color: isSelected ? color : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            const Divider(color: Colors.white24, height: 1),
            SizedBox(height: 12 * scale),
            ...perks.map(
              (perk) => Padding(
                padding: EdgeInsets.only(bottom: 6 * scale),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: color, size: 16 * scale),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        perk,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11 * scale,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
