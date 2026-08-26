import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Screen 5: Table / Tile Screen:
/// - Top bar with History, Exchange, Diamonds, Coupon, Help, Close
/// - "Table | Tile" Segmented toggle
/// - Table Tab: 4-column board skins from 04b_table_board_skins_numbered_needs_naming
/// - Tile Tab: 4-column texture swatches from 05_tile_skins_TileTab
class TableTileScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const TableTileScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<TableTileScreen> createState() => _TableTileScreenState();
}

class _TableTileScreenState extends ConsumerState<TableTileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_SkinItem> _tables = const [
    _SkinItem(
      name: 'Crown Gold',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableOneTheme.png',
    ),
    _SkinItem(
      name: 'Pink Roses',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableThreeTheme.png',
    ),
    _SkinItem(
      name: 'Royal Emerald',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableFourTheme.png',
    ),
    _SkinItem(
      name: 'Golden Sun',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableFiveTheme.png',
    ),
    _SkinItem(
      name: 'Blue Sapphire',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableSixTheme.png',
    ),
    _SkinItem(
      name: 'Ruby Crest',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableSevenTheme.png',
    ),
    _SkinItem(
      name: 'Imperial Dragon',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableEightTheme.png',
    ),
    _SkinItem(
      name: 'Phoenix Flame',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableNineTheme.png',
    ),
    _SkinItem(
      name: 'Celestial Moon',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableTenTheme.png',
    ),
    _SkinItem(
      name: 'Royal Palace',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableElevenTheme.png',
    ),
    _SkinItem(
      name: 'Diamond Crest',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableTweleveTheme.png',
    ),
    _SkinItem(
      name: 'Vintage Baroque',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableThirteenTheme.png',
    ),
    _SkinItem(
      name: 'Mystic Velvet',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableFourteenTheme.png',
    ),
    _SkinItem(
      name: 'Classic Gold',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableFifteenTheme.png',
    ),
    _SkinItem(
      name: 'Midnight Luxury',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableSixteenTheme.png',
    ),
    _SkinItem(
      name: 'Imperial Crown',
      imageAsset:
          'assets/graphics/shop/04b_table_board_skins_numbered_needs_naming/TableThTheme.png',
    ),
  ];

  final List<_SkinItem> _tiles = const [
    _SkinItem(
      name: 'Classic',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile1.png',
    ),
    _SkinItem(
      name: 'Green Silk',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile2.png',
    ),
    _SkinItem(
      name: 'Carpet',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile3.png',
    ),
    _SkinItem(
      name: 'Purity',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile4.png',
    ),
    _SkinItem(
      name: 'Wood',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/image5.png',
    ),
    _SkinItem(
      name: 'Garden',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile6.png',
    ),
    _SkinItem(
      name: 'Egyptian',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile7.png',
    ),
    _SkinItem(
      name: 'Love Bow',
      imageAsset: 'assets/graphics/shop/05_tile_skins_TileTab/Tile8.png',
    ),
  ];

  int _equippedTable = 0;
  int _equippedTile = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
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

              // 2. Segmented Tabs: Table | Tile
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                child: _buildSegmentedTabBar(scale),
              ),
              SizedBox(height: 12 * scale),

              // 3. TabBarView for Table & Tile Grids
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(
                        items: _tables,
                        scale: scale,
                        equippedIdx: _equippedTable,
                        onSelect: (idx) =>
                            setState(() => _equippedTable = idx),
                      ),
                      _buildGrid(
                        items: _tiles,
                        scale: scale,
                        equippedIdx: _equippedTile,
                        onSelect: (idx) =>
                            setState(() => _equippedTile = idx),
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
          Tab(text: 'Table'),
          Tab(text: 'Tile'),
        ],
      ),
    );
  }

  Widget _buildGrid({
    required List<_SkinItem> items,
    required double scale,
    required int equippedIdx,
    required Function(int) onSelect,
  }) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 4;

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
                  padding: EdgeInsets.symmetric(horizontal: 2.5 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      onSelect(itemIdx);
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

                          // Center Table / Tile Artwork
                          Positioned.fill(
                            top: 20 * scale,
                            bottom: 6 * scale,
                            left: 6 * scale,
                            right: 6 * scale,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6 * scale),
                                child: Image.asset(
                                  item.imageAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.grid_view_rounded,
                                    color: Colors.white70,
                                    size: 32 * scale,
                                  ),
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(children: shelfWidgets),
    );
  }
}

class _SkinItem {
  final String name;
  final String imageAsset;

  const _SkinItem({
    required this.name,
    required this.imageAsset,
  });
}
