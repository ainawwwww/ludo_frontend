import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

class Vec3 {
  final double x;
  final double y;
  final double z;

  const Vec3(this.x, this.y, this.z);

  Vec3 operator -(Vec3 other) => Vec3(x - other.x, y - other.y, z - other.z);

  Vec3 cross(Vec3 other) => Vec3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );

  double get length => sqrt(x * x + y * y + z * z);
}

String resolveEquippedDiceSkinKey(WidgetRef? ref) {
  if (ref == null) return 'classic';
  try {
    final shopState = ref.watch(shopProvider);
    final equippedDice = shopState.items.firstWhere(
      (item) => item.category == ShopCategory.dice && item.isEquipped,
      orElse: () =>
          ShopCatalog.allItems.firstWhere((i) => i.id == 'dice_classic', orElse: () => ShopCatalog.allItems.first),
    );
    switch (equippedDice.id) {
      case 'dice_chick':
      case 'token_chick':
        return 'chick';
      case 'dice_coffee':
      case 'token_coffee':
        return 'coffee';
      case 'dice_crystal':
      case 'token_crystal':
        return 'crystal';
      case 'dice_dessert':
      case 'token_dessert':
        return 'dessert';
      case 'dice_fantasy_book':
      case 'token_fantasy_book':
        return 'fantasy_book';
      case 'dice_ice_cream':
      case 'token_ice_cream':
        return 'ice_cream';
      case 'dice_leisure_kitty':
      case 'token_leisure_kitty':
        return 'leisure_kitty';
      case 'dice_rosy_life':
      case 'token_rosy_life':
        return 'rosy_life';
      case 'dice_warm_campfire':
      case 'token_warm_campfire':
        return 'campfire';
      case 'dice_warrior_helmet':
      case 'token_warrior_helmet':
        return 'warrior_helmet';
      case 'dice_blessing_basket':
      case 'token_blessing_basket':
        return 'blessing_basket';
      case 'dice_desert_hammer':
      case 'token_desert_hammer':
        return 'desert_hammer';
      case 'dice_earth_power':
      case 'token_earth_power':
        return 'campfire';
      case 'dice_wooden_case':
      case 'token_wooden_case':
        return 'fantasy_book';
      case 'dice_metal':
      case 'token_metal':
        return 'metal';
      case 'dice_classic':
      case 'token_classic':
      default:
        return 'classic';
    }
  } catch (_) {
    return 'classic';
  }
}

class _CubeFaceDefinition {
  final int faceNumber;
  final List<int> vertexIndices;

  const _CubeFaceDefinition(this.faceNumber, this.vertexIndices);
}

class _ProjectedCubeFace {
  final _CubeFaceDefinition definition;
  final List<Offset> corners;
  final Vec3 normal;
  final double averageZ;

  const _ProjectedCubeFace({
    required this.definition,
    required this.corners,
    required this.normal,
    required this.averageZ,
  });
}

/// Keeps the CanvasKit image and its shader alive for the same lifetime.
///
/// On CanvasKit, disposing an ImageShader also disposes its source Image. The
/// painter therefore reuses this shader instead of creating and disposing one
/// on every animation frame.
class _DiceFaceTexture {
  final ui.Image image;
  final ui.ImageShader shader;
  final int width;
  final int height;

  _DiceFaceTexture({required this.image, required this.shader})
      : width = image.width,
        height = image.height;

  void dispose() {
    shader.dispose();
    // CanvasKit's ImageShader owns/disposes its source image. Native Flutter's
    // shader keeps an engine reference but does not dispose the Dart image.
    if (!kIsWeb) {
      image.dispose();
    }
  }
}

class Ludo3DDiceWidget extends ConsumerStatefulWidget {
  final VoidCallback? onRollStart;
  final ValueChanged<int>? onRollComplete;
  final String? customSkinKey;
  final double size;
  final bool isEnabled;
  final int? initialValue;
  final int? targetValue;
  final bool? isRollingExternal;

  const Ludo3DDiceWidget({
    super.key,
    this.onRollStart,
    this.onRollComplete,
    this.customSkinKey,
    this.size = 56.0,
    this.isEnabled = true,
    this.initialValue,
    this.targetValue,
    this.isRollingExternal,
  });

  @override
  ConsumerState<Ludo3DDiceWidget> createState() => Ludo3DDiceState();
}

class Ludo3DDiceState extends ConsumerState<Ludo3DDiceWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rollController;
  late final AnimationController _idleGlowController;
  late Animation<double> _rotXAnimation;
  late Animation<double> _rotYAnimation;
  late Animation<double> _scaleAnimation;

  final Random _rng = Random();
  final Map<int, _DiceFaceTexture> _faceTextures = {};

  static const Map<int, Point<double>> _targetAnglesMap = {
    1: Point(0.0, 0.0),
    2: Point(0.0, -pi / 2),
    3: Point(-pi / 2, 0.0),
    4: Point(pi / 2, 0.0),
    5: Point(0.0, pi / 2),
    6: Point(0.0, pi),
  };

  static final Float64List _identityShaderMatrix = Float64List.fromList([
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
  ]);

  double _currentRotX = 0;
  double _currentRotY = 0;
  double _currentScale = 1;
  bool _isAnimating = false;
  bool _isDisposed = false;
  int _settledFace = 6;
  int _imageLoadGeneration = 0;
  String? _requestedSkin;
  String? _loadedSkin;

  bool get isAnimating => _isAnimating;
  int get currentFace => _settledFace;

  double get _paintRotX => _isAnimating ? _rotXAnimation.value : _currentRotX;
  double get _paintRotY => _isAnimating ? _rotYAnimation.value : _currentRotY;
  double get _paintScale =>
      _isAnimating ? _scaleAnimation.value : _currentScale;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _settledFace =
        initial != null && initial >= 1 && initial <= 6 ? initial : 6;
    final initialAngles = _targetAnglesMap[_settledFace]!;
    _currentRotX = initialAngles.x;
    _currentRotY = initialAngles.y;

    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _idleGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _setupAnimationTweens(_settledFace);
    _rollController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _onRollCompleted();
    });

    if (widget.isRollingExternal == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) roll(targetResult: widget.targetValue);
      });
    }
  }

  @override
  void didUpdateWidget(covariant Ludo3DDiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRollingExternal == true &&
        oldWidget.isRollingExternal != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) roll(targetResult: widget.targetValue);
      });
    } else if (widget.targetValue != oldWidget.targetValue &&
        widget.targetValue != null &&
        !_isAnimating) {
      _settledFace = widget.targetValue!.clamp(1, 6);
      final target = _targetAnglesMap[_settledFace]!;
      setState(() {
        _currentRotX = target.x;
        _currentRotY = target.y;
        _currentScale = 1;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _imageLoadGeneration++;
    _rollController.dispose();
    _idleGlowController.dispose();
    _retireTextures(_faceTextures.values);
    _faceTextures.clear();
    super.dispose();
  }

  String _getSkinKey() {
    final custom = widget.customSkinKey;
    return custom != null && custom.isNotEmpty
        ? custom
        : resolveEquippedDiceSkinKey(ref);
  }

  String _faceAsset(String skin, int face) =>
      'assets/graphics/dice_skins/$skin/face_$face.png';

  void _requestSkinImages(String skin) {
    if (_requestedSkin == skin &&
        (_loadedSkin == skin || _faceTextures.isNotEmpty)) {
      return;
    }
    if (_requestedSkin == skin && _loadedSkin == null) return;

    _requestedSkin = skin;
    final generation = ++_imageLoadGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) _loadSkinImages(skin, generation);
    });
  }

  Future<void> _loadSkinImages(String skin, int generation) async {
    final loaded = <int, _DiceFaceTexture>{};
    for (var face = 1; face <= 6; face++) {
      try {
        loaded[face] = await _decodeAssetTexture(_faceAsset(skin, face));
      } catch (_) {
        if (skin != 'classic') {
          try {
            loaded[face] =
                await _decodeAssetTexture(_faceAsset('classic', face));
          } catch (_) {
            // A stable numbered polygon is painted when both assets fail.
          }
        }
      }
    }

    if (_isDisposed || generation != _imageLoadGeneration) {
      _disposeTexturesNow(loaded.values);
      return;
    }

    final oldTextures = _faceTextures.values.toList(growable: false);
    setState(() {
      _faceTextures
        ..clear()
        ..addAll(loaded);
      _loadedSkin = skin;
    });
    _retireTextures(oldTextures);
  }

  Future<_DiceFaceTexture> _decodeAssetTexture(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final codec = await ui.instantiateImageCodec(bytes);
    late final ui.Image image;
    try {
      image = (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }

    try {
      return _DiceFaceTexture(
        image: image,
        shader: ui.ImageShader(
          image,
          TileMode.clamp,
          TileMode.clamp,
          _identityShaderMatrix,
          filterQuality: FilterQuality.high,
        ),
      );
    } catch (_) {
      image.dispose();
      rethrow;
    }
  }

  void _retireTextures(Iterable<_DiceFaceTexture> textures) {
    final retired = textures.toList(growable: false);
    if (retired.isEmpty) return;
    // The old CustomPaint picture can remain in the compositor for the current
    // frame. Releasing its image-backed shaders after the frame avoids a
    // CanvasKit use-after-free during skin changes and widget removal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _disposeTexturesNow(retired);
    });
  }

  void _disposeTexturesNow(Iterable<_DiceFaceTexture> textures) {
    for (final texture in textures) {
      texture.dispose();
    }
  }

  void _setupAnimationTweens(int targetFace) {
    final target = _targetAnglesMap[targetFace]!;
    final spinsX = (3 + _rng.nextInt(2)) * 2 * pi * (_rng.nextBool() ? 1 : -1);
    final spinsY = (3 + _rng.nextInt(2)) * 2 * pi * (_rng.nextBool() ? 1 : -1);
    final endX = _currentRotX + spinsX - (_currentRotX % (2 * pi)) + target.x;
    final endY = _currentRotY + spinsY - (_currentRotY % (2 * pi)) + target.y;

    final rollCurve = CurvedAnimation(
      parent: _rollController,
      curve: const Cubic(0.22, 1.1, 0.36, 1),
    );
    _rotXAnimation =
        Tween<double>(begin: _currentRotX, end: endX).animate(rollCurve);
    _rotYAnimation =
        Tween<double>(begin: _currentRotY, end: endY).animate(rollCurve);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
    ]).animate(_rollController);
  }

  void roll({int? targetResult}) {
    if (_isAnimating) return;
    final result = (targetResult ?? widget.targetValue ?? (_rng.nextInt(6) + 1))
        .clamp(1, 6)
        .toInt();
    setState(() {
      _isAnimating = true;
      _settledFace = result;
    });
    widget.onRollStart?.call();
    try {
      SoundService().playDiceRoll();
    } catch (_) {}
    _setupAnimationTweens(result);
    _rollController.forward(from: 0);
  }

  void resetToIdle() {
    _rollController.reset();
    if (!mounted) return;
    setState(() {
      _isAnimating = false;
      final target = _targetAnglesMap[_settledFace]!;
      _currentRotX = target.x;
      _currentRotY = target.y;
      _currentScale = 1;
    });
  }

  void _onRollCompleted() {
    if (!mounted) return;
    setState(() {
      _isAnimating = false;
      final target = _targetAnglesMap[_settledFace]!;
      _currentRotX = target.x;
      _currentRotY = target.y;
      _currentScale = 1;
    });
    widget.onRollComplete?.call(_settledFace);
  }

  @override
  Widget build(BuildContext context) {
    final skin = _getSkinKey();
    _requestSkinImages(skin);

    final cubeSize = widget.size;
    final canvasExtent = cubeSize * 2.35;
    final isClickable = widget.isEnabled && !_isAnimating;
    final texturesSnapshot =
        Map<int, _DiceFaceTexture>.unmodifiable(_faceTextures);

    return GestureDetector(
      onTap: isClickable ? roll : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox.square(
          dimension: canvasExtent,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rollController,
              _idleGlowController,
            ]),
            builder: (context, _) => CustomPaint(
              painter: _UnifiedDicePainter(
                faceTextures: texturesSnapshot,
                cubeSize: cubeSize,
                rotationX: _paintRotX,
                rotationY: _paintRotY,
                scale: _paintScale,
                glowProgress: _idleGlowController.value,
                isClickable: isClickable,
                isRolling: _isAnimating,
              ),
              size: Size.square(canvasExtent),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnifiedDicePainter extends CustomPainter {
  final Map<int, _DiceFaceTexture> faceTextures;
  final double cubeSize;
  final double rotationX;
  final double rotationY;
  final double scale;
  final double glowProgress;
  final bool isClickable;
  final bool isRolling;

  const _UnifiedDicePainter({
    required this.faceTextures,
    required this.cubeSize,
    required this.rotationX,
    required this.rotationY,
    required this.scale,
    required this.glowProgress,
    required this.isClickable,
    required this.isRolling,
  });

  static const List<_CubeFaceDefinition> _faces = [
    _CubeFaceDefinition(1, [4, 5, 6, 7]),
    _CubeFaceDefinition(6, [1, 0, 3, 2]),
    _CubeFaceDefinition(2, [5, 1, 2, 6]),
    _CubeFaceDefinition(5, [0, 4, 7, 3]),
    _CubeFaceDefinition(3, [0, 1, 5, 4]),
    _CubeFaceDefinition(4, [7, 6, 2, 3]),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintShadow(canvas, size);
    final half = cubeSize / 2;
    final modelVertices = <Vec3>[
      Vec3(-half, -half, -half),
      Vec3(half, -half, -half),
      Vec3(half, half, -half),
      Vec3(-half, half, -half),
      Vec3(-half, -half, half),
      Vec3(half, -half, half),
      Vec3(half, half, half),
      Vec3(-half, half, half),
    ];

    final rotated = modelVertices.map(_rotateAndScale).toList();
    final center = Offset(size.width / 2, size.height * 0.43);
    final cameraDistance = cubeSize * 7;
    final projected = rotated.map((vertex) {
      final perspective = cameraDistance / max(1, cameraDistance - vertex.z);
      return Offset(
        center.dx + vertex.x * perspective,
        center.dy + vertex.y * perspective,
      );
    }).toList();

    final visibleFaces = <_ProjectedCubeFace>[];
    for (final face in _faces) {
      final a = rotated[face.vertexIndices[0]];
      final b = rotated[face.vertexIndices[1]];
      final c = rotated[face.vertexIndices[2]];
      final normal = (b - a).cross(c - a);
      if (normal.z <= 0.000001) continue;

      visibleFaces.add(_ProjectedCubeFace(
        definition: face,
        corners: face.vertexIndices
            .map((index) => projected[index])
            .toList(growable: false),
        normal: normal,
        averageZ: face.vertexIndices
                .map((index) => rotated[index].z)
                .reduce((a, b) => a + b) /
            4,
      ));
    }

    visibleFaces.sort((a, b) => a.averageZ.compareTo(b.averageZ));
    for (final face in visibleFaces) {
      _paintFace(canvas, face);
    }
  }

  Vec3 _rotateAndScale(Vec3 vertex) {
    final cosY = cos(rotationY);
    final sinY = sin(rotationY);
    final xAfterY = vertex.x * cosY + vertex.z * sinY;
    final zAfterY = -vertex.x * sinY + vertex.z * cosY;
    final cosX = cos(rotationX);
    final sinX = sin(rotationX);
    return Vec3(
      xAfterY * scale,
      (vertex.y * cosX - zAfterY * sinX) * scale,
      (vertex.y * sinX + zAfterY * cosX) * scale,
    );
  }

  void _paintShadow(Canvas canvas, Size size) {
    final alpha = isClickable ? glowProgress * 0.25 + 0.35 : 0.15;
    final color = isClickable
        ? const Color(0xFFFFD54F).withValues(alpha: alpha)
        : isRolling
            ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
            : Colors.black45;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.78),
        width: cubeSize * 1.12 * scale,
        height: cubeSize * 0.28 * scale,
      ),
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          isRolling ? 12 : (isClickable ? 9 : 5),
        ),
    );
  }

  void _paintFace(Canvas canvas, _ProjectedCubeFace face) {
    final path = Path()
      ..moveTo(face.corners[0].dx, face.corners[0].dy)
      ..lineTo(face.corners[1].dx, face.corners[1].dy)
      ..lineTo(face.corners[2].dx, face.corners[2].dy)
      ..lineTo(face.corners[3].dx, face.corners[3].dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF2B1608));

    final texture = faceTextures[face.definition.faceNumber];
    if (texture == null) {
      _paintNumberFallback(canvas, path, face.definition.faceNumber);
    } else {
      final vertices = ui.Vertices.raw(
        ui.VertexMode.triangles,
        Float32List.fromList([
          face.corners[0].dx,
          face.corners[0].dy,
          face.corners[1].dx,
          face.corners[1].dy,
          face.corners[2].dx,
          face.corners[2].dy,
          face.corners[3].dx,
          face.corners[3].dy,
        ]),
        textureCoordinates: Float32List.fromList([
          0,
          0,
          texture.width.toDouble(),
          0,
          texture.width.toDouble(),
          texture.height.toDouble(),
          0,
          texture.height.toDouble(),
        ]),
        indices: Uint16List.fromList([0, 1, 2, 0, 2, 3]),
      );
      canvas.drawVertices(
        vertices,
        BlendMode.srcOver,
        Paint()
          ..shader = texture.shader
          ..isAntiAlias = true,
      );
      vertices.dispose();
    }

    final normalLength = max(face.normal.length, 0.000001);
    final nx = face.normal.x / normalLength;
    final ny = face.normal.y / normalLength;
    final nz = face.normal.z / normalLength;
    final light = (nx * -0.25 + ny * -0.65 + nz * 0.72).clamp(-1.0, 1.0);
    if (light < 0.55) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withValues(
            alpha: ((0.55 - light) * 0.30).clamp(0, 0.34),
          ),
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(
            alpha: ((light - 0.55) * 0.13).clamp(0, 0.08),
          ),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..color = const Color(0xFFFFD778).withValues(alpha: 0.24),
    );
  }

  void _paintNumberFallback(Canvas canvas, Path path, int faceNumber) {
    canvas.save();
    canvas.clipPath(path);
    final bounds = path.getBounds();
    final text = TextPainter(
      text: TextSpan(
        text: '$faceNumber',
        style: TextStyle(
          color: Colors.white,
          fontSize: max(12, bounds.shortestSide * 0.45),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset(
        bounds.center.dx - text.width / 2,
        bounds.center.dy - text.height / 2,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UnifiedDicePainter oldDelegate) {
    return oldDelegate.faceTextures != faceTextures ||
        oldDelegate.cubeSize != cubeSize ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.scale != scale ||
        oldDelegate.glowProgress != glowProgress ||
        oldDelegate.isClickable != isClickable ||
        oldDelegate.isRolling != isRolling;
  }
}
