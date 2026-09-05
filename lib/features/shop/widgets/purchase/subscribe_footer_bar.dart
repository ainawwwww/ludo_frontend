import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/purchase_models.dart';

class SubscribeFooterBar extends StatelessWidget {
  const SubscribeFooterBar({
    super.key,
    required this.tier,
    required this.onSubscribe,
    required this.onManageSubscriptions,
    this.scale = 1.0,
  });

  final SubscriptionTierData tier;
  final VoidCallback onSubscribe;
  final VoidCallback onManageSubscriptions;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF140A3C),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2E1B68),
            width: 1.2 * scale,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtitle text: Subscribe to get daily benefits
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Subscribe to get daily benefits',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E8EE6),
              ),
            ),
          ),
          SizedBox(height: 6 * scale),

          // Daily Benefit Chips + Big Orange Subscribe Button Row
          Row(
            children: [
              // 3 Daily Reward Chips (Coins, Diamonds, Chest)
              Expanded(
                child: Row(
                  children: [
                    // Daily Coins Box
                    Expanded(
                      child: _buildRewardBox(
                        iconAsset:
                            'assets/graphics/purchase_screen/common/icon_coin_header.png',
                        fallbackIcon: Icons.monetization_on_rounded,
                        text: tier.dailyCoins,
                        scale: scale,
                      ),
                    ),
                    SizedBox(width: 4 * scale),

                    // Daily Diamonds Box
                    Expanded(
                      child: _buildRewardBox(
                        iconAsset:
                            'assets/graphics/purchase_screen/common/icon_diamond_header.png',
                        fallbackIcon: Icons.diamond_rounded,
                        text: tier.dailyDiamonds,
                        scale: scale,
                      ),
                    ),
                    SizedBox(width: 4 * scale),

                    // Daily Chest Box
                    Expanded(
                      child: _buildRewardBox(
                        iconAsset:
                            'assets/graphics/purchase_screen/gold_tab/icon_reward_preview_chest.png',
                        fallbackIcon: Icons.card_giftcard_rounded,
                        text: '${tier.dailyChests}',
                        scale: scale,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8 * scale),

              // Big Orange Subscribe Button
              GestureDetector(
                onTap: () {
                  SoundService().playButtonClick();
                  onSubscribe();
                },
                child: Container(
                  width: 130 * scale,
                  height: 46 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFF9E00),
                        Color(0xFFFF6200),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(
                      color: const Color(0xFFFFD369),
                      width: 1.2 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6200).withOpacity(0.45),
                        blurRadius: 6 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tier.monthlyPrice,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5 * scale,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Subscribe for a month',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5 * scale),

          // Manage Subscriptions Link
          GestureDetector(
            onTap: () {
              SoundService().playButtonClick();
              onManageSubscriptions();
            },
            child: Text(
              'Manage Subscriptions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B7BC4),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF8B7BC4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBox({
    required String iconAsset,
    required IconData fallbackIcon,
    required String text,
    required double scale,
  }) {
    return Container(
      height: 46 * scale,
      padding: EdgeInsets.symmetric(horizontal: 2 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF221356),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFF4C3596), width: 1.0 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconAsset,
            height: 18 * scale,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              size: 16 * scale,
              color: const Color(0xFFFFD369),
            ),
          ),
          SizedBox(height: 2 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
