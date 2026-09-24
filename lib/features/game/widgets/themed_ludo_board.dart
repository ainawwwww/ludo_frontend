import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/widgets/reconstructed_board_widget.dart';

/// Data representation for a piece to be rendered on the themed board
class ThemedBoardPiece {
  final String id;
  final PlayerColor playerColor;
  final bool isInBase;
  final int baseSlotIndex; // 0..3
  final int? gridCol; // 0..14 (if on track)
  final int? gridRow; // 0..14 (if on track)
  final bool isValidMove;
  final bool isSelected;
  final VoidCallback? onTap;
  final int stackCount;

  const ThemedBoardPiece({
    required this.id,
    required this.playerColor,
    this.isInBase = false,
    this.baseSlotIndex = 0,
    this.gridCol,
    this.gridRow,
    this.isValidMove = false,
    this.isSelected = false,
    this.onTap,
    this.stackCount = 1,
  });
}

/// Themed Ludo Board Widget
/// Renders reconstructed vector board from manifest SVG components and positions tokens accurately using manifest grid fractions.
/// Keeps board vector artwork and tokens inside one Transform (Requirement 3).
class ThemedLudoBoard extends StatelessWidget {
  final LudoTheme theme;
  final List<ThemedBoardPiece> pieces;
  final double boardRotation; // in radians
  final Animation<double>? bounceAnimation;
  final Widget? centerChild;
  final bool showGridOverlay;
  final bool showLaneHighlights;
  final String? walkingPieceId;
  final (int row, int col)? walkingTileCoord;
  final PlayerColor? walkingColor;

  const ThemedLudoBoard({
    super.key,
    required this.theme,
    required this.pieces,
    this.boardRotation = 0.0,
    this.bounceAnimation,
    this.centerChild,
    this.showGridOverlay = false,
    this.showLaneHighlights = false,
    this.walkingPieceId,
    this.walkingTileCoord,
    this.walkingColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        if (size <= 0) return const SizedBox.shrink();

        final g = theme.grid;
        final origin = Offset(g.left * size, g.top * size);
        final cell = (g.size * size) / 15.0;

        Offset cellCenter(int col, int row) {
          return origin + Offset((col + 0.5) * cell, (row + 0.5) * cell);
        }

        Offset homeSlotCenter(Seat seat, int slotIndex) {
          final slotOffset = (slotIndex >= 0 && slotIndex < theme.homeSlots.length)
              ? theme.homeSlots[slotIndex]
              : const Offset(1.5, 1.5);
          return origin + (seat.quadrantOrigin + slotOffset) * cell;
        }

        // Token diameter sized dynamically to fit cell
        final tokenSize = cell * 0.72;

        // Group active track pieces by (col, row) to display stack badges
        final trackPiecesMap = <String, List<ThemedBoardPiece>>{};
        final basePieces = <ThemedBoardPiece>[];

        for (final p in pieces) {
          if (p.id == walkingPieceId) continue; // Don't draw old position while walking
          if (p.isInBase) {
            basePieces.add(p);
          } else if (p.gridCol != null && p.gridRow != null) {
            final key = '${p.gridCol}_${p.gridRow}';
            trackPiecesMap.putIfAbsent(key, () => []).add(p);
          }
        }

        // Requirement 3: Single Transform wrapper around board image AND all tokens/overlays
        return Transform.rotate(
          angle: boardRotation,
          alignment: Alignment.center,
          child: RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  // Layer 1: Reconstructed Vector Board Background (Exact SVG components from manifest)
                  Positioned.fill(
                    child: ReconstructedBoardWidget(
                      theme: theme,
                      size: size,
                    ),
                  ),

                  // Optional Debug / Gallery Grid Overlay
                  if (showGridOverlay)
                    CustomPaint(
                      size: Size(size, size),
                      painter: _GridOverlayPainter(
                        origin: origin,
                        cellSize: cell,
                      ),
                    ),

                  // Optional Debug / Gallery Lane Highlights
                  if (showLaneHighlights)
                    CustomPaint(
                      size: Size(size, size),
                      painter: _LaneHighlightsPainter(
                        origin: origin,
                        cellSize: cell,
                      ),
                    ),

                  // Layer 2: Home Base Tokens
                  for (final p in basePieces)
                    _buildPositionedToken(
                      piece: p,
                      center: homeSlotCenter(p.playerColor.seat, p.baseSlotIndex),
                      tokenSize: tokenSize,
                      scaleAnim: p.isValidMove ? bounceAnimation : null,
                    ),

                  // Layer 3: Track Pieces (Shared Track + Home Stretch)
                  for (final entry in trackPiecesMap.entries)
                    () {
                      final list = entry.value;
                      // Prioritize valid move on top
                      list.sort((a, b) => (b.isValidMove ? 1 : 0).compareTo(a.isValidMove ? 1 : 0));
                      final topPiece = list.first;
                      final center = cellCenter(topPiece.gridCol!, topPiece.gridRow!);
                      return _buildPositionedToken(
                        piece: topPiece,
                        center: center,
                        tokenSize: tokenSize,
                        scaleAnim: topPiece.isValidMove ? bounceAnimation : null,
                        stackCount: list.length,
                      );
                    }(),

                  // Layer 4: Walking / Hopping Token (Tile-by-tile animation across theme tiles!)
                  if (walkingTileCoord != null && walkingColor != null)
                    Positioned(
                      left: cellCenter(walkingTileCoord!.$2, walkingTileCoord!.$1).dx - (tokenSize / 2),
                      top: cellCenter(walkingTileCoord!.$2, walkingTileCoord!.$1).dy - (tokenSize / 2) - 6,
                      width: tokenSize,
                      height: tokenSize,
                      child: Transform.scale(
                        scale: 1.25,
                        child: _TokenPawnWidget(
                          color: theme.seatColors[walkingColor!.seat] ??
                              walkingColor!.seat.defaultColor.toColor(),
                          tokenSize: tokenSize,
                          isValidMove: false,
                          isSelected: true,
                          stackCount: 1,
                        ),
                      ),
                    ),

                  // Center Child (if any)
                  if (centerChild != null)
                    Center(child: centerChild!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionedToken({
    required ThemedBoardPiece piece,
    required Offset center,
    required double tokenSize,
    Animation<double>? scaleAnim,
    int stackCount = 1,
  }) {
    // Requirement 1: PlayerColor mapped to Seat to get theme's seatColor
    final seat = piece.playerColor.seat;
    final seatColor = theme.seatColors[seat] ?? piece.playerColor.seat.defaultColor.toColor();

    return Positioned(
      left: center.dx - (tokenSize / 2),
      top: center.dy - (tokenSize / 2),
      width: tokenSize,
      height: tokenSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: piece.isValidMove ? piece.onTap : null,
        child: AnimatedBuilder(
          animation: scaleAnim ?? const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            final bounce = scaleAnim != null
                ? (1.0 + (scaleAnim.value / 12.0) * 0.20)
                : (piece.isSelected ? 1.15 : 1.0);

            return Transform.scale(
              scale: bounce,
              child: child,
            );
          },
          child: _TokenPawnWidget(
            color: seatColor,
            tokenSize: tokenSize,
            isValidMove: piece.isValidMove,
            isSelected: piece.isSelected,
            stackCount: stackCount,
          ),
        ),
      ),
    );
  }
}

/// Requirement 4: Token widget with a crisp outline + shadow for visibility on light/dark quadrants
class _TokenPawnWidget extends StatelessWidget {
  final Color color;
  final double tokenSize;
  final bool isValidMove;
  final bool isSelected;
  final int stackCount;

  const _TokenPawnWidget({
    required this.color,
    required this.tokenSize,
    required this.isValidMove,
    required this.isSelected,
    required this.stackCount,
  });

  @override
  Widget build(BuildContext context) {
    // Determine luminance for intelligent high-contrast rim
    final isDark = color.computeLuminance() < 0.45;
    final rimColor = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF212121);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Requirement 4: Crisp outer shadow and outline
        Container(
          width: tokenSize,
          height: tokenSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Multi-tier shadow for deep contrast
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
              if (isValidMove)
                const BoxShadow(
                  color: Color(0xFF00E676),
                  blurRadius: 9.0,
                  spreadRadius: 2.5,
                ),
              if (isSelected)
                const BoxShadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 9.0,
                  spreadRadius: 2.5,
                ),
            ],
            // Double outline: bright rim + dark core
            border: Border.all(
              color: isValidMove
                  ? const Color(0xFF00E676)
                  : isSelected
                      ? const Color(0xFFFFD700)
                      : rimColor,
              width: isValidMove ? 2.2 : 1.6,
            ),
            gradient: RadialGradient(
              center: const Alignment(-0.25, -0.3),
              radius: 0.85,
              colors: [
                Color.lerp(color, Colors.white, 0.45)!,
                color,
                Color.lerp(color, Colors.black, 0.4)!,
              ],
            ),
          ),
          child: Center(
            // Inner gloss cap
            child: Container(
              width: tokenSize * 0.45,
              height: tokenSize * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.2),
                  radius: 0.7,
                  colors: [
                    Colors.white.withOpacity(0.75),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),

        // Stacked count badge if 2 or more tokens occupy this cell
        if (stackCount > 1)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
              child: Text(
                '$stackCount',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Helper extension for PlayerColor fallback hex
extension _PlayerColorHex on PlayerColor {
  Color toColor() {
    switch (this) {
      case PlayerColor.green:
        return const Color(0xFF0F9D58);
      case PlayerColor.yellow:
        return const Color(0xFFF4B400);
      case PlayerColor.red:
        return const Color(0xFFDB4437);
      case PlayerColor.blue:
        return const Color(0xFF4285F4);
    }
  }
}

/// Debug / Gallery Grid Overlay Painter
class _GridOverlayPainter extends CustomPainter {
  final Offset origin;
  final double cellSize;

  _GridOverlayPainter({required this.origin, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x7700E5FF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final boldPaint = Paint()
      ..color = const Color(0xCC00E5FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw 15x15 cell grid
    for (int i = 0; i <= 15; i++) {
      final isQuadrantBorder = (i == 0 || i == 6 || i == 9 || i == 15);
      final p = isQuadrantBorder ? boldPaint : linePaint;

      // Vertical lines
      final x = origin.dx + i * cellSize;
      canvas.drawLine(Offset(x, origin.dy), Offset(x, origin.dy + 15 * cellSize), p);

      // Horizontal lines
      final y = origin.dy + i * cellSize;
      canvas.drawLine(Offset(origin.dx, y), Offset(origin.dx + 15 * cellSize, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridOverlayPainter old) =>
      origin != old.origin || cellSize != old.cellSize;
}

/// Requirement 2: Lane Highlights Painter for Theme Gallery
/// Draws engine's home-stretch and start cells on top of the theme to spot mismatch with painted lanes.
class _LaneHighlightsPainter extends CustomPainter {
  final Offset origin;
  final double cellSize;

  _LaneHighlightsPainter({required this.origin, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    void drawCell(int col, int row, Color color, {bool isStart = false}) {
      final rect = Rect.fromLTWH(
        origin.dx + col * cellSize,
        origin.dy + row * cellSize,
        cellSize,
        cellSize,
      );
      final fillPaint = Paint()
        ..color = color.withOpacity(0.35)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = isStart ? Colors.white : color
        ..strokeWidth = isStart ? 2.5 : 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, strokePaint);
    }

    // Engine Start cells:
    // Green start: (1, 6)
    drawCell(1, 6, const Color(0xFF0F9D58), isStart: true);
    // Yellow start: (8, 1)
    drawCell(8, 1, const Color(0xFFF4B400), isStart: true);
    // Blue start: (13, 8)
    drawCell(13, 8, const Color(0xFF4285F4), isStart: true);
    // Red start: (6, 13)
    drawCell(6, 13, const Color(0xFFDB4437), isStart: true);

    // Green home stretch: (1..6, 7)
    for (int col = 1; col <= 6; col++) {
      drawCell(col, 7, const Color(0xFF0F9D58));
    }
    // Yellow home stretch: (7, 1..6)
    for (int row = 1; row <= 6; row++) {
      drawCell(7, row, const Color(0xFFF4B400));
    }
    // Blue home stretch: (8..13, 7)
    for (int col = 8; col <= 13; col++) {
      drawCell(col, 7, const Color(0xFF4285F4));
    }
    // Red home stretch: (7, 8..13)
    for (int row = 8; row <= 13; row++) {
      drawCell(7, row, const Color(0xFFDB4437));
    }
  }

  @override
  bool shouldRepaint(_LaneHighlightsPainter old) =>
      origin != old.origin || cellSize != old.cellSize;
}
