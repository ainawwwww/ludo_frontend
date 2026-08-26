import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Screen 3: Ornament / Decorative Toppers Screen (matching Screenshot 1 & Prompt):
/// - Top Bar with Diamond capsule & Close X button
/// - Center Title Capsule: 'Ornament'
/// - 2-Column Wide Horizontal Ribbon / Garland Cards on 3D purple shelves
class OrnamentScreen extends ConsumerStatefulWidget {
  const OrnamentScreen({super.key});

  @override
  ConsumerState<OrnamentScreen> createState() => _OrnamentScreenState();
}

class _OrnamentScreenState extends ConsumerState<OrnamentScreen> {
  int _equippedIndex = 0;

  final List<_OrnamentItem> _ornaments = const [
    _OrnamentItem(
      name: 'Golden Wings',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_319.png',
    ),
    _OrnamentItem(
      name: 'Neon Horizon',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_320.png',
    ),
    _OrnamentItem(
      name: 'Galaxy Planets',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_324.png',
    ),
    _OrnamentItem(
      name: 'Crystal Garland',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_322.png',
    ),
    _OrnamentItem(
      name: 'Red Velvet Ribbon',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_317.png',
    ),
    _OrnamentItem(
      name: 'Yellow Blossom',
      imageAsset: 'assets/graphics/shop/08_ornaments/Group_1261153244-1.png',
    ),
    _OrnamentItem(
      name: 'Crimson Rose Arch',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_326.png',
    ),
    _OrnamentItem(
      name: 'Purple Aurora Silk',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_325.png',
    ),
    _OrnamentItem(
      name: 'Crescent Moon',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_332.png',
    ),
    _OrnamentItem(
      name: 'Ramadan Lanterns',
      imageAsset: 'assets/graphics/shop/08_ornaments/image_330.png',
    ),
  ];

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
              SizedBox(height: 8 * scale),

              // 2. 2-Column Wide Ribbon Cards on 3D Shelves
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Column(
                    children: _buildShelfRows(scale),
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
          // Left Diamond Capsule
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

          // Center Title Pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 22 * scale,
              vertical: 6 * scale,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B2FD7), Color(0xFF381577)],
              ),
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(
                color: const Color(0xFFCCA3FF),
                width: 1.2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66764BC0),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Text(
              'Ornament',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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

  List<Widget> _buildShelfRows(double scale) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 2;

    for (int i = 0; i < _ornaments.length; i += itemsPerRow) {
      final rowItems = _ornaments.skip(i).take(itemsPerRow).toList();
      final startIndex = i;

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final itemIdx = startIndex + colIdx;
              final item = rowItems[colIdx];
              final isEquipped = _equippedIndex == itemIdx;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      setState(() => _equippedIndex = itemIdx);
                    },
                    child: AspectRatio(
                      aspectRatio: 1.85, // Wide horizontal card
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Card Frame Asset
                          Positioned.fill(
                            child: Image.asset(
                              isEquipped
                                  ? 'assets/graphics/shop/12_ui_backgrounds/IconsbackgroundLargeInBlue.png'
                                  : 'assets/graphics/shop/12_ui_backgrounds/IconsbackgroundLargeInOrange.png',
                              fit: BoxFit.fill,
                            ),
                          ),

                          // Top Title
                          Positioned(
                            top: 2 * scale,
                            left: 4 * scale,
                            right: 4 * scale,
                            height: 18 * scale,
                            child: Center(
                              child: Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9.5 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Center Ribbon Artwork
                          Positioned.fill(
                            top: 18 * scale,
                            bottom: 4 * scale,
                            child: Center(
                              child: Image.asset(
                                item.imageAsset,
                                height: 48 * scale,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.celebration,
                                  color: Colors.white70,
                                  size: 32 * scale,
                                ),
                              ),
                            ),
                          ),

                          // Equipped Checkmark Badge
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
              );
            } else {
              return const Expanded(child: SizedBox());
            }
          }),
        ),
      );
    }

    return shelfWidgets;
  }
}

class _OrnamentItem {
  final String name;
  final String imageAsset;

  const _OrnamentItem({
    required this.name,
    required this.imageAsset,
  });
}
