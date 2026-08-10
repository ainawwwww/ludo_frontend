import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';

enum CardLayoutType {
  vertical,
  horizontalLeftImage,
  horizontalRightImage,
}

class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.backgroundImagePath,
    this.onTap,
    this.borderRadius = 16.0,
    this.titleFontSize = 13.0,
    this.titleFontWeight = FontWeight.bold,
    this.gradientColors,
    this.layoutType = CardLayoutType.vertical,
  });

  final String title;
  final String imagePath;
  final String? backgroundImagePath;
  final VoidCallback? onTap;
  final double borderRadius;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final List<Color>? gradientColors;
  final CardLayoutType layoutType;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  double _getImageScaleFactor(String imagePath) {
    if (imagePath.contains('privatepng2')) return 1.25;
    if (imagePath.contains('1v1_png')) return 1.18;
    if (imagePath.contains('vip_png')) return 0.92;
    if (imagePath.contains('team_Png')) return 1.08;
    if (imagePath.contains('4player_png')) return 1.05;
    if (imagePath.contains('Complex_png')) return 1.05;
    if (imagePath.contains('nightludo_png')) return 1.05;
    if (imagePath.contains('fight ludo png')) return 1.05;
    if (imagePath.contains('jungleludo_png')) return 1.10;
    if (imagePath.contains('snakes and ladder')) return 1.08;
    if (imagePath.contains('basic_png')) return 1.05;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    // Default gradient colors if not provided
    final colors = widget.gradientColors ?? const [Color(0xFF5641F8), Color(0xFF36289E)];
    final primaryColor = colors.first;

    final isTallCard = widget.layoutType == CardLayoutType.vertical &&
        (widget.title == '1 VS 1' || widget.title.contains('Jungle'));
    final imageScaleFactor = _getImageScaleFactor(widget.imagePath);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                offset: const Offset(0, 4),
                blurRadius: 6 * scale,
              ),
            ],
            image: widget.backgroundImagePath != null
                ? DecorationImage(
                    image: AssetImage(widget.backgroundImagePath!),
                    fit: BoxFit.fill,
                  )
                : null,
            gradient: widget.backgroundImagePath == null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  )
                : null,
            border: widget.backgroundImagePath == null
                ? Border.all(
                    color: primaryColor.withOpacity(0.7),
                    width: 1.5 * scale,
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allows 3D pop-out overflow effect!
            fit: StackFit.expand,
            children: [
              // Sparkles & decorative shine
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular((widget.borderRadius - 1.5) * scale),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Glassmorphic top-left diagonal shine reflection overlay for non-image cards
                      if (widget.backgroundImagePath == null)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.22),
                                  Colors.white.withOpacity(0.08),
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.25, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      // Inner top bevel highlight for non-image cards
                      if (widget.backgroundImagePath == null)
                        Positioned(
                          top: 1,
                          left: 1,
                          right: 1,
                          height: 1 * scale,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular((widget.borderRadius - 2) * scale),
                                topRight: Radius.circular((widget.borderRadius - 2) * scale),
                              ),
                            ),
                          ),
                        ),
                      // Sparkle 1 (Top-Right)
                      Positioned(
                        top: 10 * scale,
                        right: 10 * scale,
                        width: 13 * scale,
                        height: 13 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withOpacity(0.85)),
                        ),
                      ),
                      // Sparkle 2 (Bottom-Left)
                      Positioned(
                        bottom: 10 * scale,
                        left: 10 * scale,
                        width: 11 * scale,
                        height: 11 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withOpacity(0.65)),
                        ),
                      ),
                      // Sparkle 3 (Top-Left)
                      Positioned(
                        top: 20 * scale,
                        left: 16 * scale,
                        width: 8 * scale,
                        height: 8 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withOpacity(0.65)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Unclipped Illustration and Title content to allow 3D pop-out!
              if (widget.layoutType == CardLayoutType.vertical) ...[
                // Illustration Asset - Pop-out only at top, balanced scale & padding
                Positioned(
                  top: isTallCard ? -16 * scale : -12 * scale,
                  left: isTallCard ? 4 * scale : 6 * scale,
                  right: isTallCard ? 4 * scale : 6 * scale,
                  bottom: isTallCard ? 44 * scale : 32 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: isTallCard ? Alignment.center : Alignment.bottomCenter,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: isTallCard ? Alignment.center : Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Card Title centered at bottom with clean elevation off bottom border
                Positioned(
                  left: 6 * scale,
                  right: 6 * scale,
                  bottom: isTallCard ? 14 * scale : 10 * scale,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: widget.titleFontSize * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(0, 1.5),
                          blurRadius: 3,
                        ),
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 0),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (widget.layoutType == CardLayoutType.horizontalLeftImage) ...[
                // Horizontal Left Image layout (used for 2&4 Players)
                Positioned(
                  top: -18 * scale,
                  left: 4 * scale,
                  width: 100 * scale,
                  bottom: 4 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 106 * scale,
                  right: 8 * scale,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: (widget.titleFontSize + 1.5) * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1.5),
                            blurRadius: 3,
                          ),
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 0),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (widget.layoutType == CardLayoutType.horizontalRightImage) ...[
                // Horizontal Right Image layout
                Positioned(
                  top: -16 * scale,
                  right: 4 * scale,
                  width: 88 * scale,
                  bottom: 4 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 8 * scale,
                  right: 90 * scale,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: (widget.titleFontSize + 0.5) * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1.5),
                            blurRadius: 3,
                          ),
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 0),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  const SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2;
    final ry = size.height / 2;

    path.moveTo(cx, cy - ry);
    path.quadraticBezierTo(cx, cy, cx + rx, cy);
    path.quadraticBezierTo(cx, cy, cx, cy + ry);
    path.quadraticBezierTo(cx, cy, cx - rx, cy);
    path.quadraticBezierTo(cx, cy, cx, cy - ry);
    path.close();

    canvas.drawPath(path, paint);

    // Center glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(Offset(cx, cy), rx * 0.45, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
