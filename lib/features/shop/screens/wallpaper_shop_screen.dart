import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Wallpaper Theme Shop Screen matching Screenshots 3 & 4 & Prompt:
/// - Top Bar with History/Exchange, Diamonds, Coupon/Help/Close
/// - Two Segmented Tabs: 'Basic Theme' | 'Royal Theme'
/// - 3 Columns of Vertical Wallpaper Cards on 3D Shelves
class WallpaperShopScreen extends ConsumerStatefulWidget {
  const WallpaperShopScreen({super.key});

  @override
  ConsumerState<WallpaperShopScreen> createState() =>
      _WallpaperShopScreenState();
}

class _WallpaperShopScreenState extends ConsumerState<WallpaperShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_WallpaperItem> _basicThemes = const [
    _WallpaperItem(
      name: 'Golden Mountain',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/GoldenMountainTheme.png',
    ),
    _WallpaperItem(
      name: 'Sky Wheel',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/SkyWheelTheme.png',
    ),
    _WallpaperItem(
      name: 'Starry night',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/StarryNightTheme.png',
    ),
    _WallpaperItem(
      name: 'Urban Twilight',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/SkyScrapperTheme.png',
    ),
    _WallpaperItem(
      name: 'Fantastic Jellyfish',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/JellyFishTheme.png',
    ),
    _WallpaperItem(
      name: 'Fantastic Lion',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/FantasticLionTheme.png',
    ),
    _WallpaperItem(
      name: 'Waterfall',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/WaterFallTheme.png',
    ),
    _WallpaperItem(
      name: 'Bonefire',
      imageAsset:
          'assets/graphics/shop/06_theme_basic_wallpapers/BoneFireTheme.png',
    ),
  ];

  final List<_WallpaperItem> _royalThemes = const [
    _WallpaperItem(
      name: 'Twilight knight',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/TwilightKnightRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Red car Beneath Snow',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/RedCarBeneathSnowRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Couple at dusk',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/CoupleAtDuskRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Dream Garden',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/DreamGardenRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Mountain',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/MountainRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'BoneFire night',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/BoneFireNightRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Supreme Car',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/SupremeCarRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Castle',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/CastleRoyalTheme.png',
      isRoyal: true,
    ),
    _WallpaperItem(
      name: 'Knight Sword',
      imageAsset:
          'assets/graphics/shop/07_theme_royal_wallpapers/KnightSwordRoyalTheme.png',
      isRoyal: true,
    ),
  ];

  int _equippedBasic = 0;
  int _equippedRoyal = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              // 1. Top Bar
              _buildTopBar(context, shopState.userDiamonds, scale),
              SizedBox(height: 6 * scale),

              // 2. Segmented Tabs: Basic Theme | Royal Theme
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                child: _buildSegmentedTabBar(scale),
              ),
              SizedBox(height: 12 * scale),

              // 3. TabBarView for Basic & Royal Themes
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWallpaperGrid(
                        items: _basicThemes,
                        scale: scale,
                        equippedIdx: _equippedBasic,
                        onSelect: (idx) =>
                            setState(() => _equippedBasic = idx),
                      ),
                      _buildWallpaperGrid(
                        items: _royalThemes,
                        scale: scale,
                        equippedIdx: _equippedRoyal,
                        onSelect: (idx) =>
                            setState(() => _equippedRoyal = idx),
                      ),
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

  Widget _buildSegmentedTabBar(double scale) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF160634).withOpacity(0.92),
        borderRadius: BorderRadius.circular(21 * scale),
        border: Border.all(
          color: const Color(0xFF764BC0).withOpacity(0.6),
          width: 1 * scale,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorPadding: EdgeInsets.all(3 * scale),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B2FD7), Color(0xFF381577)],
          ),
          borderRadius: BorderRadius.circular(18 * scale),
          border: Border.all(
            color: const Color(0xFFCCA3FF),
            width: 1 * scale,
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFCCA3FF),
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13 * scale,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.5 * scale,
          fontWeight: FontWeight.w600,
        ),
        onTap: (_) => SoundService().playButtonClick(),
        tabs: const [
          Tab(text: 'Basic Theme'),
          Tab(text: 'Royal Theme'),
        ],
      ),
    );
  }

  Widget _buildWallpaperGrid({
    required List<_WallpaperItem> items,
    required double scale,
    required int equippedIdx,
    required Function(int) onSelect,
  }) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 3;

    for (int i = 0; i < items.length; i += itemsPerRow) {
      final rowItems = items.skip(i).take(itemsPerRow).toList();
      final startIndex = i;

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final itemIdx = startIndex + colIdx;
              final item = rowItems[colIdx];
              final isEquipped = equippedIdx == itemIdx;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      onSelect(itemIdx);
                    },
                    child: AspectRatio(
                      aspectRatio: 0.68, // Vertical portrait wallpaper card
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                            color: isEquipped
                                ? const Color(0xFF5BA4FC)
                                : const Color(0xFFFFD700).withOpacity(0.7),
                            width: isEquipped ? 2 * scale : 1.2 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isEquipped
                                  ? const Color(0x665BA4FC)
                                  : Colors.black.withOpacity(0.4),
                              blurRadius: 6 * scale,
                              offset: Offset(0, 3 * scale),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9 * scale),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Wallpaper Image
                              Image.asset(
                                item.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF381577),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.wallpaper,
                                    color: Colors.white70,
                                    size: 32 * scale,
                                  ),
                                ),
                              ),

                              // 2. Crown Badge for Royal Theme
                              if (item.isRoyal)
                                Positioned(
                                  top: 4 * scale,
                                  left: 4 * scale,
                                  child: Container(
                                    width: 18 * scale,
                                    height: 18 * scale,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF280B52)
                                          .withOpacity(0.85),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFFD700),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.workspace_premium_rounded,
                                      color: const Color(0xFFFFD700),
                                      size: 12 * scale,
                                    ),
                                  ),
                                ),

                              // 3. Bottom Gradient Name Pill
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 24 * scale,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.85),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2 * scale),
                                  child: Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 8.5 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // 4. Equipped Checkmark Badge
                              if (isEquipped)
                                Positioned(
                                  bottom: 2 * scale,
                                  right: 2 * scale,
                                  child: SizedBox(
                                    width: 18 * scale,
                                    height: 18 * scale,
                                    child: Image.asset(
                                      'assets/graphics/shop/13_badges_selection_indicators/Group_1261153273.png',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Expanded(child: SizedBox());
            }
          }),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(children: shelfWidgets),
    );
  }
}

class _WallpaperItem {
  final String name;
  final String imageAsset;
  final bool isRoyal;

  const _WallpaperItem({
    required this.name,
    required this.imageAsset,
    this.isRoyal = false,
  });
}
