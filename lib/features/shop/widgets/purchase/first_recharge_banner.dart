import 'package:flutter/material.dart';

class FirstRechargeBanner extends StatelessWidget {
  const FirstRechargeBanner({
    super.key,
    this.scale = 1.0,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Title
          Text(
            'First Reward Recharge',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 6 * scale),

          // 3D Lavender Shelf Banner with Chest on Left & 3 Slots inside White Bubble
          SizedBox(
            height: 98 * scale,
            child: Stack(
              children: [
                // Shelf & Chest Background
                Positioned.fill(
                  child: Image.asset(
                    'assets/graphics/purchase_screen/gold_tab/banner_chest_bubble_bg.png',
                    fit: BoxFit.fill,
                  ),
                ),

                // 3 Reward items positioned strictly inside the right white bubble (left offset 125 * scale)
                Positioned(
                  left: 124 * scale,
                  right: 14 * scale,
                  top: 8 * scale,
                  bottom: 14 * scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Reward 1: Ring / Avatar frame +1
                      Expanded(
                        child: _buildSlotItem(
                          iconAsset:
                              'assets/graphics/purchase_screen/unused_or_verify/coin_icon_variant_flamering.png',
                          fallbackIcon: Icons.military_tech_rounded,
                          qty: '+1',
                          scale: scale,
                        ),
                      ),
                      // Divider line
                      Container(
                        width: 1,
                        height: 36 * scale,
                        color: const Color(0xFFDDD2F8),
                      ),
                      // Reward 2: Diamonds +150
                      Expanded(
                        child: _buildSlotItem(
                          iconAsset:
                              'assets/graphics/purchase_screen/common/icon_diamond_header.png',
                          fallbackIcon: Icons.diamond_rounded,
                          qty: '+150',
                          scale: scale,
                        ),
                      ),
                      // Divider line
                      Container(
                        width: 1,
                        height: 36 * scale,
                        color: const Color(0xFFDDD2F8),
                      ),
                      // Reward 3: Gold +150000
                      Expanded(
                        child: _buildSlotItem(
                          iconAsset:
                              'assets/graphics/purchase_screen/common/icon_coin_header.png',
                          fallbackIcon: Icons.monetization_on_rounded,
                          qty: '+150000',
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 6 * scale),

          // Subtitle: Recharge any amount to get bonus rewards
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4C8FF),
              ),
              children: const [
                TextSpan(text: 'Recharge '),
                TextSpan(
                  text: 'any amount',
                  style: TextStyle(
                    color: Color(0xFFFF5EA8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ' to get bonus rewards'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotItem({
    required String iconAsset,
    required IconData fallbackIcon,
    required String qty,
    required double scale,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon with circular base pedestal
        Container(
          width: 28 * scale,
          height: 28 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEDE5FC),
            border: Border.all(
              color: const Color(0xFFD6C8F8),
              width: 0.8 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.18),
                blurRadius: 4 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 19 * scale,
              height: 19 * scale,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                size: 17 * scale,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ),
        ),
        SizedBox(height: 3 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            qty,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF381F78),
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
