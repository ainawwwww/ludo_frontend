import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/router/nav_loader_extension.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';

String _formatAmount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}k';
  }
  return '$value';
}

class TopBar extends ConsumerWidget {
  const TopBar({
    super.key,
    this.playerName,
    this.coins,
    this.diamonds,
    this.level,
    this.onProfileTap,
    this.onSettingsTap,
    this.onCartTap,
    this.onPlusCoinsTap,
    this.onPlusDiamondsTap,
  });

  final String? playerName;
  final String? coins;
  final String? diamonds;
  final int? level;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onPlusCoinsTap;
  final VoidCallback? onPlusDiamondsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    final authUser = ref.watch(authProvider).user;

    final effectivePlayerName = playerName ?? authUser?.username ?? 'Player';
    final effectiveCoins = coins ?? (authUser != null ? _formatAmount(authUser.coins) : '10k');
    final effectiveDiamonds = diamonds ?? (authUser != null ? _formatAmount(authUser.diamonds) : '50');
    final effectiveLevel = level ?? authUser?.level ?? 1;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/graphics/TopBar.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 8 * scale,
          ),
          child: Row(
            children: [
              // LEFT Profile Avatar & Name (Tappable for Profile Settings)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  SoundService().playButtonClick();
                  if (onProfileTap != null) {
                    onProfileTap!();
                  } else {
                    context.push(AppConstants.profileRoute);
                  }
                },
                child: Row(
                  children: [
                    _ProfileAvatar(scale: scale),
                    SizedBox(width: 8 * scale),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          effectivePlayerName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  // Level badge directly below the name!
                  SizedBox(
                    width: 24 * scale,
                    height: 24 * scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/graphics/icon_level.png',
                          width: 24 * scale,
                          height: 24 * scale,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 2 * scale,
                          child: Text(
                            '$effectiveLevel',
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
                ],
              ),
            ],
          ),
        ),
              SizedBox(width: 10 * scale),
              
              // Separate Coins Capsule
              Expanded(
                child: _buildResourceCapsule(
                  iconAsset: 'assets/graphics/icon_coins.png',
                  value: effectiveCoins,
                  onPlusTap: () {
                    SoundService().playButtonClick();
                    if (onPlusCoinsTap != null) {
                      onPlusCoinsTap!();
                    } else {
                      context.push(AppConstants.goldShopRoute, extra: {'tab': 0});
                    }
                  },
                  scale: scale,
                ),
              ),
              SizedBox(width: 8 * scale),
              
              // Separate Diamonds Capsule
              Expanded(
                child: _buildResourceCapsule(
                  iconAsset: 'assets/graphics/icon_diamond.png',
                  value: effectiveDiamonds,
                  onPlusTap: () {
                    SoundService().playButtonClick();
                    if (onPlusDiamondsTap != null) {
                      onPlusDiamondsTap!();
                    } else {
                      context.push(AppConstants.goldShopRoute, extra: {'tab': 1});
                    }
                  },
                  scale: scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              
              // Orange Shopping Cart Icon
              GestureDetector(
                onTap: () {
                  SoundService().playButtonClick();
                  if (onCartTap != null) {
                    onCartTap!();
                  } else {
                    context.push(AppConstants.goldShopRoute);
                  }
                },
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: const Color(0xFFFF7A00),
                  size: 26 * scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              
              // Settings Gear Icon
              GestureDetector(
                onTap: () {
                  SoundService().playButtonClick();
                  if (onSettingsTap != null) onSettingsTap!();
                },
                child: Image.asset(
                  'assets/graphics/icon_settings.png',
                  width: 24 * scale,
                  height: 24 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCapsule({
    required String iconAsset,
    required String value,
    required VoidCallback? onPlusTap,
    required double scale,
  }) {
    return Container(
      height: 32 * scale,
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0C073E).withOpacity(0.55), // Translucent dark capsule background
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          // Resource Icon
          Image.asset(
            iconAsset,
            width: 18 * scale,
            height: 18 * scale,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 2 * scale),
          
          // Resource Value
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Plus Button Icon
          GestureDetector(
            onTap: onPlusTap,
            child: Image.asset(
              'assets/graphics/icon_plus.png',
              width: 20 * scale,
              height: 20 * scale,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 46 * scale;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD9D9D9),
        border: Border.all(
          color: const Color(0xFFFDD369), // Gold color border
          width: 2 * scale,
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 26 * scale,
      ),
    );
  }
}
