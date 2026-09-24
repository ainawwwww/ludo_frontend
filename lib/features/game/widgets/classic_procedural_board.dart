import 'package:flutter/material.dart';

/// Pinwheel center painter for the classic procedural board
class ClassicPinwheelPainter extends CustomPainter {
  final Color greenColor;
  final Color yellowColor;
  final Color blueColor;
  final Color redColor;

  ClassicPinwheelPainter({
    this.greenColor = const Color(0xFF0F9D58),
    this.yellowColor = const Color(0xFFF4B400),
    this.blueColor = const Color(0xFF4285F4),
    this.redColor = const Color(0xFFDB4437),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Top Triangle: GREEN / TL
    paint.color = greenColor;
    final greenPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Right Triangle: YELLOW / TR
    paint.color = yellowColor;
    final yellowPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Bottom Triangle: BLUE / BR
    paint.color = blueColor;
    final bluePath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Left Triangle: RED / BL
    paint.color = redColor;
    final redPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(redPath, paint);

    // Dividing lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), linePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Standalone Classic Procedural Ludo Board Widget.
/// Used as the primary procedural board and as the failsafe fallback if vector reconstruction fails.
class ClassicProceduralBoardWidget extends StatelessWidget {
  final double? size;
  final Color greenColor;
  final Color yellowColor;
  final Color blueColor;
  final Color redColor;

  const ClassicProceduralBoardWidget({
    super.key,
    this.size,
    this.greenColor = const Color(0xFF0F9D58),
    this.yellowColor = const Color(0xFFF4B400),
    this.blueColor = const Color(0xFF4285F4),
    this.redColor = const Color(0xFFDB4437),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = size ?? constraints.maxWidth;
        final scale = (boardSize / 360.0).clamp(0.5, 2.5);

        return Container(
          width: boardSize,
          height: boardSize,
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E1A47), Color(0xFF130924)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              width: 2.0 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Top Row (flex 6): TL Base (Green), Top Arm (6x3), TR Base (Yellow)
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        Expanded(flex: 6, child: _buildHomeBase(greenColor, scale)),
                        Expanded(flex: 3, child: _buildVerticalTrack(0, 5, scale)),
                        Expanded(flex: 6, child: _buildHomeBase(yellowColor, scale)),
                      ],
                    ),
                  ),
                  // Middle Row (flex 3): Left Arm, Center Goal, Right Arm
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(flex: 6, child: _buildHorizontalTrack(0, 5, scale, isLeft: true)),
                        Expanded(flex: 3, child: _buildCenterGoal(scale)),
                        Expanded(flex: 6, child: _buildHorizontalTrack(9, 14, scale, isLeft: false)),
                      ],
                    ),
                  ),
                  // Bottom Row (flex 6): BL Base (Red), Bottom Arm (6x3), BR Base (Blue)
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        Expanded(flex: 6, child: _buildHomeBase(redColor, scale)),
                        Expanded(flex: 3, child: _buildVerticalTrack(9, 14, scale, isBottom: true)),
                        Expanded(flex: 6, child: _buildHomeBase(blueColor, scale)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeBase(Color color, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.5),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.76,
          heightFactor: 0.76,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3 * scale,
                  offset: Offset(0, 1.5 * scale),
                ),
              ],
            ),
            padding: EdgeInsets.all(4 * scale),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildSlotCircle(color, scale)),
                      Expanded(child: _buildSlotCircle(color, scale)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildSlotCircle(color, scale)),
                      Expanded(child: _buildSlotCircle(color, scale)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCircle(Color color, double scale) {
    return Center(
      child: Container(
        width: 22 * scale,
        height: 22 * scale,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5 * scale),
        ),
      ),
    );
  }

  Widget _buildCenterGoal(double scale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDFE5EB), width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ClassicPinwheelPainter(
                greenColor: greenColor,
                yellowColor: yellowColor,
                blueColor: blueColor,
                redColor: redColor,
              ),
            ),
          ),
          Container(
            width: 20 * scale,
            height: 20 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFFD700), width: 1.8 * scale),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3 * scale),
              ],
            ),
            child: Center(
              child: Icon(Icons.star_rounded, color: const Color(0xFFFFB300), size: 14 * scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTrack(int startRow, int endRow, double scale, {bool isBottom = false}) {
    final rowCount = endRow - startRow + 1;
    return Column(
      children: List.generate(rowCount, (r) {
        final row = startRow + r;
        return Expanded(
          child: Row(
            children: List.generate(3, (c) {
              final col = 6 + c;
              Color bg = Colors.white;
              bool isStar = false;
              bool isStart = false;

              // Home stretch column (col == 7)
              if (col == 7) {
                if (!isBottom && row >= 1 && row <= 5) bg = greenColor;
                if (isBottom && row >= 9 && row <= 13) bg = blueColor;
              }

              // Start markers
              if (row == 6 && col == 1) { bg = greenColor; isStart = true; }
              if (row == 1 && col == 8) { bg = yellowColor; isStart = true; }
              if (row == 8 && col == 13) { bg = blueColor; isStart = true; }
              if (row == 13 && col == 6) { bg = redColor; isStart = true; }

              // Safe stars
              if ((row == 2 && col == 6) || (row == 12 && col == 8)) isStar = true;

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(color: const Color(0xFFDFE5EB), width: 0.5),
                  ),
                  child: isStar
                      ? Center(child: Icon(Icons.star_rounded, color: Colors.grey.shade600, size: 12 * scale))
                      : isStart
                          ? Center(child: Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 12 * scale))
                          : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalTrack(int startCol, int endCol, double scale, {required bool isLeft}) {
    final colCount = endCol - startCol + 1;
    return Column(
      children: List.generate(3, (r) {
        final row = 6 + r;
        return Expanded(
          child: Row(
            children: List.generate(colCount, (c) {
              final col = startCol + c;
              Color bg = Colors.white;
              bool isStar = false;
              bool isStart = false;

              // Home stretch row (row == 7)
              if (row == 7) {
                if (isLeft && col >= 1 && col <= 5) bg = redColor;
                if (!isLeft && col >= 9 && col <= 13) bg = yellowColor;
              }

              // Start markers
              if (row == 6 && col == 1) { bg = greenColor; isStart = true; }
              if (row == 1 && col == 8) { bg = yellowColor; isStart = true; }
              if (row == 8 && col == 13) { bg = blueColor; isStart = true; }
              if (row == 13 && col == 6) { bg = redColor; isStart = true; }

              // Safe stars
              if ((row == 8 && col == 2) || (row == 6 && col == 12)) isStar = true;

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(color: const Color(0xFFDFE5EB), width: 0.5),
                  ),
                  child: isStar
                      ? Center(child: Icon(Icons.star_rounded, color: Colors.grey.shade600, size: 12 * scale))
                      : isStart
                          ? Center(child: Icon(Icons.arrow_circle_right_rounded, color: Colors.white, size: 12 * scale))
                          : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
