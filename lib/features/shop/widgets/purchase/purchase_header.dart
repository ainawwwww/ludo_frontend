import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';
import 'package:ludo_vibe/features/profile/providers/profile_customization_provider.dart';

String _formatBalance(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 10000) {
    return '${(value / 1000).toStringAsFixed(0)}k';
  } else if (value >= 1000) {
    final kVal = value / 1000;
    return kVal == kVal.roundToDouble()
        ? '${kVal.toInt()}k'
        : '${kVal.toStringAsFixed(1)}k';
  }
  return '$value';
}

class PurchaseHeader extends ConsumerWidget {
  const PurchaseHeader({
    super.key,
    required this.onClose,
    this.scale = 1.0,
  });

  final VoidCallback onClose;
  final double scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);
    final customization = ref.watch(profileCustomizationProvider);

    final coinsStr = authUser != null ? _formatBalance(authUser.coins) : '33k';
    final diamondsStr =
        authUser != null ? _formatBalance(authUser.diamonds) : '33';
    final avatarIndex = profileState.avatarIndex;
    final avatarUrl = profileState.avatarUrl ??
        customization.customAvatarPath ??
        customization.presetAvatarAsset ??
        authUser?.avatarUrl;
    final level = authUser?.level ?? 33;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 8 * scale,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: Player Avatar with Crown Badge, PRO Pill & XP Progress Bar
          SizedBox(
            width: 58 * scale,
            height: 58 * scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular Avatar
                Positioned(
                  left: 2 * scale,
                  top: 0,
                  child: AvatarDisplay(
                    avatarIndex: avatarIndex,
                    size: 46 * scale,
                    borderWidth: 2 * scale,
                    avatarUrl: avatarUrl,
                    frameItem: customization.currentFrame,
                    ornamentItem: customization.currentOrnament,
                    showOrnament: false,
                  ),
                ),

                // Crown Badge Overlay on bottom-right of avatar
                Positioned(
                  left: 30 * scale,
                  top: 26 * scale,
                  child: Container(
                    width: 22 * scale,
                    height: 22 * scale,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/graphics/icon_level.png',
                          width: 22 * scale,
                          height: 22 * scale,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 1.5 * scale,
                          child: Text(
                            '$level',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Small PRO Pill Tag
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5 * scale, vertical: 1 * scale),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      borderRadius: BorderRadius.circular(6 * scale),
                      border: Border.all(
                          color: const Color(0xFFC4B5FD), width: 0.8 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.5),
                          blurRadius: 4 * scale,
                        ),
                      ],
                    ),
                    child: Text(
                      'PRO',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 6 * scale),

          // Thin XP Level Progress Bar under the name area
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 12 * scale,
                width: 72 * scale,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // XP Bar background
                    Container(
                      height: 6 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFF140E3E),
                        borderRadius: BorderRadius.circular(3 * scale),
                        border: Border.all(
                            color: const Color(0xFF3B2A8C), width: 0.8 * scale),
                      ),
                    ),
                    // XP Bar gradient progress fill
                    FractionallySizedBox(
                      widthFactor: 0.68,
                      child: Container(
                        height: 6 * scale,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFFA855F7),
                              Color(0xFFEC4899)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3 * scale),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT: Coin Chip, Diamond Chip, Close (X) Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coins Capsule Chip
              _buildBalanceChip(
                iconAsset:
                    'assets/graphics/purchase_screen/common/icon_coin_header.png',
                fallbackAsset: 'assets/graphics/icon_coins.png',
                amount: coinsStr,
                gradientColors: const [Color(0xFF1D1452), Color(0xFF130D3B)],
                borderColor: const Color(0xFF4C3B9B),
                scale: scale,
              ),

              SizedBox(width: 6 * scale),

              // Diamonds Capsule Chip
              _buildBalanceChip(
                iconAsset:
                    'assets/graphics/purchase_screen/common/icon_diamond_header.png',
                fallbackAsset: 'assets/graphics/icon_diamond.png',
                amount: diamondsStr,
                gradientColors: const [Color(0xFF1D1452), Color(0xFF130D3B)],
                borderColor: const Color(0xFF4C3B9B),
                scale: scale,
              ),

              SizedBox(width: 8 * scale),

              // Close (X) Button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  SoundService().playButtonClick();
                  onClose();
                },
                child: Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF281C6E),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF5D4BB8), width: 1.2 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/graphics/purchase_screen/common/btn_close.png',
                    width: 14 * scale,
                    height: 14 * scale,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.close_rounded,
                      color: const Color(0xFFD4C8FF),
                      size: 18 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChip({
    required String iconAsset,
    required String fallbackAsset,
    required String amount,
    required List<Color> gradientColors,
    required Color borderColor,
    required double scale,
  }) {
    return Container(
      height: 28 * scale,
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: borderColor, width: 1.0 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4 * scale,
            offset: Offset(0, 1.5 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            iconAsset,
            width: 18 * scale,
            height: 18 * scale,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              fallbackAsset,
              width: 18 * scale,
              height: 18 * scale,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 4 * scale),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
