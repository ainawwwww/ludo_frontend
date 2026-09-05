import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_item_card.dart';
import 'package:ludo_vibe/features/shop/widgets/theme_wallpaper_card.dart';

class ShopHomeTab extends ConsumerStatefulWidget {
  final Function(int targetTabIndex) onNavigateToTab;

  const ShopHomeTab({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  ConsumerState<ShopHomeTab> createState() => _ShopHomeTabState();
}

class _ShopHomeTabState extends ConsumerState<ShopHomeTab> {
  late final PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<_PromoBannerData> _banners = const [
    _PromoBannerData(
      title: 'Skin Design Contest',
      subtitle: 'Co-Created Exclusive Community Skins',
      tag: 'HOT EVENT',
      gradientColors: [Color(0xFF6B2FD7), Color(0xFF43169E), Color(0xFF320E77)],
      iconData: Icons.auto_awesome_rounded,
      dateRange: '29/06/2026 - 07/07/2026',
    ),
    _PromoBannerData(
      title: 'Royal VIP Pass',
      subtitle: 'Unlock Dragon & Moon Chariot',
      tag: 'SEASON 4',
      gradientColors: [Color(0xFFB388FF), Color(0xFF7C4DFF), Color(0xFF651FFF)],
      iconData: Icons.military_tech_rounded,
      dateRange: 'Special 50% discount for Royal 3+',
    ),
    _PromoBannerData(
      title: 'Legendary Board Tiles',
      subtitle: 'Egyptian & Cyber arena sets',
      tag: 'NEW',
      gradientColors: [Color(0xFFFF9100), Color(0xFFFF6D00), Color(0xFFDD2C00)],
      iconData: Icons.dashboard_customize_rounded,
      dateRange: 'Limited edition seasonal board sets',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);

    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Promo Banner Carousel
          _buildBannerCarousel(scale),
          SizedBox(height: 10 * scale),

          // 2. Horizontal Quick-Access Category Row
          _buildQuickAccessCategories(scale),
          SizedBox(height: 14 * scale),

          // 3. Featured Tokens Section
          _buildSectionHeader(
            title: 'Featured Tokens',
            scale: scale,
            onSeeAllTap: () => widget.onNavigateToTab(1),
          ),
          SizedBox(height: 6 * scale),
          _buildTokenGrid(shopState.tokenItems.take(4).toList(), scale),
          SizedBox(height: 14 * scale),

          // 4. Popular Themes Section
          _buildSectionHeader(
            title: 'Popular Themes',
            scale: scale,
            onSeeAllTap: () => widget.onNavigateToTab(2),
          ),
          SizedBox(height: 6 * scale),
          _buildThemeGrid(shopState.basicThemes.take(2).toList(), scale),
          SizedBox(height: 14 * scale),

          // 5. Royal Exclusives Banner Highlight
          _buildRoyalHighlightBanner(scale),
          SizedBox(height: 16 * scale),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(double scale) {
    return Column(
      children: [
        SizedBox(
          height: 95 * scale,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: banner.gradientColors[1].withOpacity(0.4),
                      blurRadius: 6 * scale,
                      offset: Offset(0, 3 * scale),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 8 * scale,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6 * scale,
                              vertical: 1.5 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(6 * scale),
                            ),
                            child: Text(
                              banner.tag,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 8 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD369),
                              ),
                            ),
                          ),
                          SizedBox(height: 3 * scale),
                          Text(
                            banner.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            banner.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5 * scale,
                              color: const Color(0xFFE2C4FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Container(
                      padding: EdgeInsets.all(8 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        banner.iconData,
                        color: const Color(0xFFFFD369),
                        size: 20 * scale,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 5 * scale),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (idx) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 2.5 * scale),
              width: _currentBannerIndex == idx ? 12 * scale : 5 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: _currentBannerIndex == idx
                    ? const Color(0xFFFF9B63)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCategories(double scale) {
    final categories = [
      _CategoryChipData(
        title: 'Tokens',
        icon: Icons.casino_rounded,
        tabIndex: 1,
        color: const Color(0xFF6B2FD7),
      ),
      _CategoryChipData(
        title: 'Themes',
        icon: Icons.wallpaper_rounded,
        tabIndex: 2,
        color: const Color(0xFF00B0FF),
      ),
      _CategoryChipData(
        title: 'Tiles',
        icon: Icons.dashboard_rounded,
        tabIndex: 3,
        color: const Color(0xFF00E676),
      ),
      _CategoryChipData(
        title: 'Stickers',
        icon: Icons.sticky_note_2_rounded,
        tabIndex: 4,
        color: const Color(0xFFFF4081),
      ),
      _CategoryChipData(
        title: 'Royal VIP',
        icon: Icons.military_tech_rounded,
        tabIndex: 5,
        color: const Color(0xFFFFAB00),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: categories.map((cat) {
          return Padding(
            padding: EdgeInsets.only(right: 10 * scale),
            child: GestureDetector(
              onTap: () {
                SoundService().playButtonClick();
                widget.onNavigateToTab(cat.tabIndex);
              },
              child: Column(
                children: [
                  Container(
                    width: 44 * scale,
                    height: 44 * scale,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cat.color.withOpacity(0.7),
                          cat.color.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13 * scale),
                      border: Border.all(
                        color: cat.color.withOpacity(0.8),
                        width: 1 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cat.color.withOpacity(0.25),
                          blurRadius: 4 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: Icon(
                      cat.icon,
                      color: Colors.white,
                      size: 20 * scale,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    cat.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required double scale,
    required VoidCallback onSeeAllTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        GestureDetector(
          onTap: () {
            SoundService().playButtonClick();
            onSeeAllTap();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9B63),
                ),
              ),
              SizedBox(width: 1 * scale),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFFF9B63),
                size: 14 * scale,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenGrid(List<ShopItem> items, double scale) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8 * scale,
        mainAxisSpacing: 8 * scale,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ShopItemCard(item: items[index]);
      },
    );
  }

  Widget _buildThemeGrid(List<ShopItem> items, double scale) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8 * scale,
        mainAxisSpacing: 8 * scale,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ThemeWallpaperCard(item: items[index]);
      },
    );
  }

  Widget _buildRoyalHighlightBanner(double scale) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        widget.onNavigateToTab(5);
      },
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5E17EB), Color(0xFF280B52), Color(0xFF1B0538)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: const Color(0xFFFFD369),
            width: 1.2 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x55FFD369),
              blurRadius: 8 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/graphics/shop/badges_selection_indicators/Crown.png',
                        width: 14 * scale,
                        height: 14 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          'ROYAL EXCLUSIVES',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.5 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD369),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    'Imperial Dragon & Golden ORV',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    'Luxury entrance vehicles for VIP lords.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9 * scale,
                      color: const Color(0xFFD4C1FF),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD369), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                'EXPLORE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B0538),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerData {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> gradientColors;
  final IconData iconData;
  final String dateRange;

  const _PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.gradientColors,
    required this.iconData,
    required this.dateRange,
  });
}

class _CategoryChipData {
  final String title;
  final IconData icon;
  final int tabIndex;
  final Color color;

  const _CategoryChipData({
    required this.title,
    required this.icon,
    required this.tabIndex,
    required this.color,
  });
}
