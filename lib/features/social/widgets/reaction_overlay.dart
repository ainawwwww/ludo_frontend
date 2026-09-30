import 'dart:math';
import 'package:flutter/material.dart';

class FloatingReactionItem {
  final Key key;
  final String emoji;
  final double startX;
  final double curveFactor;
  final double size;

  FloatingReactionItem({
    required this.key,
    required this.emoji,
    required this.startX,
    required this.curveFactor,
    required this.size,
  });
}

class ReactionOverlayController {
  void Function(String emoji)? _trigger;

  void trigger(String emoji) {
    _trigger?.call(emoji);
  }
}

class ReactionOverlay extends StatefulWidget {
  final ReactionOverlayController controller;
  final Widget child;

  const ReactionOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<ReactionOverlay> with TickerProviderStateMixin {
  final List<FloatingReactionItem> _reactions = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    widget.controller._trigger = _addReaction;
  }

  void _addReaction(String emoji) {
    if (!mounted) return;
    final item = FloatingReactionItem(
      key: UniqueKey(),
      emoji: emoji,
      startX: 0.65 + _rnd.nextDouble() * 0.25, // Right side of screen
      curveFactor: (_rnd.nextDouble() - 0.5) * 60,
      size: 28.0 + _rnd.nextDouble() * 14.0,
    );

    setState(() {
      _reactions.add(item);
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _reactions.remove(item);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        widget.child,
        ..._reactions.map((item) => _AnimatedReactionParticle(
              key: item.key,
              item: item,
              screenHeight: size.height,
              screenWidth: size.width,
            )),
      ],
    );
  }
}

class _AnimatedReactionParticle extends StatefulWidget {
  final FloatingReactionItem item;
  final double screenHeight;
  final double screenWidth;

  const _AnimatedReactionParticle({
    super.key,
    required this.item,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<_AnimatedReactionParticle> createState() => _AnimatedReactionParticleState();
}

class _AnimatedReactionParticleState extends State<_AnimatedReactionParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progress = CurvedAnimation(parent: _animController, curve: Curves.easeOutQuad);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final val = _progress.value;
        final startBottom = 90.0;
        final endBottom = widget.screenHeight * 0.65;
        final currentBottom = startBottom + (endBottom - startBottom) * val;

        // Wave curve horizontally
        final wave = sin(val * pi * 3) * widget.item.curveFactor;
        final currentLeft = (widget.screenWidth * widget.item.startX) + wave;

        // Scale & Opacity curves
        final opacity = val < 0.2
            ? (val / 0.2)
            : val > 0.7
                ? ((1.0 - val) / 0.3).clamp(0.0, 1.0)
                : 1.0;
        final scale = val < 0.2 ? (val / 0.2) * 1.2 : 1.0;

        return Positioned(
          bottom: currentBottom,
          left: currentLeft,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Text(
                widget.item.emoji,
                style: TextStyle(fontSize: widget.item.size),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReactionSelectorBar extends StatelessWidget {
  final Function(String emoji) onSelectEmoji;
  final double scale;

  const ReactionSelectorBar({
    super.key,
    required this.onSelectEmoji,
    required this.scale,
  });

  static const List<String> availableEmojis = [
    '❤️', '🔥', '🎲', '👏', '😂', '🎉', '💎', '👑', '👍'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF160D4A).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFF8E2DE2).withOpacity(0.5), width: 1.2 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E2DE2).withOpacity(0.3),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: availableEmojis.map((emoji) {
          return GestureDetector(
            onTap: () => onSelectEmoji(emoji),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * scale),
              child: Transform.scale(
                scale: 1.0,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 22 * scale),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
