import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/screens/tabs/bubble_shop_tab.dart';
import 'package:ludo_vibe/features/shop/screens/tabs/theme_shop_tab.dart';
import 'package:ludo_vibe/features/shop/screens/tabs/tile_shop_tab.dart';
import 'package:ludo_vibe/features/shop/screens/tabs/token_shop_tab.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';

/// Screen 2 (The Category Inventory Screen matching Right Screen in Image 1):
/// Top bar with History/Exchange, Diamond capsule, Coupon/Help/Close,
/// 4 Tab Categories (Dice, Token, Bubble, Theme), and 4-column shelves grid.
class ShopScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const ShopScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_CategoryTabData> _tabs = const [
    _CategoryTabData(
      title: 'Dice',
      iconAsset:
          'assets/graphics/shop/11_nav_tab_icons_buttons/NavSelectorIcons/Selected_dice.png',
      fallbackIcon: Icons.casino_rounded,
    ),
    _CategoryTabData(
      title: 'Token',
      iconAsset:
          'assets/graphics/shop/11_nav_tab_icons_buttons/NavSelectorIcons/Unselected_token.png',
      fallbackIcon: Icons.token_rounded,
    ),
    _CategoryTabData(
      title: 'Bubble',
      iconAsset:
          'assets/graphics/shop/11_nav_tab_icons_buttons/NavSelectorIcons/Unselected_bubble.png',
      fallbackIcon: Icons.chat_bubble_rounded,
    ),
    _CategoryTabData(
      title: 'Theme',
      iconAsset:
          'assets/graphics/shop/11_nav_tab_icons_buttons/NavSelectorIcons/Unselected_theme.png',
      fallbackIcon: Icons.dashboard_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController
          .animateTo(widget.initialTabIndex.clamp(0, _tabs.length - 1));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A001C),
      body: ShopSpotlightBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar matching Image 1 Right (History, Exchange, Diamonds, %, ?, X)
              _buildCategoryTopBar(context, shopState.userDiamonds, scale),
              SizedBox(height: 4 * scale),

              // 2. 4-Segmented Tab Bar (Dice, Token, Bubble, Theme)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: _buildSegmentedTabBar(scale),
              ),
              SizedBox(height: 8 * scale),

              // 3. Tab Views with 4-Column Shelves
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      TokenShopTab(), // Tab 0: Dice skins
                      TileShopTab(), // Tab 1: Token / 4-Piece sets
                      BubbleShopTab(), // Tab 2: Bubble / Speech frames
                      ThemeShopTab(), // Tab 3: Themes / Board skins
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

  Widget _buildCategoryTopBar(
      BuildContext context, int diamonds, double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: History & Exchange icons
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

          // Center: Diamond Counter Capsule
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
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

          // Right: Coupon, Help, Close buttons
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
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    try {
                      context.pop();
                    } catch (_) {}
                  }
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

  Widget _buildSegmentedTabBar(double scale) {
    return Container(
      height: 40 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF160634).withOpacity(0.92),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: const Color(0xFF764BC0).withOpacity(0.6),
          width: 1 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 6 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicatorPadding: EdgeInsets.all(2 * scale),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B2FD7), Color(0xFF381577)],
          ),
          borderRadius: BorderRadius.circular(18 * scale),
          border: Border.all(
            color: const Color(0xFFCCA3FF),
            width: 1 * scale,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x666B2FD7),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFCCA3FF),
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5 * scale,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11 * scale,
          fontWeight: FontWeight.w600,
        ),
        onTap: (_) => SoundService().playButtonClick(),
        tabs: _tabs.map((t) {
          return Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    t.iconAsset,
                    width: 16 * scale,
                    height: 16 * scale,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      t.fallbackIcon,
                      size: 15 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5 * scale),
                  Text(t.title),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryTabData {
  final String title;
  final String iconAsset;
  final IconData fallbackIcon;

  const _CategoryTabData({
    required this.title,
    required this.iconAsset,
    required this.fallbackIcon,
  });
}
