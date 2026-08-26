import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';
import 'package:ludo_vibe/features/shop/widgets/sunburst_card.dart';

/// Screen 2 (Dice Tab matching Screenshot 3 & Prompt):
/// 4-column Sunburst dice cards on 3D purple shelves.
class TokenShopTab extends ConsumerStatefulWidget {
  const TokenShopTab({super.key});

  @override
  ConsumerState<TokenShopTab> createState() => _TokenShopTabState();
}

class _TokenShopTabState extends ConsumerState<TokenShopTab> {
  int _selectedFilterIndex = 0;
  int _equippedIndex = 0;

  final List<String> _filters = const [
    'All',
    'Diamond',
    'Activity',
    'Premium',
    'Featured',
  ];

  final List<_DiceItem> _diceList = const [
    _DiceItem(
      name: 'Classic',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Classic.png',
      price: 0,
    ),
    _DiceItem(
      name: 'Fantasy Book',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Fantasy_Book.png',
      price: 800,
    ),
    _DiceItem(
      name: 'Warrior Helmet',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Metal.png',
      price: 1200,
    ),
    _DiceItem(
      name: 'Rosy Life',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Rosy_Life.png',
      price: 950,
    ),
    _DiceItem(
      name: 'Coffee',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Cofee.png',
      price: 600,
    ),
    _DiceItem(
      name: 'Icecream',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Icecream.png',
      price: 750,
    ),
    _DiceItem(
      name: 'Earth Power',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Earth_power.png',
      price: 1100,
    ),
    _DiceItem(
      name: 'Campfire',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Warm_Campfire.png',
      price: 850,
    ),
    _DiceItem(
      name: 'Blessing',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Blessing_Basket.png',
      price: 1300,
    ),
    _DiceItem(
      name: 'Chick',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Chick.png',
      price: 900,
    ),
    _DiceItem(
      name: 'Crystal',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Crystal.png',
      price: 1500,
    ),
    _DiceItem(
      name: 'Dessert',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Dessert.png',
      price: 700,
    ),
    _DiceItem(
      name: 'Leisure Kitty',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Leisure_kitty.png',
      price: 1000,
    ),
    _DiceItem(
      name: 'Wooden Case',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Wooden_Case.png',
      price: 650,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);

    return Column(
      children: [
        // 1. Sub-Filter Chips Row ('All', 'Diamond', 'Activity', 'Premium', 'Featured')
        _buildFilterChips(scale),
        SizedBox(height: 10 * scale),

        // 2. 4-Column Dice Cards on 3D Purple Shelves
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: _buildShelfRows(scale),
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
                      : const Color(0xFF130630).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9E6BFF)
                        : const Color(0xFF764BC0).withOpacity(0.35),
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

  List<Widget> _buildShelfRows(double scale) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 4;

    for (int i = 0; i < _diceList.length; i += itemsPerRow) {
      final rowItems = _diceList.skip(i).take(itemsPerRow).toList();
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
                  padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      setState(() => _equippedIndex = itemIdx);
                    },
                    child: SunburstCard(
                      isEquipped: isEquipped,
                      scale: scale,
                      title: item.name,
                      child: Image.asset(
                        item.imageAsset,
                        height: 52 * scale,
                        width: 52 * scale,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.casino_rounded,
                          color: Colors.white70,
                          size: 38 * scale,
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

    return shelfWidgets;
  }
}

class _DiceItem {
  final String name;
  final String imageAsset;
  final int price;

  const _DiceItem({
    required this.name,
    required this.imageAsset,
    required this.price,
  });
}
