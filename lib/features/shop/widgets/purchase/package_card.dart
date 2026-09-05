import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/purchase_models.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.scale = 1.0,
    this.isGold = true,
  });

  final PurchasePackage package;
  final VoidCallback onTap;
  final double scale;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isGold
                ? const [
                    Color(0xFFFFCA28),
                    Color(0xFFFFA000),
                    Color(0xFFE65100),
                  ]
                : const [
                    Color(0xFF4FC3F7),
                    Color(0xFF039BE5),
                    Color(0xFF01579B),
                  ],
          ),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: isGold ? const Color(0xFFFFEE58) : const Color(0xFFB3E5FC),
            width: 1.8 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 7 * scale,
              offset: Offset(0, 3.5 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * scale),
          child: Stack(
            children: [
              // Radial sunburst glow behind center icon
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 95 * scale,
                    height: 95 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.38),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Main Card Layout
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 7 * scale,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TOP: Amount Pill (e.g. [Coin] 33k or [Diamond] 300)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6 * scale,
                        vertical: 2 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0424).withOpacity(0.38),
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              isGold
                                  ? 'assets/graphics/icon_coins.png'
                                  : 'assets/graphics/icon_diamond.png',
                              width: 12 * scale,
                              height: 12 * scale,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 2.5 * scale),
                            Text(
                              package.amount,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CENTER: 3D Item Asset with Base Platform/Pedestal Underneath
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Base Platform / Dark circular base beneath the icon
                            Positioned(
                              bottom: 4 * scale,
                              child: Container(
                                width: 56 * scale,
                                height: 16 * scale,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(
                                          56 * scale, 16 * scale)),
                                  gradient: RadialGradient(
                                    colors: [
                                      (isGold
                                              ? const Color(0xFF78350F)
                                              : const Color(0xFF0C4A6E))
                                          .withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isGold
                                              ? const Color(0xFFFFD54F)
                                              : const Color(0xFF7DD3FC))
                                          .withOpacity(0.25),
                                      blurRadius: 8 * scale,
                                      spreadRadius: 1 * scale,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 3D Coin Stack / Diamond Icon
                            Padding(
                              padding: EdgeInsets.only(bottom: 4 * scale),
                              child: Image.asset(
                                package.iconAsset,
                                height: 58 * scale,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  isGold
                                      ? Icons.monetization_on_rounded
                                      : Icons.diamond_rounded,
                                  size: 44 * scale,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // BOTTOM: Purple Price Button Pill
                    Container(
                      width: double.infinity,
                      height: 28 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6D28D9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(
                          color: const Color(0xFFC4B5FD),
                          width: 1.2 * scale,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6D28D9).withOpacity(0.55),
                            blurRadius: 4 * scale,
                            offset: Offset(0, 2 * scale),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            package.priceUsd,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5 * scale,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // TOP-RIGHT: Tags/Badges (HOT flame, POPULAR ribbon, BEST ribbon)
              if (package.badgeType != PackageBadgeType.none)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildBadge(package.badgeType, scale),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(PackageBadgeType type, double scale) {
    switch (type) {
      case PackageBadgeType.hot:
        return Padding(
          padding: EdgeInsets.all(2 * scale),
          child: Image.asset(
            'assets/graphics/purchase_screen/tags_badges/badge_hot_flame.png',
            width: 26 * scale,
            height: 26 * scale,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 4 * scale, vertical: 1.5 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
              child: Text(
                'HOT',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 7 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );

      case PackageBadgeType.popular:
        return SizedBox(
          width: 52 * scale,
          height: 20 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/graphics/purchase_screen/tags_badges/ribbon_bg_pink_popular.png',
                width: 52 * scale,
                height: 20 * scale,
                fit: BoxFit.fill,
              ),
              Positioned(
                top: 2 * scale,
                child: Text(
                  'POPULAR',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 7.5 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );

      case PackageBadgeType.best:
        return SizedBox(
          width: 46 * scale,
          height: 20 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/graphics/purchase_screen/tags_badges/ribbon_bg_red_best.png',
                width: 46 * scale,
                height: 20 * scale,
                fit: BoxFit.fill,
              ),
              Positioned(
                top: 2 * scale,
                child: Text(
                  'BEST',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );

      case PackageBadgeType.none:
        return const SizedBox.shrink();
    }
  }
}
