import 'package:flutter/material.dart';

/// Sunburst Card Frame Widget matching Figma assets in 12_ui_backgrounds/
/// Uses IconsbackgroundLargeInBlue.png for equipped/selected and
/// IconsbackgroundLargeInOrange.png for unequipped.
class SunburstCard extends StatelessWidget {
  final Widget child;
  final bool isEquipped;
  final double scale;
  final String title;

  const SunburstCard({
    super.key,
    required this.child,
    this.isEquipped = false,
    this.scale = 1.0,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Exact Card Frame Asset (Blue equipped / Orange unequipped)
          Positioned.fill(
            child: Image.asset(
              isEquipped
                  ? 'assets/graphics/shop/12_ui_backgrounds/IconsbackgroundLargeInBlue.png'
                  : 'assets/graphics/shop/12_ui_backgrounds/IconsbackgroundLargeInOrange.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isEquipped
                        ? [const Color(0xFF5BA4FC), const Color(0xFF2048A5)]
                        : [const Color(0xFFFF9B63), const Color(0xFFC7460A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
              ),
            ),
          ),

          // 2. Card Title Header
          if (title.isNotEmpty)
            Positioned(
              top: 2 * scale,
              left: 4 * scale,
              right: 4 * scale,
              height: 18 * scale,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.5 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Center 3D Content (Dice, Piece, Bubble)
          Positioned.fill(
            top: 20 * scale,
            bottom: 6 * scale,
            child: Center(child: child),
          ),

          // 4. Equipped Checkmark Badge
          if (isEquipped)
            Positioned(
              bottom: 2 * scale,
              right: 2 * scale,
              child: SizedBox(
                width: 20 * scale,
                height: 20 * scale,
                child: Image.asset(
                  'assets/graphics/shop/13_badges_selection_indicators/Group_1261153273.png',
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00E676),
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
