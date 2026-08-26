import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

import 'package:ludo_vibe/core/services/sound_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';

String _formatAmount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 10000) {
    return '${(value / 1000).toStringAsFixed(0)}k';
  } else if (value >= 1000) {
    final kVal = value / 1000;
    return kVal == kVal.roundToDouble() ? '${kVal.toInt()}k' : '${kVal.toStringAsFixed(1)}k';
  }
  return '$value';
}

String _formatAmountString(String? raw) {
  if (raw == null || raw.isEmpty) return '0';
  final numVal = int.tryParse(raw);
  if (numVal != null) {
    return _formatAmount(numVal);
  }
  return raw;
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
    final profileState = ref.watch(profileProvider);

    final effectivePlayerName = playerName ??
        (profileState.username.isNotEmpty && profileState.username != 'Player'
            ? profileState.username
            : (authUser?.username ?? 'Player'));
    final effectiveCoins = coins != null ? _formatAmountString(coins) : (authUser != null ? _formatAmount(authUser.coins) : '10k');
    final effectiveDiamonds = diamonds != null ? _formatAmountString(diamonds) : (authUser != null ? _formatAmount(authUser.diamonds) : '50');
    final effectiveLevel = level ?? authUser?.level ?? 1;
    final effectiveAvatarUrl = profileState.avatarUrl ?? authUser?.avatarUrl;

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
                    AvatarDisplay(
                      avatarIndex: profileState.avatarIndex,
                      size: 46 * scale,
                      borderWidth: 2 * scale,
                      avatarUrl: effectiveAvatarUrl,
                    ),
                    SizedBox(width: 8 * scale),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 90 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            effectivePlayerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14 * scale,
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
                          // Level badge directly below the name
                          SizedBox(
                            width: 22 * scale,
                            height: 22 * scale,
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
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * scale),
              
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
              SizedBox(width: 6 * scale),
              
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
              SizedBox(width: 8 * scale),
              
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
                  size: 24 * scale,
                ),
              ),
              SizedBox(width: 8 * scale),
              
              // Settings Gear Icon
              GestureDetector(
                onTap: () {
                  SoundService().playButtonClick();
                  if (onSettingsTap != null) onSettingsTap!();
                },
                child: Image.asset(
                  'assets/graphics/icon_settings.png',
                  width: 22 * scale,
                  height: 22 * scale,
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
      height: 30 * scale,
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0C073E).withValues(alpha: 0.55), // Translucent dark capsule background
        borderRadius: BorderRadius.circular(15 * scale),
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
          
          // Resource Value scaled and on 1 line
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 2 * scale),
          
          // Plus Button Icon
          GestureDetector(
            onTap: onPlusTap,
            child: Image.asset(
              'assets/graphics/icon_plus.png',
              width: 18 * scale,
              height: 18 * scale,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
