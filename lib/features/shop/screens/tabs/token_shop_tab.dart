import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';
import 'package:ludo_vibe/features/shop/widgets/sunburst_card.dart';

/// Screen 2 (Dice & Token Tab matching UI/UX design):
/// 4-column Sunburst dice/token cards on 3D purple shelves with real-time equip syncing.
class TokenShopTab extends ConsumerStatefulWidget {
  const TokenShopTab({super.key});

  @override
  ConsumerState<TokenShopTab> createState() => _TokenShopTabState();
}

class _TokenShopTabState extends ConsumerState<TokenShopTab> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Diamond',
    'Activity',
    'Premium',
    'Featured',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);
    final diceItems = shopState.diceItems;

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
              children: _buildShelfRows(scale, diceItems),
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

  List<Widget> _buildShelfRows(double scale, List<ShopItem> diceItems) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 4;

    for (int i = 0; i < diceItems.length; i += itemsPerRow) {
      final rowItems = diceItems.skip(i).take(itemsPerRow).toList();

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final item = rowItems[colIdx];
              final isEquipped = item.isEquipped;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      ref.read(shopProvider.notifier).equipItem(item);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.name} dice skin equipped!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF7C4DFF),
                          duration: const Duration(milliseconds: 1400),
                        ),
                      );
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
