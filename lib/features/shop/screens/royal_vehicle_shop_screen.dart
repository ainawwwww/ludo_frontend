import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_background.dart';
import 'package:ludo_vibe/features/shop/widgets/shop_shelf_row.dart';

/// Royal Vehicle Shop Screen matching Screenshot 2 & Prompt:
/// - Top Bar with Diamond capsule & Close X button
/// - Hero 3D Stage / Pedestal displaying current vehicle preview with "No vehicle is equipped"
/// - 2-column wide vehicle cards on 3D purple shelves
class RoyalVehicleShopScreen extends ConsumerStatefulWidget {
  const RoyalVehicleShopScreen({super.key});

  @override
  ConsumerState<RoyalVehicleShopScreen> createState() =>
      _RoyalVehicleShopScreenState();
}

class _RoyalVehicleShopScreenState
    extends ConsumerState<RoyalVehicleShopScreen> {
  int _equippedIndex = 0;

  final List<_VehicleItem> _vehicles = const [
    _VehicleItem(
      name: 'Empty',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalCar.png',
      isEmptySlot: true,
    ),
    _VehicleItem(
      name: 'Cyber Supercar',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalCar.png',
    ),
    _VehicleItem(
      name: 'Royal Lion',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalLion.png',
    ),
    _VehicleItem(
      name: 'Luxury Yacht',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalYacht.png',
    ),
    _VehicleItem(
      name: 'Fighter Jet',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalFighterJet.png',
    ),
    _VehicleItem(
      name: 'White Tiger',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalTiger.png',
    ),
    _VehicleItem(
      name: 'Gorgeous Carriage',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalCarrage.png',
    ),
    _VehicleItem(
      name: 'Winged Lion',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalLionWithWings.png',
    ),
    _VehicleItem(
      name: 'Golden Jeep',
      imageAsset: 'assets/graphics/shop/09_royal_vehicles/RoyalJeep.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);
    final activeVehicle = _vehicles[_equippedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0A001C),
      body: ShopSpotlightBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar (Diamond capsule + Close X button)
              _buildTopBar(context, shopState.userDiamonds, scale),
              SizedBox(height: 4 * scale),

              // 2. Hero 3D Stage / Pedestal Preview
              _buildHeroStage(activeVehicle, scale),
              SizedBox(height: 8 * scale),

              // 3. 2-Column Wide Vehicle Cards on 3D Shelves
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Column(
                    children: _buildShelfRows(scale),
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
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 32 * scale),

          // Center Diamond Counter Capsule
          Container(
            height: 30 * scale,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF130630).withOpacity(0.9),
              borderRadius: BorderRadius.circular(15 * scale),
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
                  width: 18 * scale,
                  height: 18 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '$diamonds',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Container(
                  width: 18 * scale,
                  height: 18 * scale,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF9B63), Color(0xFFF97023)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 13 * scale,
                  ),
                ),
              ],
            ),
          ),

          // Right Close (X) Button
          GestureDetector(
            onTap: () {
              SoundService().playButtonClick();
              context.pop();
            },
            child: Container(
              width: 30 * scale,
              height: 30 * scale,
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
                size: 18 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStage(_VehicleItem activeVehicle, double scale) {
    final bool isEmpty = activeVehicle.isEmptySlot;

    return Container(
      width: double.infinity,
      height: 145 * scale,
      margin: EdgeInsets.symmetric(horizontal: 14 * scale),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background spotlight radial beam
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9E6BFF).withOpacity(0.35),
                    const Color(0xFF5E22B8).withOpacity(0.1),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          // 3D Illuminated Stage Base Platform
          Positioned(
            bottom: 12 * scale,
            child: Container(
              width: 220 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9E6BFF), Color(0xFF5E22B8), Color(0xFF280B52)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(220 * scale, 48 * scale),
                ),
                border: Border.all(
                  color: const Color(0xFFE2C4FF),
                  width: 2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xAA9E6BFF),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
            ),
          ),

          // Vehicle 3D Artwork Preview
          Positioned(
            top: 6 * scale,
            child: Opacity(
              opacity: isEmpty ? 0.45 : 1.0,
              child: Image.asset(
                activeVehicle.imageAsset,
                height: 85 * scale,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white70,
                  size: 60 * scale,
                ),
              ),
            ),
          ),

          // Vehicle Name Pill Badge / 'No vehicle is equipped'
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 3.5 * scale,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF551FB8), Color(0xFF280B52)],
                ),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: const Color(0xFFCCA3FF).withOpacity(0.7),
                  width: 1 * scale,
                ),
              ),
              child: Text(
                isEmpty ? 'No vehicle is equipped' : activeVehicle.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShelfRows(double scale) {
    final List<Widget> shelfWidgets = [];
    const int itemsPerRow = 2;

    for (int i = 0; i < _vehicles.length; i += itemsPerRow) {
      final rowItems = _vehicles.skip(i).take(itemsPerRow).toList();
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
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                  child: GestureDetector(
                    onTap: () {
                      SoundService().playButtonClick();
                      setState(() => _equippedIndex = itemIdx);
                    },
                    child: AspectRatio(
                      aspectRatio: 1.85, // Wide horizontal card
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

                          // Center Vehicle Artwork
                          Positioned.fill(
                            top: 18 * scale,
                            bottom: 4 * scale,
                            left: 8 * scale,
                            right: 8 * scale,
                            child: Center(
                              child: Opacity(
                                opacity: item.isEmptySlot ? 0.5 : 1.0,
                                child: Image.asset(
                                  item.imageAsset,
                                  height: 46 * scale,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.directions_car,
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
                                width: 18 * scale,
                                height: 18 * scale,
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

class _VehicleItem {
  final String name;
  final String imageAsset;
  final bool isEmptySlot;

  const _VehicleItem({
    required this.name,
    required this.imageAsset,
    this.isEmptySlot = false,
  });
}
