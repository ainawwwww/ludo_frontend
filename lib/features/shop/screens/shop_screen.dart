import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

/// Data model representing a shop item on the shelf.
class ShopItemData {
  final String name;
  final String iconPath;
  final String labelPath;

  const ShopItemData({
    required this.name,
    required this.iconPath,
    required this.labelPath,
  });
}

/// The Shop screen for LudoVibe featuring a top bar, skin design contest banner,
/// and a 3D pedestal item shelf grid with glowing neon background continuation.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const List<ShopItemData> items = [
    ShopItemData(
      name: 'Ludo Skin',
      iconPath: 'assets/graphics/shop/icons/icon_ludo_skin.png',
      labelPath: 'assets/graphics/shop/labels/label_ludo_skin.png',
    ),
    ShopItemData(
      name: 'Domino Skin',
      iconPath: 'assets/graphics/shop/icons/icon_domino_skin.png',
      labelPath: 'assets/graphics/shop/labels/label_domino_skin.png',
    ),
    ShopItemData(
      name: 'Jackaro Skin',
      iconPath: 'assets/graphics/shop/icons/icon_jackaro_skin.png',
      labelPath: 'assets/graphics/shop/labels/label_jackaro_skin.png',
    ),
    ShopItemData(
      name: 'Sticker',
      iconPath: 'assets/graphics/shop/icons/icon_sticker.png',
      labelPath: 'assets/graphics/shop/labels/label_sticker.png',
    ),
    ShopItemData(
      name: 'Profile Card',
      iconPath: 'assets/graphics/shop/icons/icon_profile_card.png',
      labelPath: 'assets/graphics/shop/labels/label_profile_card.png',
    ),
    ShopItemData(
      name: 'Ornament',
      iconPath: 'assets/graphics/shop/icons/icon_ornament.png',
      labelPath: 'assets/graphics/shop/labels/label_ornament.png',
    ),
    ShopItemData(
      name: 'Unique ID',
      iconPath: 'assets/graphics/shop/icons/icon_unique_id.png',
      labelPath: 'assets/graphics/shop/labels/label_unique_id.png',
    ),
    ShopItemData(
      name: 'Theme',
      iconPath: 'assets/graphics/shop/icons/icon_theme.png',
      labelPath: 'assets/graphics/shop/labels/label_theme.png',
    ),
    ShopItemData(
      name: 'Pin on top',
      iconPath: 'assets/graphics/shop/icons/icon_pin_on_top.png',
      labelPath: 'assets/graphics/shop/labels/label_pin_on_top.png',
    ),
    ShopItemData(
      name: 'Royal Vehicle',
      iconPath: 'assets/graphics/shop/icons/icon_royal_vehicle.png',
      labelPath: 'assets/graphics/shop/labels/label_royal_vehicle.png',
    ),
    ShopItemData(
      name: 'Entry Effects',
      iconPath: 'assets/graphics/shop/icons/icon_entry_effects.png',
      labelPath: 'assets/graphics/shop/labels/label_entry_effects.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.8, 1.4);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                // 1. Top bar
                _buildTopBar(context, scale),

                // Scrollable area for banner and item shelf grid
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 2. Contest banner (top section)
                          _buildContestBanner(scale),
                          SizedBox(height: 8 * scale),

                          // 4. Shelf region aligned to background shelf LED ledges
                          _buildShelfSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the shelf section where shop items rest precisely on the 3D shelf ledges.
  Widget _buildShelfSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shelfWidth = constraints.maxWidth;
        // Natural design dimensions of shop_shelf_background.jpg (738 x 1600)
        final scaleFactor = shelfWidth / 738.0;
        final shelfHeight = 1380.0 * scaleFactor;

        const rowIndices = [
          [0, 3],   // Row 0: Items 0, 1, 2
          [3, 6],   // Row 1: Items 3, 4, 5
          [6, 9],   // Row 2: Items 6, 7, 8
          [9, 11],  // Row 3: Items 9, 10
        ];

        // Design Y coordinates for item slot tops to place pedestals directly on the shelf LED lines
        // LED Y lines in shop_shelf_background.jpg: 405, 654, 903, 1152
        final rowTopYDesign = [274.0, 523.0, 772.0, 1021.0];

        return SizedBox(
          width: shelfWidth,
          height: shelfHeight,
          child: Stack(
            children: [
              // 1. Background cabinet shelf graphic
              Positioned.fill(
                child: Image.asset(
                  'assets/graphics/shop/background/shop_shelf_background.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // 2. Item rows aligned precisely with shelf LED ledges
              for (int r = 0; r < rowIndices.length; r++)
                Positioned(
                  top: rowTopYDesign[r] * scaleFactor,
                  left: 16.0 * scaleFactor,
                  right: 16.0 * scaleFactor,
                  child: _buildShelfRow(
                    items.sublist(rowIndices[r][0], rowIndices[r][1]),
                    scaleFactor,
                    12.0,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 1. Top bar widget
  Widget _buildTopBar(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 8 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Balance capsule (diamond icon + balance text + plus top-up button)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E103E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(20 * scale),
              border: Border.all(
                color: AppColors.primaryBorder.withOpacity(0.5),
                width: 1 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4 * scale,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/graphics/shop/ui/icon_diamond.png',
                  height: 22 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8 * scale),
                Builder(
                  builder: (context) {
                    return Consumer(
                      builder: (context, ref, child) {
                        String diamondsStr = '33';
                        try {
                          final authUser = ref.watch(authProvider).user;
                          if (authUser != null) diamondsStr = '${authUser.diamonds}';
                        } catch (_) {}
                        return Text(
                          diamondsStr,
                          style: AppTextStyles.resourceValue.copyWith(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(width: 10 * scale),
                GestureDetector(
                  onTap: () {
                    debugPrint('Top-up button tapped');
                  },
                  child: Image.asset(
                    'assets/graphics/shop/ui/icon_plus.png',
                    height: 22 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          // Dismiss / Close button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: EdgeInsets.all(6 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1 * scale,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Contest banner widget
  Widget _buildContestBanner(double scale) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B2FD7),
            Color(0xFF43169E),
            Color(0xFF5B1DA0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFF9E6BFF).withOpacity(0.5),
          width: 1.5 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x664B179E),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skin Design Contest',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          shadows: const [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        'Co-Created Skins',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE2C4FF),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * scale),
                Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: const Color(0xFFFFD369),
                    size: 22 * scale,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Text(
                '29/06/2026 05:00 - 07/07/2026 05:00 (GMT+3)',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD4C1FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single shelf row containing up to 3 item slots
  Widget _buildShelfRow(
    List<ShopItemData> rowItems,
    double scale,
    double itemSpacing,
  ) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i < rowItems.length)
            Expanded(
              child: _buildItemSlot(rowItems[i], scale),
            )
          else
            const Expanded(child: SizedBox()),
          if (i < 2) SizedBox(width: itemSpacing * scale),
        ],
      ],
    );
  }

  /// 3. Individual item slot Stack (layered bottom to top):
  /// 1. pedestal_shadow.png
  /// 2. pedestal_tray.png
  /// 3. Item icon (icon_*.png)
  /// 4. Item label (label_*.png)
  Widget _buildItemSlot(
    ShopItemData item,
    double scale,
  ) {
    final slotHeight = 145.0 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = constraints.maxWidth;

        return GestureDetector(
          onTap: () {
            debugPrint('Tapped shop item: ${item.name}');
          },
          child: SizedBox(
            width: slotWidth,
            height: slotHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. pedestal_shadow.png (purple pill base - flush under pedestal_tray with 0 gap)
                Positioned(
                  bottom: 8 * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: slotWidth * 0.60,
                      height: 16 * scale,
                      child: Image.asset(
                        'assets/graphics/shop/pedestal/pedestal_shadow.png',
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                // 2. pedestal_tray.png (purple 3D tray platform sitting directly over shadow)
                Positioned(
                  bottom: 12 * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: slotWidth * 0.95,
                      height: 56 * scale,
                      child: Image.asset(
                        'assets/graphics/shop/pedestal/pedestal_tray.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                // 3. Item's icon (icon_*.png) resting on top surface of tray
                Positioned(
                  bottom: 42 * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: slotWidth * 0.65,
                      height: 54 * scale,
                      child: Image.asset(
                        item.iconPath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 4. Item's label (label_*.png / text fallback) centered at bottom of tray
                Positioned(
                  bottom: 2 * scale,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: slotWidth * 0.85,
                      height: 16 * scale,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Image.asset(
                          item.labelPath,
                          height: 11 * scale,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                              child: Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10 * scale,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
