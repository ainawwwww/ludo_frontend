import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/providers/board_theme_provider.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';
import 'package:ludo_vibe/features/game/widgets/reconstructed_board_widget.dart';

/// Board Themes Tab in Shop
/// 3-column square board theme cards resting on 3D purple shelves with live Riverpod state,
/// interactive purchase/equip flow, and full-resolution board preview dialog.
class ThemeShopTab extends ConsumerStatefulWidget {
  const ThemeShopTab({super.key});

  @override
  ConsumerState<ThemeShopTab> createState() => _ThemeShopTabState();
}

class _ThemeShopTabState extends ConsumerState<ThemeShopTab> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Owned',
    'Free',
    'Premium',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);

    final catalogAsync = ref.watch(themeCatalogProvider);
    final ownedThemes = ref.watch(ownedThemesProvider);
    final selectedThemeId = ref.watch(selectedThemeIdProvider);

    return Column(
      children: [
        // 1. Filter Chips Row
        _buildFilterChips(scale),
        SizedBox(height: 10 * scale),

        // 2. 3-Column Theme Cards on 3D Shelves
        Expanded(
          child: catalogAsync.when(
            data: (allThemes) {
              final filteredThemes = allThemes.where((t) {
                if (_selectedFilterIndex == 1) {
                  return ownedThemes.contains(t.id);
                } else if (_selectedFilterIndex == 2) {
                  return t.price == 0;
                } else if (_selectedFilterIndex == 3) {
                  return t.price > 0;
                }
                return true;
              }).toList();

              if (filteredThemes.isEmpty) {
                return Center(
                  child: Text(
                    'No themes found in this category',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12 * scale,
                      color: Colors.white60,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: _buildShelfRows(
                    themes: filteredThemes,
                    ownedThemes: ownedThemes,
                    selectedThemeId: selectedThemeId,
                    scale: scale,
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD200)),
            ),
            error: (err, _) => Center(
              child: Text(
                'Failed to load themes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  color: Colors.white70,
                ),
              ),
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

  List<Widget> _buildShelfRows({
    required List<LudoTheme> themes,
    required Set<String> ownedThemes,
    required String selectedThemeId,
    required double scale,
  }) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 3;

    for (int i = 0; i < themes.length; i += itemsPerRow) {
      final rowItems = themes.skip(i).take(itemsPerRow).toList();

      shelfWidgets.add(
        ShopShelfRow(
          scale: scale,
          shelfHeight: 20.0,
          children: List.generate(itemsPerRow, (colIdx) {
            if (colIdx < rowItems.length) {
              final theme = rowItems[colIdx];
              final isOwned = ownedThemes.contains(theme.id);
              final isEquipped = selectedThemeId == theme.id;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      _showThemePreviewDialog(theme, isOwned, isEquipped, scale);
                    },
                    child: AspectRatio(
                      aspectRatio: 0.70,
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
                                theme.name,
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

                          // Center Artwork (preview.png or fallback)
                          Positioned.fill(
                            top: 20 * scale,
                            bottom: 22 * scale,
                            left: 6 * scale,
                            right: 6 * scale,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6 * scale),
                                child: Image.asset(
                                  theme.previewAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.dashboard_rounded,
                                    color: Colors.white70,
                                    size: 36 * scale,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Bottom Status Pill (Price chip or Owned/Apply label)
                          Positioned(
                            bottom: 4 * scale,
                            left: 6 * scale,
                            right: 6 * scale,
                            child: Container(
                              height: 16 * scale,
                              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                              decoration: BoxDecoration(
                                color: isEquipped
                                    ? const Color(0xFF00E676).withOpacity(0.9)
                                    : isOwned
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF1B0F3A),
                                borderRadius: BorderRadius.circular(8 * scale),
                                border: Border.all(
                                  color: isEquipped
                                      ? Colors.white
                                      : isOwned
                                          ? const Color(0xFF81C784)
                                          : const Color(0xFFFFD200).withOpacity(0.5),
                                  width: 0.8 * scale,
                                ),
                              ),
                              child: Center(
                                child: isEquipped
                                    ? Text(
                                        'EQUIPPED',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 8 * scale,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      )
                                    : isOwned
                                        ? Text(
                                            'OWNED',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 8 * scale,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/graphics/profile/coin_icon.png',
                                                width: 10 * scale,
                                                height: 10 * scale,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.monetization_on,
                                                  size: 10 * scale,
                                                  color: const Color(0xFFFFD200),
                                                ),
                                              ),
                                              SizedBox(width: 3 * scale),
                                              Text(
                                                '${theme.price}',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 8.5 * scale,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFFFFD200),
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                          ),

                          // Equipped Checkmark Badge
                          if (isEquipped)
                            Positioned(
                              top: 2 * scale,
                              right: 2 * scale,
                              child: Container(
                                width: 18 * scale,
                                height: 18 * scale,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 13 * scale,
                                  color: Colors.white,
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

  void _showThemePreviewDialog(
    LudoTheme theme,
    bool isOwned,
    bool isEquipped,
    double scale,
  ) {
    // Pre-warm vector board representation to eliminate flicker
    ref.read(boardReconstructorServiceProvider).prewarmTheme(theme);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final owned = ref.watch(ownedThemesProvider).contains(theme.id);
            final equipped = ref.watch(selectedThemeIdProvider) == theme.id;
            final userCoins = ref.watch(shopProvider).userCoins;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 24 * scale),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C1354), Color(0xFF14082D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(
                    color: const Color(0xFF9E6BFF).withOpacity(0.5),
                    width: 1.5 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 24 * scale,
                      offset: Offset(0, 10 * scale),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Name and Close button
                    Row(
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(dialogCtx).pop(),
                          child: Container(
                            padding: EdgeInsets.all(4 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white70, size: 18 * scale),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14 * scale),

                    // Board Full Preview Card
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14 * scale),
                          border: Border.all(
                            color: const Color(0xFFFFD200).withOpacity(0.35),
                            width: 2 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10 * scale,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12 * scale),
                          child: ReconstructedBoardWidget(
                            theme: theme,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    // Action Button (Buy / Equip / Equipped)
                    SizedBox(
                      width: double.infinity,
                      height: 44 * scale,
                      child: equipped
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18 * scale),
                                  SizedBox(width: 8 * scale),
                                  Text(
                                    'CURRENTLY EQUIPPED',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : owned
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E676),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                  ),
                                  onPressed: () {
                                    SoundService().playButtonClick();
                                    ref.read(selectedThemeIdProvider.notifier).selectTheme(theme.id);
                                    Navigator.of(dialogCtx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${theme.name} equipped for next matches!'),
                                        backgroundColor: const Color(0xFF2E7D32),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'EQUIP THEME',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB300),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                  ),
                                  onPressed: () {
                                    SoundService().playButtonClick();
                                    if (userCoins < theme.price) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Not enough coins to purchase this theme!'),
                                          backgroundColor: Color(0xFFD32F2F),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = ref.read(ownedThemesProvider.notifier).buyTheme(theme);
                                    if (success) {
                                      Navigator.of(dialogCtx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${theme.name} purchased and equipped!'),
                                          backgroundColor: const Color(0xFF2E7D32),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/graphics/profile/coin_icon.png',
                                        width: 18 * scale,
                                        height: 18 * scale,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.monetization_on,
                                          color: Colors.black87,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 8 * scale),
                                      Text(
                                        'BUY FOR ${theme.price}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
