import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Screen 2 (Token Tab / 4-Piece Color Sets Tab):
/// 4-column token cards with 4 player pieces per set resting on 3D purple shelves with real-time equip syncing.
class TileShopTab extends ConsumerStatefulWidget {
  const TileShopTab({super.key});

  @override
  ConsumerState<TileShopTab> createState() => _TileShopTabState();
}

class _TileShopTabState extends ConsumerState<TileShopTab> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Diamond',
    'Activity',
    'Premium',
    'Featured',
  ];

  static const List<_TokenPieceDef> _tokenDefs = [
    _TokenPieceDef(
      id: 'token_classic',
      name: 'Classic Pieces',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Classic.png',
    ),
    _TokenPieceDef(
      id: 'token_chick',
      name: 'Chick Set',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Chick-4.png',
    ),
    _TokenPieceDef(
      id: 'token_coffee',
      name: 'Coffee Set',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Cofee-3.png',
    ),
    _TokenPieceDef(
      id: 'token_blessing_basket',
      name: 'Blessing Basket',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Blessing_Basket-3.png',
    ),
    _TokenPieceDef(
      id: 'token_desert_hammer',
      name: 'Desert Hammer',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Desert_Hammer-2.png',
    ),
    _TokenPieceDef(
      id: 'token_earth_power',
      name: 'Earth Power',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Earth_power-7.png',
    ),
    _TokenPieceDef(
      id: 'token_fantasy_book',
      name: 'Fantasy Book',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Fantasy_Book-3.png',
    ),
    _TokenPieceDef(
      id: 'token_ice_cream',
      name: 'Ice Cream',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Icecream-3.png',
    ),
    _TokenPieceDef(
      id: 'token_leisure_kitty',
      name: 'Leisure Kitty',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Leisure_kitty-3.png',
    ),
    _TokenPieceDef(
      id: 'token_rosy_life',
      name: 'Rosy Life',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Rosy_Life-3.png',
    ),
    _TokenPieceDef(
      id: 'token_warm_campfire',
      name: 'Warm Campfire',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Warm_Campfire-3.png',
    ),
    _TokenPieceDef(
      id: 'token_wooden_case',
      name: 'Wooden Case',
      imageAsset:
          'assets/graphics/shop/03_piece_color_sets_TokenTab/Wooden_Case-2.png',
    ),
    _TokenPieceDef(
      id: 'token_crystal',
      name: 'Crystal Set',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Crystal.png',
    ),
    _TokenPieceDef(
      id: 'token_dessert',
      name: 'Dessert Set',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Dessert.png',
    ),
    _TokenPieceDef(
      id: 'token_warrior_helmet',
      name: 'Warrior Helmet',
      imageAsset: 'assets/graphics/shop/01_dice_skins_DiceTab/Metal.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return Column(
      children: [
        // 1. Sub-Filter Chips Row ('All', 'Diamond', 'Activity', 'Premium', 'Featured')
        _buildFilterChips(scale),
        SizedBox(height: 10 * scale),

        // 2. 4-Column Token Cards on 3D Purple Shelves
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

  List<Widget> _buildShelfRows(double scale, ShopState shopState) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 4;

    for (int i = 0; i < _tokenDefs.length; i += itemsPerRow) {
      final rowItems = _tokenDefs.skip(i).take(itemsPerRow).toList();

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final tokenDef = rowItems[colIdx];
              final shopItem = shopState.items.firstWhere(
                (item) => item.id == tokenDef.id,
                orElse: () => ShopItem(
                  id: tokenDef.id,
                  name: tokenDef.name,
                  category: ShopCategory.token,
                  imageAsset: tokenDef.imageAsset,
                  price: 0,
                  currencyType: CurrencyType.free,
                ),
              );

              final isEquipped = shopItem.isEquipped;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      ref.read(shopProvider.notifier).equipItem(shopItem);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${tokenDef.name} pawns equipped for gameplay!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF7C4DFF),
                          duration: const Duration(milliseconds: 1400),
                        ),
                      );
                    },
                    child: _buildTokenCard(tokenDef, isEquipped, scale),
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

  Widget _buildTokenCard(_TokenPieceDef token, bool isEquipped, double scale) {
    return Container(
      height: 94 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF1E0A44),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(
          color: isEquipped
              ? const Color(0xFF56AB2F)
              : const Color(0xFF764BC0).withOpacity(0.55),
          width: isEquipped ? 2 * scale : 1 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: isEquipped
                ? const Color(0x6656AB2F)
                : Colors.black.withOpacity(0.35),
            blurRadius: isEquipped ? 8 * scale : 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Token Piece Graphic
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4 * scale),
              child: Center(
                child: Image.asset(
                  token.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.token_rounded,
                    color: Colors.amber,
                    size: 32 * scale,
                  ),
                ),
              ),
            ),
          ),

          // Token Name Label
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 4 * scale,
              vertical: 3 * scale,
            ),
            decoration: BoxDecoration(
              color: isEquipped
                  ? const Color(0xFF56AB2F).withOpacity(0.85)
                  : const Color(0xFF13042E).withOpacity(0.85),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(9 * scale),
                bottomRight: Radius.circular(9 * scale),
              ),
            ),
            child: Text(
              isEquipped ? 'EQUIPPED' : token.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5 * scale,
                fontWeight: isEquipped ? FontWeight.bold : FontWeight.w600,
                color: isEquipped ? Colors.white : const Color(0xFFCCA3FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenPieceDef {
  final String id;
  final String name;
  final String imageAsset;

  const _TokenPieceDef({
    required this.id,
    required this.name,
    required this.imageAsset,
  });
}
