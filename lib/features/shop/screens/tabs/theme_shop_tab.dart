import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Screen 2 (The Theme / Board Skins Tab matching Image 2):
/// 3-column square board theme cards resting on 3D purple shelves with real-time equip syncing.
class ThemeShopTab extends ConsumerStatefulWidget {
  const ThemeShopTab({super.key});

  @override
  ConsumerState<ThemeShopTab> createState() => _ThemeShopTabState();
}

class _ThemeShopTabState extends ConsumerState<ThemeShopTab> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Diamond',
    'Activity',
    'Premium',
    'Featured',
  ];

  final List<_BoardThemeItem> _boardThemes = const [
    _BoardThemeItem(
      id: 'theme_green_silk',
      name: 'Classic',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Classic-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_golden_mountain',
      name: 'Warrior helmet',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Warrior_Helmet-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_sky_wheel',
      name: 'Lucky Chest',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Precious.png',
    ),
    _BoardThemeItem(
      id: 'theme_indigo_wallpaper',
      name: 'Indigo wallpaper',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Crystal-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_fantastic_lion',
      name: 'Dessert',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Icecream-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_bonfire',
      name: 'Point',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Cofee-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_cloudy_sky',
      name: 'Cloudy Sky',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Fantasy_Book-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_waterfall',
      name: 'Enchanted Hat',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Warm_Campfire-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_blue_moon',
      name: 'Lightning',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Earth_power-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_eternal_lighthouse',
      name: 'Eternal Light House',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Blessing_Basket-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_urban_twilight',
      name: 'Frost Fire Blade',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Chick-2.png',
    ),
    _BoardThemeItem(
      id: 'theme_spring_letter',
      name: 'Letter from spring',
      imageAsset:
          'assets/graphics/shop/04a_table_board_skins_named/Leisure_kitty-2.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return Column(
      children: [
        // 1. Sub-Filter Chips Row
        _buildFilterChips(scale),
        SizedBox(height: 10 * scale),

        // 2. 3-Column Square Board Theme Cards on 3D Shelves
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: _buildShelfRows(scale, shopState),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(double scale) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (idx) {
          final isSelected = _selectedFilterIndex == idx;
          return Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: GestureDetector(
              onTap: () {
                SoundService().playButtonClick();
                setState(() => _selectedFilterIndex = idx);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 4.5 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF5E22B8), Color(0xFF38107D)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : const Color(0xFF130630).withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9E6BFF)
                        : const Color(0xFF764BC0).withValues(alpha: 0.35),
                    width: 1 * scale,
                  ),
                ),
                child: Text(
                  _filters[idx],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5 * scale,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFFCCA3FF),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildShelfRows(double scale, ShopState shopState) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 3;

    for (int i = 0; i < _boardThemes.length; i += itemsPerRow) {
      final rowItems = _boardThemes.skip(i).take(itemsPerRow).toList();

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final themeDef = rowItems[colIdx];
              final shopItem = shopState.items.firstWhere(
                (item) => item.id == themeDef.id,
                orElse: () => ShopItem(
                  id: themeDef.id,
                  name: themeDef.name,
                  category: ShopCategory.theme,
                  imageAsset: themeDef.imageAsset,
                  price: 0,
                  currencyType: CurrencyType.free,
                ),
              );

              final isEquipped = shopItem.isEquipped;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      final itemToEquip = shopItem.copyWith(
                        imageAsset: themeDef.imageAsset,
                        name: themeDef.name,
                      );
                      ref.read(shopProvider.notifier).equipItem(itemToEquip);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${themeDef.name} board theme equipped!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF7C4DFF),
                          duration: const Duration(milliseconds: 1400),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 0.72,
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
                                themeDef.name,
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

                          // Center Board Skin Artwork
                          Positioned.fill(
                            top: 20 * scale,
                            bottom: 6 * scale,
                            left: 6 * scale,
                            right: 6 * scale,
                            child: Center(
                              child: Image.asset(
                                themeDef.imageAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.grid_view_rounded,
                                  color: Colors.white70,
                                  size: 38 * scale,
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
                                width: 20 * scale,
                                height: 20 * scale,
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

class _BoardThemeItem {
  final String id;
  final String name;
  final String imageAsset;

  const _BoardThemeItem({
    required this.id,
    required this.name,
    required this.imageAsset,
  });
}
