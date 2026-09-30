import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/social/models/gift_model.dart';

class GiftAnimationController {
  void Function(SentGiftEvent event)? _show;

  void show(SentGiftEvent event) {
    _show?.call(event);
  }
}

class GiftAnimationOverlay extends StatefulWidget {
  final GiftAnimationController controller;
  final Widget child;

  const GiftAnimationOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {
  SentGiftEvent? _currentEvent;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller._show = _triggerGiftAnimation;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_animController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _currentEvent = null;
          });
        }
      }
    });
  }

  void _triggerGiftAnimation(SentGiftEvent event) {
    if (!mounted) return;
    setState(() {
      _currentEvent = event;
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentEvent != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final event = _currentEvent!;
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Gift image with glow & scale
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD200).withOpacity(0.6),
                                    blurRadius: 35,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFD500F9).withOpacity(0.5),
                                    blurRadius: 25,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                event.gift.assetPath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.card_giftcard,
                                  size: 80,
                                  color: Color(0xFFFFD200),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Banner announcement plaque
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8E2DE2),
                                  Color(0xFF4A00E0),
                                  Color(0xFFFF9000),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFD200), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🎁 ', style: TextStyle(fontSize: 16)),
                                Text(
                                  '${event.senderName} sent ',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  event.gift.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFD200),
                                  ),
                                ),
                                Text(
                                  ' to ${event.recipientName}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
