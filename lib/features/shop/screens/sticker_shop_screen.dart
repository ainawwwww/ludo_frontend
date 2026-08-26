import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/screens/tabs/sticker_shop_tab.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';

/// Screen 6: Sticker Shop Screen (Sticker Pack | Single Sticker):
/// Top bar + Sticker Pack / Single Sticker tabs on 3D purple shelves
class StickerShopScreen extends ConsumerWidget {
  const StickerShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A001C),
      body: ShopSpotlightBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar
              _buildTopBar(context, shopState.userDiamonds, scale),
              SizedBox(height: 6 * scale),

              // 2. Sticker Tabs & 3D Units
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StickerShopTab(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int diamonds, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTopIconBtn(
                title: 'History',
                icon: Icons.history_rounded,
                scale: scale,
                onTap: () {},
              ),
              SizedBox(width: 8 * scale),
              _buildTopIconBtn(
                title: 'Exchange',
                icon: Icons.storefront_rounded,
                scale: scale,
                onTap: () {},
              ),
            ],
          ),

          // Center Diamond Counter Capsule
          Container(
            height: 28 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF130630).withOpacity(0.9),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(
                color: const Color(0xFF836DDF).withOpacity(0.55),
                width: 1 * scale,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/graphics/icon_diamond.png',
                  width: 16 * scale,
                  height: 16 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '$diamonds',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Container(
                  width: 16 * scale,
                  height: 16 * scale,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF9B63), Color(0xFFF97023)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 11 * scale,
                  ),
                ),
              ],
            ),
          ),

          // Right Buttons
          Row(
            children: [
              _buildSmallSquareBtn(
                child: Text(
                  '%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD369),
                  ),
                ),
                scale: scale,
                onTap: () {},
              ),
              SizedBox(width: 6 * scale),
              _buildSmallSquareBtn(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE2C4FF),
                  ),
                ),
                scale: scale,
                onTap: () {},
              ),
              SizedBox(width: 6 * scale),
              GestureDetector(
                onTap: () {
                  SoundService().playButtonClick();
                  context.pop();
                },
                child: Container(
                  width: 28 * scale,
                  height: 28 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B35E8), Color(0xFF381577)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCCA3FF).withOpacity(0.6),
                      width: 1 * scale,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 16 * scale,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconBtn({
    required String title,
    required IconData icon,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 28 * scale,
            height: 28 * scale,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5E22B8), Color(0xFF320E66)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCCA3FF).withOpacity(0.5),
                width: 1 * scale,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD369),
              size: 16 * scale,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 8 * scale,
              color: const Color(0xFFCCA3FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSquareBtn({
    required Widget child,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        onTap();
      },
      child: Container(
        width: 26 * scale,
        height: 26 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF280B52).withOpacity(0.9),
          borderRadius: BorderRadius.circular(6 * scale),
          border: Border.all(
            color: const Color(0xFF9E6BFF).withOpacity(0.6),
            width: 1 * scale,
          ),
        ),
        child: child,
      ),
    );
  }
}
