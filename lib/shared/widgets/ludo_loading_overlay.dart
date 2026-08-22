import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Helper data structure for Z-sorting 3D dice faces.
class _DiceFaceData {
  final int faceValue;
  final Matrix4 localMatrix;
  final double x;
  final double y;
  final double z;
  double depth = 0.0;

  _DiceFaceData({
    required this.faceValue,
    required this.localMatrix,
    required this.x,
    required this.y,
    required this.z,
  });
}

/// Custom painter for rendering standard dice dot patterns (1–6).
class _DiceFacePainter extends CustomPainter {
  final int faceValue;

  const _DiceFacePainter({required this.faceValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E103E)
      ..style = PaintingStyle.fill;

    const double dotRadius = 2.5;
    const double c = 19.0; // Center
    const double l = 11.0; // Left
    const double r = 27.0; // Right
    const double t = 11.0; // Top
    const double b = 27.0; // Bottom

    final List<Offset> points = [];

    switch (faceValue) {
      case 1:
        points.add(const Offset(c, c));
        break;
      case 2:
        points.addAll([const Offset(l, t), const Offset(r, b)]);
        break;
      case 3:
        points.addAll([const Offset(l, t), const Offset(c, c), const Offset(r, b)]);
        break;
      case 4:
        points.addAll([
          const Offset(l, t),
          const Offset(r, t),
          const Offset(l, b),
          const Offset(r, b),
        ]);
        break;
      case 5:
        points.addAll([
          const Offset(l, t),
          const Offset(r, t),
          const Offset(c, c),
          const Offset(l, b),
          const Offset(r, b),
        ]);
        break;
      case 6:
        points.addAll([
          const Offset(l, 10.0),
          const Offset(r, 10.0),
          const Offset(l, c),
          const Offset(r, c),
          const Offset(l, 28.0),
          const Offset(r, 28.0),
        ]);
        break;
    }

    for (final pt in points) {
      canvas.drawCircle(pt, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) {
    return oldDelegate.faceValue != faceValue;
  }
}

/// A premium Ludo loading screen presented as a blurred frosted-glass overlay.
///
/// Features:
/// - Compact, sleek floating loader stage (130x130).
/// - Frosted backdrop blur (10px sigma) with semi-transparent dark tint (30% opacity).
/// - 3D tumbling dice cube (38x38) with standard dot patterns (1–6) and purple glow.
/// - 4 mini Ludo token pieces orbiting in a circular path with Y-axis 3D flips.
/// - 4 sequential pulsing gradient dots (purple -> orange).
/// - Smooth 200ms fade in/out transitions.
class LudoLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final Widget? child;

  const LudoLoadingOverlay({
    super.key,
    this.isVisible = true,
    this.child,
  });

  static BuildContext? _dialogContext;

  /// Shows the blurred frosted-glass loading overlay globally over the current screen.
  static void show(BuildContext context) {
    if (_dialogContext != null) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        _dialogContext = ctx;
        return const LudoLoadingOverlay();
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  /// Hides/dismisses the active global loading overlay with a smooth fade-out.
  static void hide(BuildContext context) {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!, rootNavigator: true).pop();
      _dialogContext = null;
    }
  }

  /// Returns true if the global loading overlay is currently visible.
  static bool get isShowing => _dialogContext != null;

  @override
  State<LudoLoadingOverlay> createState() => _LudoLoadingOverlayState();
}

class _LudoLoadingOverlayState extends State<LudoLoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _diceController;
  late final AnimationController _orbitController;
  late final AnimationController _tokenSpinController;
  late final AnimationController _dotController;

  static const List<String> _tokenPaths = [
    'assets/graphics/game/pieces/blue_piece.png',
    'assets/graphics/game/pieces/green_piece.png',
    'assets/graphics/game/pieces/red_piece.png',
    'assets/graphics/game/pieces/yellow_piece.png',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Dice 3D continuous tumble (3.2s per full loop, linear)
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // 2. Orbit group rotation (3.0s per full loop, linear)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // 3. Token individual Y-axis 3D spin (1.6s per rotation, linear)
    _tokenSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // 4. Staggered dot pulse (1.2s per loop)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _diceController.dispose();
    _orbitController.dispose();
    _tokenSpinController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return Stack(
        children: [
          widget.child!,
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.isVisible ? 1.0 : 0.0,
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !widget.isVisible,
                child: _buildOverlayContent(),
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: _buildOverlayContent(),
      ),
    );
  }

  /// Builds the full frosted glass overlay with centered loading animations.
  Widget _buildOverlayContent() {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 1. Frosted Glass Backdrop Blur (sigma 10) + Dark Tint (30% opacity)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.30),
                ),
              ),
            ),
          ),

          // 2. Centered compact stage: 3D Dice + Orbiting Tokens + Pulsing Dots
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D Dice & Token Orbit Container Stage (130x130)
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Purple background glow behind the dice
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF5641F8),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      // 3D Tumbling Dice Cube (38x38)
                      _build3DDiceCube(),

                      // 4 Orbiting Mini Ludo Tokens
                      ..._buildOrbitingTokens(),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4 Staggered Pulsing Gradient Dots
                _buildPulsingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 3D rotating dice cube using 6 Z-sorted faces.
  Widget _build3DDiceCube() {
    return AnimatedBuilder(
      animation: _diceController,
      builder: (context, child) {
        final angleX = _diceController.value * 2 * math.pi;
        final angleY = _diceController.value * 2 * math.pi * 1.5;

        final cubeMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(angleX)
          ..rotateY(angleY);

        const double size = 38.0;
        const double half = size / 2.0;

        // 6 Cube Faces with initial positions
        final faces = <_DiceFaceData>[
          _DiceFaceData(
            faceValue: 1,
            localMatrix: Matrix4.identity()..translate(0.0, 0.0, half),
            x: 0.0,
            y: 0.0,
            z: half,
          ),
          _DiceFaceData(
            faceValue: 6,
            localMatrix: Matrix4.identity()
              ..translate(0.0, 0.0, -half)
              ..rotateY(math.pi),
            x: 0.0,
            y: 0.0,
            z: -half,
          ),
          _DiceFaceData(
            faceValue: 2,
            localMatrix: Matrix4.identity()
              ..translate(0.0, -half, 0.0)
              ..rotateX(-math.pi / 2),
            x: 0.0,
            y: -half,
            z: 0.0,
          ),
          _DiceFaceData(
            faceValue: 5,
            localMatrix: Matrix4.identity()
              ..translate(0.0, half, 0.0)
              ..rotateX(math.pi / 2),
            x: 0.0,
            y: half,
            z: 0.0,
          ),
          _DiceFaceData(
            faceValue: 3,
            localMatrix: Matrix4.identity()
              ..translate(-half, 0.0, 0.0)
              ..rotateY(-math.pi / 2),
            x: -half,
            y: 0.0,
            z: 0.0,
          ),
          _DiceFaceData(
            faceValue: 4,
            localMatrix: Matrix4.identity()
              ..translate(half, 0.0, 0.0)
              ..rotateY(math.pi / 2),
            x: half,
            y: 0.0,
            z: 0.0,
          ),
        ];

        // Z depth sorting formula: Z_transformed = M[2]*x + M[6]*y + M[10]*z + M[14]
        final m = cubeMatrix.storage;
        for (final face in faces) {
          face.depth = m[2] * face.x + m[6] * face.y + m[10] * face.z + m[14];
        }

        // Sort descending: farthest faces rendered first, closest faces rendered on top
        faces.sort((a, b) => b.depth.compareTo(a.depth));

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: faces.map((face) {
              final faceMatrix = cubeMatrix * face.localMatrix;
              return Transform(
                alignment: Alignment.center,
                transform: faceMatrix,
                child: _buildDiceFace(face.faceValue),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Builds a single white rounded face (38x38) for the dice.
  Widget _buildDiceFace(int faceValue) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DiceFacePainter(faceValue: faceValue),
      ),
    );
  }

  /// Builds the 4 orbiting Ludo tokens around the central dice.
  List<Widget> _buildOrbitingTokens() {
    const double radius = 50.0;
    const double tokenSize = 20.0;
    const double stageCenter = 65.0; // 130 / 2

    return List.generate(4, (index) {
      return AnimatedBuilder(
        animation: Listenable.merge([_orbitController, _tokenSpinController]),
        builder: (context, child) {
          final orbitAngle = _orbitController.value * 2 * math.pi;
          final baseAngle = index * (math.pi / 2.0); // 0°, 90°, 180°, 270°
          final currentAngle = orbitAngle + baseAngle;

          final x = radius * math.cos(currentAngle);
          final y = radius * math.sin(currentAngle);

          final spinAngle = _tokenSpinController.value * 2 * math.pi;

          final tokenMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(spinAngle);

          return Positioned(
            left: stageCenter + x - (tokenSize / 2.0),
            top: stageCenter + y - (tokenSize / 2.0),
            child: Transform(
              alignment: Alignment.center,
              transform: tokenMatrix,
              child: Container(
                width: tokenSize,
                height: tokenSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  _tokenPaths[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// Builds the row of 4 sequential pulsing gradient dots below the stage.
  Widget _buildPulsingDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        const double dotSize = 6.0;
        const double stepOffset = 0.15 / 1.2; // 0.125 progress per dot (~0.15s offset)

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final rawProgress = _dotController.value - (index * stepOffset);
            final normalized = (rawProgress % 1.0 + 1.0) % 1.0;

            // Sine wave curve for smooth pulse
            final pulse = (math.sin(normalized * 2 * math.pi) + 1.0) / 2.0;

            final scale = 0.8 + (0.4 * pulse); // 0.8 to 1.2
            final opacity = 0.25 + (0.75 * pulse); // 0.25 to 1.0

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5641F8), // Purple
                          Color(0xFFF97023), // Orange
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x665641F8),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
