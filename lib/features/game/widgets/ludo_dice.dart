import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

/// Helper to resolve active dice skin from Shop state or fallback to 'classic'
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

/// Standalone, modular and reusable 3D Animated Ludo Dice component
/// 
/// Features:
/// 1. Idle State: Displays idle.png with subtle turn-active breathing glow.
/// 2. Tap to Roll: Triggers 3D tumbling animation with perspective (Matrix4 setEntry(3,2,0.001)).
/// 3. Fast Face Cycling: Timer.periodic (~90ms) randomly flashes face_1 to face_6 for tumbling illusion.
/// 4. Settle & Bounce: Lands on final random number (1-6) with Curves.easeOutBack elastic bounce.
/// 5. Guard: Disables multi-tapping during active roll (isAnimating check).
/// 6. Callback: Delivers final roll result to parent via `onRollComplete(int result)`.
class LudoDice extends ConsumerStatefulWidget {
  /// Callback triggered when rolling starts
  final VoidCallback? onRollStart;

  /// Callback delivering the final rolled value (1-6) to the parent screen / game logic
  final ValueChanged<int>? onRollComplete;

  /// Optional fixed skin key (e.g. 'classic', 'chick', 'coffee', 'crystal', etc.).
  /// If omitted, automatically reads the equipped skin from ShopState.
  final String? customSkinKey;

  /// Display size of the dice in logical pixels
  final double size;

  /// Whether the dice is interactable/clickable by the player
  final bool isEnabled;

  /// Initial face to show (1-6), or null to display idle.png initially
  final int? initialValue;

  /// Optional pre-determined roll result for deterministic/AI rolls
  final int? targetValue;

  /// Whether external parent is driving the rolling state (e.g. AI turn or network sync)
  final bool? isRollingExternal;

  const LudoDice({
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
  ConsumerState<LudoDice> createState() => LudoDiceState();
}

class LudoDiceState extends ConsumerState<LudoDice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _rotXAnim;
  late final Animation<double> _rotYAnim;
  late final Animation<double> _rotZAnim;
  late final Animation<double> _scaleAnim;

  final Random _random = Random();
  Timer? _faceCycleTimer;

  bool _isAnimating = false;
  int _currentDisplayFace = 1;
  bool _showIdleGraphic = true;
  int _finalRolledValue = 6;

  /// Whether the dice is actively tumbling/rolling
  bool get isAnimating => _isAnimating;

  /// Currently visible face value (1-6)
  int get currentFace => _currentDisplayFace;

  /// Last settled roll value (1-6)
  int get lastRolledValue => _finalRolledValue;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue! >= 1 && widget.initialValue! <= 6) {
      _currentDisplayFace = widget.initialValue!;
      _finalRolledValue = widget.initialValue!;
      _showIdleGraphic = false;
    } else {
      _showIdleGraphic = true;
      _currentDisplayFace = 6;
      _finalRolledValue = 6;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 3D tumbling rotations (multiple complete spins with smooth deceleration)
    _rotXAnim = Tween<double>(begin: 0.0, end: 6 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _rotYAnim = Tween<double>(begin: 0.0, end: 8 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _rotZAnim = Tween<double>(begin: 0.0, end: 4 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    // Scale sequence with lift off -> mid-air tumble -> landing bounce with easeOutBack
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 0.88).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationFinished();
      }
    });

    if (widget.isRollingExternal == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) roll(targetResult: widget.targetValue);
      });
    }
  }

  @override
  void didUpdateWidget(covariant LudoDice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRollingExternal == true && oldWidget.isRollingExternal != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) roll(targetResult: widget.targetValue);
      });
    }
  }

  @override
  void dispose() {
    _faceCycleTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  /// Triggers the 3D tumbling roll animation.
  /// 
  /// [targetResult] can be optionally passed for deterministic rolls (AI / backend sync).
  /// If null, a random value between 1 and 6 is generated.
  void roll({int? targetResult}) {
    // Guard against multi-tap while already animating
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _showIdleGraphic = false;
    });

    widget.onRollStart?.call();
    try {
      SoundService().playDiceRoll();
    } catch (_) {}

    // Determine final settled roll value (1 to 6)
    _finalRolledValue = targetResult ?? widget.targetValue ?? (_random.nextInt(6) + 1);

    // Fast cycling random face images (~90ms interval) for tumbling illusion
    _faceCycleTimer?.cancel();
    _faceCycleTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentDisplayFace = _random.nextInt(6) + 1;
      });
    });

    _animController.forward(from: 0.0);
  }

  void _onAnimationFinished() {
    _faceCycleTimer?.cancel();
    _faceCycleTimer = null;

    if (!mounted) return;

    setState(() {
      _isAnimating = false;
      _currentDisplayFace = _finalRolledValue;
      _showIdleGraphic = false;
    });

    // Deliver final roll number to parent callback for game logic (e.g. moving pawn)
    widget.onRollComplete?.call(_finalRolledValue);
  }

  /// Resets the dice back to its initial idle state
  void resetToIdle() {
    _faceCycleTimer?.cancel();
    _animController.reset();
    if (mounted) {
      setState(() {
        _isAnimating = false;
        _showIdleGraphic = true;
      });
    }
  }

  String _getSkinKey() {
    if (widget.customSkinKey != null && widget.customSkinKey!.isNotEmpty) {
      return widget.customSkinKey!;
    }
    return resolveEquippedDiceSkinKey(ref);
  }

  String _getImageAssetPath(String skinKey) {
    if (_showIdleGraphic) {
      return 'assets/graphics/dice_skins/$skinKey/idle.png';
    }
    final validFace = (_currentDisplayFace >= 1 && _currentDisplayFace <= 6)
        ? _currentDisplayFace
        : 1;
    return 'assets/graphics/dice_skins/$skinKey/face_$validFace.png';
  }

  @override
  Widget build(BuildContext context) {
    final skinKey = _getSkinKey();
    final diceSize = widget.size;

    return GestureDetector(
      onTap: (widget.isEnabled && !_isAnimating) ? () => roll() : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: diceSize * 1.35,
          height: diceSize * 1.35,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Dynamic 3D Ground Shadow & Glow
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final scaleVal = _isAnimating ? _scaleAnim.value : 1.0;
                  final isClickable = widget.isEnabled && !_isAnimating;

                  return Positioned(
                    bottom: 2,
                    child: Container(
                      width: diceSize * 0.95 * scaleVal,
                      height: diceSize * 0.30 * scaleVal,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(diceSize, diceSize * 0.30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isClickable
                                ? const Color(0xFFFFD54F).withValues(alpha: 0.35)
                                : _isAnimating
                                    ? const Color(0xFFFFD54F).withValues(alpha: 0.6)
                                    : Colors.black45,
                            blurRadius: _isAnimating ? 16 : (isClickable ? 10 : 6),
                            spreadRadius: _isAnimating ? 4 : (isClickable ? 2 : 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 2. 3D Tumbling Transformed Dice Cube with Perspective
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final rotX = _isAnimating ? _rotXAnim.value : 0.0;
                  final rotY = _isAnimating ? _rotYAnim.value : 0.0;
                  final rotZ = _isAnimating ? _rotZAnim.value : 0.0;
                  final scale = _isAnimating ? _scaleAnim.value : 1.0;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // 3D Perspective entry
                      ..scale(scale)
                      ..rotateX(rotX)
                      ..rotateY(rotY)
                      ..rotateZ(rotZ),
                    child: Container(
                      width: diceSize,
                      height: diceSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.isEnabled
                              ? const Color(0xFFFFD54F).withValues(alpha: 0.85)
                              : Colors.white24,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Dice Texture (Idle graphic or Cycling/Settled Face)
                            Image.asset(
                              _getImageAssetPath(skinKey),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF2E334D),
                                child: Center(
                                  child: Text(
                                    _showIdleGraphic ? '🎲' : '$_currentDisplayFace',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Dynamic Glass Highlight Shine Overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.25),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.20),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
