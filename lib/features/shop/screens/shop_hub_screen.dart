import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/screens/ornament_screen.dart';
import 'package:ludo_vibe/features/shop/screens/royal_vehicle_shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/sticker_shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/table_tile_screen.dart';
import 'package:ludo_vibe/features/shop/screens/wallpaper_shop_screen.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Screen 1 (The Shop Hub / Main Menu from Image 4 & Prompt):
/// Displays the promo banner and 4 illuminated 3D purple shelves
/// hosting large, prominent category items on 3D pedestals with purple pill labels.
class ShopHubScreen extends ConsumerWidget {
  const ShopHubScreen({super.key});

  void _openCategory(BuildContext context, int tabIndex) {
    SoundService().playButtonClick();
    if (tabIndex == 99) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const OrnamentScreen(),
        ),
      );
      return;
    }
    if (tabIndex == 98) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const RoyalVehicleShopScreen(),
        ),
      );
      return;
    }
    if (tabIndex == 97) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const WallpaperShopScreen(),
        ),
      );
      return;
    }
    if (tabIndex == 96) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TableTileScreen(initialTabIndex: 0),
        ),
      );
      return;
    }
    if (tabIndex == 95) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TableTileScreen(initialTabIndex: 1),
        ),
      );
      return;
    }
    if (tabIndex == 94) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const StickerShopScreen(),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopScreen(initialTabIndex: tabIndex),
      ),
    );
  }

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
              // 1. Top Bar (Diamond capsule + Close X)
              _buildTopBar(context, shopState.userDiamonds, scale),
              SizedBox(height: 4 * scale),

              // 2. Scrollable Shelves Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Column(
                    children: [
                      // Top Promo Banner Carousel
                      _buildPromoBanner(scale),
                      SizedBox(height: 12 * scale),

                      // Shelf 1 (3 Items: Ludo Skin, Domino Skin, Jackaro Skin)
                      _buildHubShelf(
                        scale: scale,
                        items: [
                          _HubItemData(
                            title: 'Ludo Skin',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_271.png',
                            tabIndex: 0, // Dice Tab
                          ),
                          _HubItemData(
                            title: 'Domino Skin',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_272.png',
                            tabIndex: 1, // Token Tab
                          ),
                          _HubItemData(
                            title: 'Jackaro Skin',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_240.png',
                            tabIndex: 2, // Bubble Tab
                          ),
                        ],
                        onTap: (idx) => _openCategory(context, idx),
                      ),

                      // Shelf 2 (3 Items: Sticker, Profile Card, Ornament)
                      _buildHubShelf(
                        scale: scale,
                        items: [
                          _HubItemData(
                            title: 'Sticker',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_241.png',
                            tabIndex: 94, // Standalone Sticker Screen
                          ),
                          _HubItemData(
                            title: 'Profile Card',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_242.png',
                            tabIndex: 97, // Wallpaper Themes
                          ),
                          _HubItemData(
                            title: 'Ornament',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_273.png',
                            tabIndex: 99, // Ornament Screen
                          ),
                        ],
                        onTap: (idx) => _openCategory(context, idx),
                      ),

                      // Shelf 3 (3 Items: Unique ID, Theme, Pin on top)
                      _buildHubShelf(
                        scale: scale,
                        items: [
                          _HubItemData(
                            title: 'Unique ID',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_243.png',
                            tabIndex: 96, // Table Screen
                          ),
                          _HubItemData(
                            title: 'Theme',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_244.png',
                            tabIndex: 97, // Wallpaper Themes
                          ),
                          _HubItemData(
                            title: 'Pin on top',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_245.png',
                            tabIndex: 95, // Tile Screen
                          ),
                        ],
                        onTap: (idx) => _openCategory(context, idx),
                      ),

                      // Shelf 4 (2 Items: Royal Vehicle, Entry Effects)
                      _buildHubShelf(
                        scale: scale,
                        items: [
                          _HubItemData(
                            title: 'Royal Vehicle',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_270.png',
                            tabIndex: 98, // Royal Vehicle Screen
                          ),
                          _HubItemData(
                            title: 'Entry Effects',
                            imageAsset:
                                'assets/graphics/shop/15_main_screen_banner_icons/image_242.png',
                            tabIndex: 96, // Table/Tile Screen
                          ),
                        ],
                        onTap: (idx) => _openCategory(context, idx),
                      ),
                      SizedBox(height: 16 * scale),
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
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 32 * scale),

          // Center Diamond Counter Capsule
          Container(
            height: 30 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF130630).withOpacity(0.9),
              borderRadius: BorderRadius.circular(15 * scale),
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
                  width: 18 * scale,
                  height: 18 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '$diamonds',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Container(
                  width: 18 * scale,
                  height: 18 * scale,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF9B63), Color(0xFFF97023)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 13 * scale,
                  ),
                ),
              ],
            ),
          ),

          // Right Close (X) Button
          GestureDetector(
            onTap: () {
              SoundService().playButtonClick();
              context.pop();
            },
            child: Container(
              width: 30 * scale,
              height: 30 * scale,
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
                size: 18 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(double scale) {
    return Container(
      width: double.infinity,
      height: 118 * scale,
      margin: EdgeInsets.symmetric(horizontal: 4 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66764BC0),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14 * scale),
        child: Image.asset(
          'assets/graphics/shop/17_misc_uncategorized/image_222.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A1988), Color(0xFF1E044D)],
              ),
            ),
            child: Center(
              child: Text(
                'Skin Design Contest\nCo-Created Skins',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD369),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHubShelf({
    required double scale,
    required List<_HubItemData> items,
    required Function(int) onTap,
  }) {
    return ShopShelfRow(
      scale: scale,
      shelfHeight: 20.0,
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(item.tabIndex),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Item Pedestal and Category Artwork
                  SizedBox(
                    height: 82 * scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Purple Pedestal Base
                        Positioned(
                          bottom: 0,
                          child: SizedBox(
                            width: 68 * scale,
                            height: 28 * scale,
                            child: Image.asset(
                              'assets/graphics/shop/12_ui_backgrounds/TrayForicons.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                height: 12 * scale,
                                width: 50 * scale,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF551FB8),
                                  borderRadius: BorderRadius.circular(6 * scale),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 2. Large 3D Category Icon Artwork
                        Positioned(
                          bottom: 6 * scale,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x779E6BFF),
                                  blurRadius: 10 * scale,
                                  offset: Offset(0, 2 * scale),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              item.imageAsset,
                              width: 62 * scale,
                              height: 62 * scale,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.stars_rounded,
                                color: const Color(0xFFFFD369),
                                size: 48 * scale,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2 * scale),

                  // Category Title Pill Label
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 3.5 * scale),
                    margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF551FB8), Color(0xFF280B52)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(
                        color: const Color(0xFFC79BFF).withOpacity(0.55),
                        width: 1 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 4 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.5 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 2,
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
      }).toList(),
    );
  }
}

class _HubItemData {
  final String title;
  final String imageAsset;
  final int tabIndex;

  const _HubItemData({
    required this.title,
    required this.imageAsset,
    required this.tabIndex,
  });
}
