import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Bubble Tab (Speech-Bubble Chat Frame Skins matching Token tab requirement):
/// 4-column grid of speech-bubble chat frame cards on 3D purple shelves.
class BubbleShopTab extends StatefulWidget {
  const BubbleShopTab({super.key});

  @override
  State<BubbleShopTab> createState() => _BubbleShopTabState();
}

class _BubbleShopTabState extends State<BubbleShopTab> {
  int _selectedFilterIndex = 0;
  int _equippedIndex = 0;

  final List<String> _filters = const [
    'All',
    'Diamond',
    'Activity',
    'Premium',
    'Featured',
  ];

  final List<_BubbleFrameItem> _bubbleFrames = const [
    _BubbleFrameItem(
      name: 'Classic',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-4.png',
    ),
    _BubbleFrameItem(
      name: 'Chick Bubble',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Rectangle.png',
    ),
    _BubbleFrameItem(
      name: 'Crown Glow',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-5.png',
    ),
    _BubbleFrameItem(
      name: 'Party Bubble',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-6.png',
    ),
    _BubbleFrameItem(
      name: 'Earth Frame',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Earth_power-3.png',
    ),
    _BubbleFrameItem(
      name: 'Golden Frame',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Earth_power-4.png',
    ),
    _BubbleFrameItem(
      name: 'Royal Frame',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Earth_power-5.png',
    ),
    _BubbleFrameItem(
      name: 'Nature Frame',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Earth_power-6.png',
    ),
    _BubbleFrameItem(
      name: 'Violet Star',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-7.png',
    ),
    _BubbleFrameItem(
      name: 'Silver Wave',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-8.png',
    ),
    _BubbleFrameItem(
      name: 'Emerald Shine',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-9.png',
    ),
    _BubbleFrameItem(
      name: 'Sunset Ribbon',
      imageAsset: 'assets/graphics/shop/02_token_speech_bubble_frames_BubbleTab/Classic-10.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);

    return Column(
      children: [
        // 1. Sub-Filter Chips
        _buildFilterChips(scale),
        SizedBox(height: 10 * scale),

        // 2. 4-Column Bubble Frames Grid on 3D Shelves
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: _buildShelvesRows(scale),
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

  List<Widget> _buildShelvesRows(double scale) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 4;

    for (int i = 0; i < _bubbleFrames.length; i += itemsPerRow) {
      final rowItems = _bubbleFrames.skip(i).take(itemsPerRow).toList();
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

                          // Center Bubble Frame Artwork
                          Positioned.fill(
                            top: 20 * scale,
                            bottom: 6 * scale,
                            left: 6 * scale,
                            right: 6 * scale,
                            child: Center(
                              child: Image.asset(
                                item.imageAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.chat_bubble_rounded,
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

class _BubbleFrameItem {
  final String name;
  final String imageAsset;

  const _BubbleFrameItem({
    required this.name,
    required this.imageAsset,
  });
}
