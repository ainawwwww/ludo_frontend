import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

class ShopTopBar extends ConsumerWidget {
  final String title;
  final VoidCallback? onClose;
  final bool showBackButton;

  const ShopTopBar({
    super.key,
    this.title = 'SHOP',
    this.onClose,
    this.showBackButton = false,
  });

  String _formatAmount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 4 * scale,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () {
                SoundService().playButtonClick();
                if (onClose != null) {
                  onClose!();
                } else {
                  context.pop();
                }
              },
              child: Container(
                padding: EdgeInsets.all(5 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E103E).withOpacity(0.85),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBorder.withOpacity(0.4),
                    width: 1 * scale,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 12 * scale,
                ),
              ),
            ),
            SizedBox(width: 6 * scale),
          ],

          // Coins Capsule (Compact)
          Expanded(
            child: _buildResourceCapsule(
              iconAsset: 'assets/graphics/icon_coins.png',
              value: _formatAmount(shopState.userCoins),
              scale: scale,
              onPlusTap: () {
                SoundService().playButtonClick();
                _showTopUpDialog(context, 'Coins', scale);
              },
            ),
          ),
          SizedBox(width: 6 * scale),

          // Diamonds Capsule (Compact)
          Expanded(
            child: _buildResourceCapsule(
              iconAsset: 'assets/graphics/icon_diamond.png',
              value: _formatAmount(shopState.userDiamonds),
              scale: scale,
              onPlusTap: () {
                SoundService().playButtonClick();
                _showTopUpDialog(context, 'Diamonds', scale);
              },
            ),
          ),
          SizedBox(width: 8 * scale),

          // Close (X) button (Compact)
          GestureDetector(
            onTap: () {
              SoundService().playButtonClick();
              if (onClose != null) {
                onClose!();
              } else {
                context.pop();
              }
            },
            child: Container(
              width: 26 * scale,
              height: 26 * scale,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B35E8), Color(0xFF381577)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFCCA3FF).withOpacity(0.5),
                  width: 1 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3 * scale,
                    offset: Offset(0, 1.5 * scale),
                  ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCapsule({
    required String iconAsset,
    required String value,
    required double scale,
    required VoidCallback onPlusTap,
  }) {
    return Container(
      height: 27 * scale,
      padding: EdgeInsets.symmetric(horizontal: 5 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF130630).withOpacity(0.85),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0xFF836DDF).withOpacity(0.4),
          width: 0.8 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3 * scale,
            offset: Offset(0, 1.5 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 14 * scale,
            height: 14 * scale,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 3 * scale),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlusTap,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, String currency, double scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF22134E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          side: BorderSide(color: const Color(0xFF9E6BFF), width: 1.2 * scale),
        ),
        title: Text(
          'Recharge $currency',
          style: AppTextStyles.h3
              .copyWith(color: Colors.white, fontSize: 15 * scale),
        ),
        content: Text(
          'Choose your preferred $currency package from the Resource store.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: const Color(0xFFD4C1FF), fontSize: 11.5 * scale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push(AppConstants.goldShopRoute);
            },
            child: const Text('Go to Store',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
