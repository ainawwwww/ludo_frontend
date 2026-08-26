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
    if (imagePath.contains('privatepng2')) return 0.95;
    if (imagePath.contains('1v1_png')) return 1.05;
    if (imagePath.contains('vip_png')) return 0.95;
    if (imagePath.contains('team_Png')) return 0.95;
    if (imagePath.contains('Tournament_png')) return 0.95;
    if (imagePath.contains('2 and 4 png')) return 1.0;
    if (imagePath.contains('4player_png')) return 1.0;
    if (imagePath.contains('Complex_png')) return 1.0;
    if (imagePath.contains('nightludo_png')) return 1.0;
    if (imagePath.contains('fight ludo png')) return 1.0;
    if (imagePath.contains('jungleludo_png')) return 1.05;
    if (imagePath.contains('snakes and ladder')) return 1.0;
    if (imagePath.contains('basic_png')) return 1.0;
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
                color: Colors.black.withValues(alpha: 0.20),
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
                    color: primaryColor.withValues(alpha: 0.7),
                    width: 1.5 * scale,
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
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
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.08),
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
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular((widget.borderRadius - 2) * scale),
                                topRight: Radius.circular((widget.borderRadius - 2) * scale),
                              ),
                            ),
                          ),
                        ),
                      // Sparkle 1 (Top-Right)
                      Positioned(
                        top: 8 * scale,
                        right: 8 * scale,
                        width: 13 * scale,
                        height: 13 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ),
                      // Sparkle 2 (Bottom-Left)
                      Positioned(
                        bottom: 8 * scale,
                        left: 8 * scale,
                        width: 11 * scale,
                        height: 11 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withValues(alpha: 0.65)),
                        ),
                      ),
                      // Sparkle 3 (Top-Left)
                      Positioned(
                        top: 16 * scale,
                        left: 12 * scale,
                        width: 8 * scale,
                        height: 8 * scale,
                        child: CustomPaint(
                          painter: SparklePainter(color: Colors.white.withValues(alpha: 0.65)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Illustration and Title content
              if (widget.layoutType == CardLayoutType.vertical) ...[
                // Illustration Asset - Cleanly positioned inside card
                Positioned(
                  top: isTallCard ? 6 * scale : 6 * scale,
                  left: isTallCard ? 6 * scale : 8 * scale,
                  right: isTallCard ? 6 * scale : 8 * scale,
                  bottom: isTallCard ? 36 * scale : 26 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: Alignment.center,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                // Card Title centered at bottom
                Positioned(
                  left: 4 * scale,
                  right: 4 * scale,
                  bottom: isTallCard ? 10 * scale : 7 * scale,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: widget.titleFontSize * scale,
                      fontWeight: FontWeight.w800,
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
                  top: 4 * scale,
                  left: 6 * scale,
                  width: 95 * scale,
                  bottom: 4 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: Alignment.center,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 104 * scale,
                  right: 8 * scale,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: (widget.titleFontSize + 1.5) * scale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
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
                  top: 4 * scale,
                  right: 6 * scale,
                  width: 90 * scale,
                  bottom: 4 * scale,
                  child: Transform.scale(
                    scale: imageScaleFactor,
                    alignment: Alignment.center,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 10 * scale,
                  right: 98 * scale,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: (widget.titleFontSize + 0.5) * scale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
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
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(Offset(cx, cy), rx * 0.45, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
