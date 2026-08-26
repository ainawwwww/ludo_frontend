import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Sticker Shop Tab matching Figma & reference screenshots:
/// - Segmented Tabs: 'Sticker Pack' | 'Single Sticker'
/// - 3D purple laptop/monitor display units on 3D purple shelves
class StickerShopTab extends StatefulWidget {
  const StickerShopTab({super.key});

  @override
  State<StickerShopTab> createState() => _StickerShopTabState();
}

class _StickerShopTabState extends State<StickerShopTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_StickerPackItem> _stickerPacks = const [
    _StickerPackItem(
      title: 'Emoji Express',
      priceText: '1999',
      isRoyalOnly: false,
      stickerAssets: [
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_smirk_wink.png',
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_crying.png',
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_laughing_tears.png',
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_shocked.png',
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_wide_eyed_fear.png',
        'assets/graphics/shop/10_sticker_skins/03_sticker_pack_emoji_faces/emoji_tongue_out_wink.png',
      ],
    ),
    _StickerPackItem(
      title: 'Tiger Cheer',
      priceText: '1999',
      isRoyalOnly: false,
      stickerAssets: [
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_holding_rose.png',
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_playing_piano.png',
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_peeking_playful.png',
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_thinking_paw_up.png',
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_shy_blushing.png',
        'assets/graphics/shop/10_sticker_skins/02_sticker_pack_tiger/tiger_angry_arms_crossed.png',
      ],
    ),
    _StickerPackItem(
      title: 'Fox Love',
      priceText: '1999',
      isRoyalOnly: false,
      stickerAssets: [
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_holding_heart.png',
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_confetti_celebration.png',
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_eating_icecream.png',
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_crying.png',
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_shy_blushing.png',
        'assets/graphics/shop/10_sticker_skins/01_sticker_pack_fox/fox_crying_loud.png',
      ],
    ),
    _StickerPackItem(
      title: 'Arabian VIP',
      priceText: 'Exclusive for royal users',
      isRoyalOnly: true,
      stickerAssets: [
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_celebrating.png',
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_crying_blue_tears.png',
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_sad_neutral.png',
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_wiping_tears.png',
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_green_sick.png',
        'assets/graphics/shop/10_sticker_skins/04_sticker_pack_royal_male/royal_man_heart_eyes.png',
      ],
    ),
    _StickerPackItem(
      title: 'Hijab Queens',
      priceText: 'Exclusive for royal users',
      isRoyalOnly: true,
      stickerAssets: [
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_raised_hands.png',
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_crying.png',
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_neutral.png',
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_angry.png',
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_celebrating.png',
        'assets/graphics/shop/10_sticker_skins/05_sticker_pack_royal_female/royal_woman_green_sick.png',
      ],
    ),
  ];

  final List<_SingleStickerItem> _singleStickers = const [
    _SingleStickerItem(
      name: 'Throw Confetti',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_frog_throw_confetti.png',
      priceText: 'Obtained',
      isObtained: true,
    ),
    _SingleStickerItem(
      name: 'Cool',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_cat_cool_sunglasses.png',
      priceText: '99',
    ),
    _SingleStickerItem(
      name: 'Cofee',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_cat_coffee.png',
      priceText: '99',
    ),
    _SingleStickerItem(
      name: 'Dance',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_fox_yay_flower.png',
      priceText: '99',
    ),
    _SingleStickerItem(
      name: 'Music Moment',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_penguin_music_moment.png',
      priceText: '99',
    ),
    _SingleStickerItem(
      name: 'Sorry',
      imageAsset: 'assets/graphics/shop/10_sticker_skins/06_single_stickers/single_penguin_sorry.png',
      priceText: '99',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Column(
      children: [
        // 1. Two Tabs: Sticker Pack | Single Sticker
        _buildSegmentedTabBar(scale),
        SizedBox(height: 10 * scale),

        // 2. TabBarView for Packs and Single Stickers
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStickerPacksList(scale),
              _buildSingleStickersList(scale),
            ],
          ),
        ),
      ],
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
          Tab(text: 'Sticker Pack'),
          Tab(text: 'Single Sticker'),
        ],
      ),
    );
  }

  Widget _buildStickerPacksList(double scale) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        children: _stickerPacks.map((pack) {
          return ShopShelfRow(
            scale: scale,
            shelfHeight: 20.0,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: SizedBox(
                    height: 128 * scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 3D Purple Display Screen Box
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A1988), Color(0xFF22084D)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: const Color(0xFF9E6BFF).withOpacity(0.7),
                                width: 1.5 * scale,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6 * scale,
                                  offset: Offset(0, 3 * scale),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 6 Sticker Emojis inside the Display Screen
                        Positioned.fill(
                          top: 10 * scale,
                          bottom: 26 * scale,
                          left: 16 * scale,
                          right: 16 * scale,
                          child: Center(
                            child: Wrap(
                              spacing: 16 * scale,
                              runSpacing: 8 * scale,
                              alignment: WrapAlignment.center,
                              children: pack.stickerAssets.map((asset) {
                                return Image.asset(
                                  asset,
                                  width: 30 * scale,
                                  height: 30 * scale,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.emoji_emotions_rounded,
                                    color: const Color(0xFFFFD369),
                                    size: 26 * scale,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        // Bottom Price / Exclusive Pill Button
                        Positioned(
                          bottom: 3 * scale,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: pack.isRoyalOnly
                                  ? 14 * scale
                                  : 16 * scale,
                              vertical: 3.5 * scale,
                            ),
                            decoration: BoxDecoration(
                              gradient: pack.isRoyalOnly
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF5E22B8),
                                        Color(0xFF38107D)
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFFF9B63),
                                        Color(0xFFF97023)
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: pack.isRoyalOnly
                                    ? const Color(0xFFCCA3FF)
                                    : const Color(0xFFFFD8B2),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!pack.isRoyalOnly) ...[
                                  Image.asset(
                                    'assets/graphics/icon_diamond.png',
                                    width: 14 * scale,
                                    height: 14 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                ],
                                Text(
                                  pack.priceText,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleStickersList(double scale) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        children: _singleStickers.map((sticker) {
          return ShopShelfRow(
            scale: scale,
            shelfHeight: 20.0,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: SizedBox(
                    height: 128 * scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 3D Purple Display Screen Box
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A1988), Color(0xFF22084D)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: const Color(0xFF9E6BFF).withOpacity(0.7),
                                width: 1.5 * scale,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6 * scale,
                                  offset: Offset(0, 3 * scale),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Title at top
                        Positioned(
                          top: 10 * scale,
                          child: Text(
                            sticker.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Center Single Sticker Artwork
                        Positioned.fill(
                          top: 24 * scale,
                          bottom: 24 * scale,
                          child: Center(
                            child: Image.asset(
                              sticker.imageAsset,
                              height: 52 * scale,
                              width: 52 * scale,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.pets_rounded,
                                color: Colors.white70,
                                size: 36 * scale,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Price / Obtained Pill Button
                        Positioned(
                          bottom: 3 * scale,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sticker.isObtained
                                  ? 20 * scale
                                  : 14 * scale,
                              vertical: 3.5 * scale,
                            ),
                            decoration: BoxDecoration(
                              gradient: sticker.isObtained
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF4A1988),
                                        Color(0xFF2A085C)
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFFF9B63),
                                        Color(0xFFF97023)
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: sticker.isObtained
                                    ? const Color(0xFF836DDF)
                                    : const Color(0xFFFFD8B2),
                                width: 1 * scale,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!sticker.isObtained) ...[
                                  Image.asset(
                                    'assets/graphics/icon_diamond.png',
                                    width: 14 * scale,
                                    height: 14 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                ],
                                Text(
                                  sticker.priceText,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StickerPackItem {
  final String title;
  final String priceText;
  final bool isRoyalOnly;
  final List<String> stickerAssets;

  const _StickerPackItem({
    required this.title,
    required this.priceText,
    required this.isRoyalOnly,
    required this.stickerAssets,
  });
}

class _SingleStickerItem {
  final String name;
  final String imageAsset;
  final String priceText;
  final bool isObtained;

  const _SingleStickerItem({
    required this.name,
    required this.imageAsset,
    required this.priceText,
    this.isObtained = false,
  });
}
