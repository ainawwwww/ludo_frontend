import 'package:flutter/material.dart';

/// Reusable 3D Purple Shelf Row Container:
/// Renders a row of items sitting directly on top of an illuminated 3D purple shelf ledge
/// with high quality 3D perspective, matching Images 1, 2, 3, 4 & 5.
class ShopShelfRow extends StatelessWidget {
  final List<Widget> children;
  final double scale;
  final double shelfHeight;

  const ShopShelfRow({
    super.key,
    required this.children,
    required this.scale,
    this.shelfHeight = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * scale),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. 3D Illuminated Purple Shelf Base Ledge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: shelfHeight * scale,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8042E8),
                    Color(0xFF551FB8),
                    Color(0xFF330B7A),
                    Color(0xFF1E044D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.25, 0.65, 1.0],
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFC79BFF),
                    width: 2 * scale,
                  ),
                  bottom: BorderSide(
                    color: const Color(0xFF10022B),
                    width: 1.5 * scale,
                  ),
                ),
                boxShadow: [
                  // Top neon edge illumination glow
                  BoxShadow(
                    color: const Color(0x889E6BFF),
                    blurRadius: 8 * scale,
                    offset: Offset(0, -2 * scale),
                  ),
                  // Bottom drop shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
            ),
          ),

          // 2. Row of items resting on the shelf ledge
          Padding(
            padding: EdgeInsets.only(bottom: (shelfHeight * 0.4) * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
