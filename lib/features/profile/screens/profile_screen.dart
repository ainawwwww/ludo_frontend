import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/avatar_display.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';
import 'package:ludo_vibe/features/profile/providers/profile_customization_provider.dart';
import 'package:ludo_vibe/features/wallet/providers/wallet_management_provider.dart';
import 'package:ludo_vibe/shared/widgets/league_rank_dialog.dart';
import 'package:ludo_vibe/shared/widgets/app_close_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final customization = ref.watch(profileCustomizationProvider);
    final walletState = ref.watch(walletManagementProvider);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor:
          const Color(0xFFDCD2FD), // Soft purple background matching mockup
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Banner + Avatar Header
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Dark Purple Patterned Header Banner with optional theme background
                  Container(
                    height: 175 * scale,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          customization.currentTheme.accentColor
                              .withOpacity(0.9),
                          const Color(0xFF4C1895),
                          const Color(0xFF5D1CA8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background theme wallpaper preview overlay if custom theme is equipped
                        if (customization.currentTheme.id !=
                            'theme_classic_main')
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.35,
                              child: Image.asset(
                                customization.currentTheme.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        // Background pattern simulation (diamond grid)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.12,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                              ),
                              itemCount: 30,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
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
                          child: AppCloseButton(
                            size: 32 * scale,
                            onTap: () => context.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 1. Dedicated Wide Header Ornament Layer (if equipped)
                  if (!customization.currentOrnament.isNone &&
                      customization.currentOrnament.assetPath != null)
                    Positioned(
                      top: 40 * scale,
                      child: IgnorePointer(
                        child: Container(
                          width: 330 * scale,
                          height: 165 * scale,
                          alignment: Alignment.center,
                          child: Image.asset(
                            customization.currentOrnament.assetPath!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // 2. Avatar & Action Buttons Section (Placed on top so buttons are never hidden)
                  Padding(
                    padding: EdgeInsets.only(top: 105 * scale),
                    child: Column(
                      children: [
                        // Row with Cloth icon, Avatar, Edit icon
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left Cloth Button (T-Shirt icon) - Elevated & always on top
                              GestureDetector(
                                onTap: () => showClothMenuPopover(context, ref),
                                child: Container(
                                  width: 46 * scale,
                                  height: 46 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DEFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC7B3FF),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3D000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
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

                              SizedBox(width: 18 * scale),

                              // Profile Avatar with Equipped Custom Frame
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const BasicInfoAvatarDialog(
                                            initialTab: 0),
                                  );
                                },
                                child: AvatarDisplay(
                                  avatarIndex: profileState.avatarIndex,
                                  size: 96 * scale,
                                  borderWidth: 3.5 * scale,
                                  avatarUrl: profileState.avatarUrl ??
                                      customization.customAvatarPath ??
                                      customization.presetAvatarAsset ??
                                      ref.watch(authProvider).user?.avatarUrl,
                                  frameItem: customization.currentFrame,
                                  showOrnament: false,
                                ),
                              ),

                              SizedBox(width: 18 * scale),

                              // Right Edit Button - Elevated & always on top
                              GestureDetector(
                                onTap: () =>
                                    context.push(AppConstants.editProfileRoute),
                                child: Container(
                                  width: 46 * scale,
                                  height: 46 * scale,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DEFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC7B3FF),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3D000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: const Color(0xFFC06BEE),
                                    size: 24 * scale,
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
                    _buildLevelCard(scale, profileState),
                    SizedBox(height: 16 * scale),

                    // Wallet Management Section Card
                    _buildWalletCard(context, scale, walletState),
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
  Widget _buildLevelCard(double scale, ProfileState profileState) {
    final level = profileState.level;
    final xp = profileState.xp;
    final currentXpInLevel = xp % 100;
    final progressRatio = (currentXpInLevel / 100.0).clamp(0.05, 1.0);

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DEFF),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFC7B3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level',
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF260D5C),
                ),
              ),
              Text(
                'Total XP: $xp',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7565A4),
                ),
              ),
            ],
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
                      border: Border.all(
                          color: const Color(0xFFFFD54F), width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$level',
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
                      height: 16 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBCAAA4).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progressRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                              ),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '$currentXpInLevel / 100 XP',
                      style: TextStyle(
                        fontSize: 10.5 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                          ),
                        ],
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
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 8 * scale),
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
                      builder: (context) =>
                          const LeagueRankDialog(initialTab: 0),
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
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 6 * scale),
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

  // Wallet Management Card
  Widget _buildWalletCard(
      BuildContext context, double scale, WalletManagementState walletState) {
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
          // Purple Ribbon Header "Wallet Management"
          _buildRibbonHeader('Wallet Management', scale),
          SizedBox(height: 10 * scale),

          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 6 * scale),
            child: Column(
              children: [
                // Quick Balance Row
                Row(
                  children: [
                    // Coins Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                            color: const Color(0xFFFFD700), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on,
                              color: const Color(0xFFFFB300),
                              size: 16 * scale),
                          SizedBox(width: 4 * scale),
                          Text(
                            walletState.coins.toString(),
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF260D5C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    // Diamonds Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                            color: const Color(0xFF00E5FF), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.diamond,
                              color: const Color(0xFF00B0FF),
                              size: 16 * scale),
                          SizedBox(width: 4 * scale),
                          Text(
                            walletState.diamonds.toString(),
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF260D5C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Cash value tag
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Text(
                        '≈ ${walletState.currencySymbol} ${walletState.estimatedMoneyValue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),

                // Primary Wallet Management Action Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(AppConstants.walletRoute),
                    borderRadius: BorderRadius.circular(14 * scale),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E35B1).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 22 * scale,
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manage Wallet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 2 * scale),
                                Text(
                                  'Deposit, Withdraw & Convert Coins',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 10.5 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(20 * scale),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'OPEN',
                                  style: TextStyle(
                                    color: const Color(0xFF260D5C),
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 2 * scale),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFF260D5C),
                                  size: 11 * scale,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10 * scale),

                // Payment Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Supported:',
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7565A4),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    _buildMiniBadge('JazzCash', const Color(0xFFD32F2F), scale),
                    SizedBox(width: 4 * scale),
                    _buildMiniBadge('EasyPaisa', const Color(0xFF2E7D32), scale),
                    SizedBox(width: 4 * scale),
                    _buildMiniBadge('Bank Transfer', const Color(0xFF1565C0), scale),
                  ],
                ),
                SizedBox(height: 6 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String label, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 6 * scale, vertical: 2 * scale),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9 * scale,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
