import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';
import 'package:ludo_vibe/shared/widgets/top_bar.dart';

class GoldShopScreen extends StatefulWidget {
  const GoldShopScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<GoldShopScreen> createState() => _GoldShopScreenState();
}

class _GoldShopScreenState extends State<GoldShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_ShopPack> _goldPacks = const [
    _ShopPack(
        id: 'g1',
        amount: '10,000',
        price: '\$0.99',
        iconAsset: 'assets/graphics/icon_coins.png'),
    _ShopPack(
        id: 'g2',
        amount: '50,000',
        price: '\$3.99',
        iconAsset: 'assets/graphics/icon_coins.png',
        badge: 'POPULAR'),
    _ShopPack(
        id: 'g3',
        amount: '150,000',
        price: '\$9.99',
        iconAsset: 'assets/graphics/icon_coins.png',
        badge: 'BEST VALUE'),
    _ShopPack(
        id: 'g4',
        amount: '500,000',
        price: '\$29.99',
        iconAsset: 'assets/graphics/icon_coins.png'),
    _ShopPack(
        id: 'g5',
        amount: '1,500,000',
        price: '\$79.99',
        iconAsset: 'assets/graphics/icon_coins.png'),
    _ShopPack(
        id: 'g6',
        amount: '5,000,000',
        price: '\$199.99',
        iconAsset: 'assets/graphics/icon_coins.png',
        badge: 'VIP MEGA'),
  ];

  final List<_ShopPack> _diamondPacks = const [
    _ShopPack(
        id: 'd1',
        amount: '50 Gems',
        price: '\$0.99',
        iconAsset: 'assets/graphics/icon_diamond.png'),
    _ShopPack(
        id: 'd2',
        amount: '250 Gems',
        price: '\$3.99',
        iconAsset: 'assets/graphics/icon_diamond.png',
        badge: 'HOT'),
    _ShopPack(
        id: 'd3',
        amount: '800 Gems',
        price: '\$9.99',
        iconAsset: 'assets/graphics/icon_diamond.png',
        badge: 'BEST VALUE'),
    _ShopPack(
        id: 'd4',
        amount: '2,500 Gems',
        price: '\$29.99',
        iconAsset: 'assets/graphics/icon_diamond.png'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBuyPack(_ShopPack pack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchased ${pack.amount} for ${pack.price}!'),
        backgroundColor: const Color(0xFF56AB2F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            SizedBox(height: 8 * scale),

            // Header Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 22 * scale),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'RESOURCE SHOP',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 18 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * scale),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24 * scale),
              height: 40 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF0C073E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20 * scale),
                border:
                    Border.all(color: AppColors.primaryBorder.withOpacity(0.4)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.leagueCardGradient,
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Gold Coins'),
                  Tab(text: 'Diamonds'),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPacksGrid(_goldPacks, scale),
                  _buildPacksGrid(_diamondPacks, scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacksGrid(List<_ShopPack> packs, double scale) {
    return GridView.builder(
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14 * scale,
        mainAxisSpacing: 14 * scale,
        childAspectRatio: 0.85,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.listItemGradient,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: pack.badge != null
                  ? const Color(0xFFFFD369)
                  : AppColors.primaryBorder.withOpacity(0.5),
              width: pack.badge != null ? 2 * scale : 1 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6 * scale,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content Column
              Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8 * scale),
                    Image.asset(pack.iconAsset,
                        width: 44 * scale, height: 44 * scale),
                    SizedBox(height: 8 * scale),
                    Text(
                      pack.amount,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 16 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    OrangeButton(
                      text: pack.price,
                      onPressed: () => _onBuyPack(pack),
                      width: double.infinity,
                      height: 36 * scale,
                    ),
                  ],
                ),
              ),

              // Badge Pill
              if (pack.badge != null)
                Positioned(
                  top: 8 * scale,
                  right: 8 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale, vertical: 2 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD369),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      pack.badge!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0C073E),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShopPack {
  final String id;
  final String amount;
  final String price;
  final String iconAsset;
  final String? badge;

  const _ShopPack({
    required this.id,
    required this.amount,
    required this.price,
    required this.iconAsset,
    this.badge,
  });
}
