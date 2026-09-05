import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/purchase_models.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/first_recharge_banner.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/package_card.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/privilege_item_widget.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/purchase_header.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/subscribe_footer_bar.dart';
import 'package:ludo_vibe/features/shop/widgets/purchase/tier_toggle_button.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedSubscriptionTierIndex = 0; // 0 = Knight, 1 = Baron

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, 2);
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _selectedTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBuyPackage(PurchasePackage pack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Purchased ${pack.amount} for ${pack.priceUsd}!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E1065),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.2),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSubscribe(SubscriptionTierData tier) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Subscribed to ${tier.name} for ${tier.monthlyPrice}/month!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E1065),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFB800), width: 1.2),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsDialog(String title, String description) {
    SoundService().playButtonClick();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1C134E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF6D28D9), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFFC4B5FD),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.85, 1.25);

    return Scaffold(
      backgroundColor: const Color(0xFF160A44),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C0D54),
              Color(0xFF160A44),
              Color(0xFF0F062E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Shared Header (Avatar, Level Crown, PRO Pill, Coins, Diamonds, Close X)
              PurchaseHeader(
                scale: scale,
                onClose: () => Navigator.pop(context),
              ),

              // 2. Pill Segmented Tab Bar (Gold | Diamond | Subscription)
              _buildTabBar(scale),

              SizedBox(height: 6 * scale),

              // 3. Tab Content View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tab 0: Gold
                    _buildPackageGridTab(
                      packages: PurchaseScreenData.goldPackages,
                      isGold: true,
                      scale: scale,
                      detailsButtonText: 'Gold Details',
                      onDetailsTap: () => _showDetailsDialog(
                        'Gold Coins Info',
                        'Gold coins are used to play matches, participate in tournaments, enter private rooms, and tip friends.',
                      ),
                    ),

                    // Tab 1: Diamond
                    _buildPackageGridTab(
                      packages: PurchaseScreenData.diamondPackages,
                      isGold: false,
                      scale: scale,
                      detailsButtonText: 'Gold Details',
                      onDetailsTap: () => _showDetailsDialog(
                        'Diamonds Info',
                        'Diamonds are premium currency used for purchasing rare dice, board skins, tokens, animated stickers, and unlocking exclusive privileges.',
                      ),
                    ),

                    // Tab 2: Subscription
                    _buildSubscriptionTab(scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(double scale) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      height: 40 * scale,
      padding: EdgeInsets.all(3.5 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0D062E),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFF2E1A68), width: 1.0 * scale),
      ),
      child: Row(
        children: [
          // Tab 0: Gold
          Expanded(
            child: _buildTabItem(
              title: 'Gold',
              index: 0,
              iconAsset: 'assets/graphics/icon_coins.png',
              scale: scale,
            ),
          ),

          // Tab 1: Diamond
          Expanded(
            child: _buildTabItem(
              title: 'Diamond',
              index: 1,
              iconAsset: 'assets/graphics/icon_diamond.png',
              scale: scale,
            ),
          ),

          // Tab 2: Subscription
          Expanded(
            child: _buildTabItem(
              title: 'Subscription',
              index: 2,
              iconAsset:
                  'assets/graphics/purchase_screen/subscription_tab/icon_knight_shield_small.png',
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required int index,
    required String iconAsset,
    required double scale,
  }) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        SoundService().playButtonClick();
        _tabController.animateTo(index);
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 5 * scale,
                    offset: Offset(0, 1 * scale),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Image.asset(
                    iconAsset,
                    width: 14 * scale,
                    height: 14 * scale,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4 * scale),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11 * scale,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF1E0E52)
                        : const Color(0xFF8B7BC4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageGridTab({
    required List<PurchasePackage> packages,
    required bool isGold,
    required double scale,
    required String detailsButtonText,
    required VoidCallback onDetailsTap,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      child: Column(
        children: [
          // 1. Top First Recharge Banner
          FirstRechargeBanner(scale: scale),

          SizedBox(height: 12 * scale),

          // 2. 3 Columns x 2 Rows Grid of Tall Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8 * scale,
              mainAxisSpacing: 10 * scale,
              childAspectRatio: 0.66,
            ),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final pack = packages[index];
              return PackageCard(
                package: pack,
                isGold: isGold,
                scale: scale,
                onTap: () => _onBuyPackage(pack),
              );
            },
          ),

          SizedBox(height: 16 * scale),

          // 3. Footer Details Pill Button
          GestureDetector(
            onTap: onDetailsTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32 * scale,
                vertical: 8.5 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0730),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(
                  color: const Color(0xFF382378),
                  width: 1.2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 5 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Text(
                detailsButtonText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB5A4F0),
                ),
              ),
            ),
          ),

          SizedBox(height: 16 * scale),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTab(double scale) {
    final currentTier = _selectedSubscriptionTierIndex == 0
        ? PurchaseScreenData.knightTier
        : PurchaseScreenData.baronTier;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 8 * scale),
            child: Column(
              children: [
                // 1. Tier Selector Toggle (Knight / Baron)
                TierToggleButton(
                  selectedTierIndex: _selectedSubscriptionTierIndex,
                  scale: scale,
                  onTierChanged: (index) {
                    setState(() {
                      _selectedSubscriptionTierIndex = index;
                    });
                  },
                ),

                SizedBox(height: 8 * scale),

                // 2. Hero Section: Podium Background, Sunburst Glow, Large Emblem & Chevron Arrows
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14 * scale),
                  height: 180 * scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Podium Panel Background
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16 * scale),
                          child: Image.asset(
                            'assets/graphics/purchase_screen/subscription_tab/bg_panel_podium.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1F1462),
                                    Color(0xFF0F0838)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16 * scale),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sunburst Glow Overlay behind emblem
                      Positioned(
                        top: 10 * scale,
                        child: Image.asset(
                          'assets/graphics/purchase_screen/subscription_tab/bg_tier_sunburst_glow.png',
                          width: 140 * scale,
                          height: 140 * scale,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120 * scale,
                            height: 120 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_selectedSubscriptionTierIndex == 0
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFA855F7))
                                  .withOpacity(0.25),
                            ),
                          ),
                        ),
                      ),

                      // Large Emblem with animated crossfade
                      Positioned(
                        top: 18 * scale,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: Image.asset(
                            currentTier.emblemAsset,
                            key: ValueKey<String>(currentTier.id),
                            height: 130 * scale,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.security_rounded,
                              size: 100 * scale,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),

                      // Left Chevron Arrow Button
                      Positioned(
                        left: 8 * scale,
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playButtonClick();
                            setState(() {
                              _selectedSubscriptionTierIndex =
                                  _selectedSubscriptionTierIndex == 0 ? 1 : 0;
                            });
                          },
                          child: Container(
                            width: 32 * scale,
                            height: 32 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF140D3E).withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF5D4BB8),
                                width: 1.0 * scale,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/graphics/purchase_screen/subscription_tab/nav_chevron_left.png',
                              width: 12 * scale,
                              height: 12 * scale,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 20 * scale,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right Chevron Arrow Button
                      Positioned(
                        right: 8 * scale,
                        child: GestureDetector(
                          onTap: () {
                            SoundService().playButtonClick();
                            setState(() {
                              _selectedSubscriptionTierIndex =
                                  _selectedSubscriptionTierIndex == 0 ? 1 : 0;
                            });
                          },
                          child: Container(
                            width: 32 * scale,
                            height: 32 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF140D3E).withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF5D4BB8),
                                width: 1.0 * scale,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/graphics/purchase_screen/subscription_tab/nav_chevron_right.png',
                              width: 12 * scale,
                              height: 12 * scale,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 20 * scale,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14 * scale),

                // 3. "Exclusive Privileges" Section Header
                Text(
                  'Exclusive Privileges',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 10 * scale),

                // 4. 2-Column Grid of Privileges
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16 * scale,
                      mainAxisSpacing: 14 * scale,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: currentTier.privileges.length,
                    itemBuilder: (context, index) {
                      final priv = currentTier.privileges[index];
                      return PrivilegeItemWidget(
                        item: priv,
                        scale: scale,
                      );
                    },
                  ),
                ),

                SizedBox(height: 12 * scale),
              ],
            ),
          ),
        ),

        // 5. Fixed Bottom Subscribe Bar
        SubscribeFooterBar(
          tier: currentTier,
          scale: scale,
          onSubscribe: () => _onSubscribe(currentTier),
          onManageSubscriptions: () => _showDetailsDialog(
            'Subscription Management',
            'Subscriptions renew automatically each month unless cancelled at least 24 hours prior to renewal. You can manage or cancel your subscription in your App Store / Google Play account settings.',
          ),
        ),
      ],
    );
  }
}
