import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';

/// A unified, premium arcade-style Red Cross (X) close/exit button
/// used consistently across all screens, dialogs, sheets, and headers in the app.
class AppCloseButton extends StatefulWidget {
  const AppCloseButton({
    super.key,
    this.onTap,
    this.onPressed,
    this.size = 32.0,
    this.iconSize,
    this.semanticLabel = 'Close',
  });

  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final double size;
  final double? iconSize;
  final String semanticLabel;

  @override
  State<AppCloseButton> createState() => _AppCloseButtonState();
}

class _AppCloseButtonState extends State<AppCloseButton> {
  bool _isPressed = false;

  void _handleTap() {
    SoundService().playButtonClick();
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else if (widget.onTap != null) {
      widget.onTap!();
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppConstants.homeRoute);
          }
        } catch (_) {
          Navigator.of(context).maybePop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size;
    final effectiveIconSize = widget.iconSize ?? (effectiveSize * 0.54);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Rich multi-stop crimson-to-ruby glossy gradient
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4B4B), // Bright highlight red
                  Color(0xFFE52424), // Vibrant crimson
                  Color(0xFFB71C1C), // Deep ruby
                  Color(0xFF800C0C), // Rich bottom shadow red
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
              // Glossy highlight border + 3D rim
              border: Border.all(
                color: const Color(0xFFFFB3B3),
                width: effectiveSize >= 32 ? 1.5 : 1.2,
              ),
              boxShadow: [
                // Soft colored ambient glow
                BoxShadow(
                  color: const Color(0xFFE52424).withValues(alpha: 0.45),
                  blurRadius: effectiveSize * 0.25,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1.5),
                ),
                // Crisp bottom drop shadow for tactile depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: effectiveSize * 0.18,
                  offset: Offset(0, effectiveSize * 0.08),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Specular top highlight curve for 3D glassy/arcade reflection
                Positioned(
                  top: effectiveSize * 0.06,
                  child: Container(
                    width: effectiveSize * 0.68,
                    height: effectiveSize * 0.32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                            effectiveSize * 0.68, effectiveSize * 0.32),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.55),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Crisp White Cross Icon with subtle drop shadow
                Icon(
                  Icons.close_rounded,
                  size: effectiveIconSize,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x66000000),
                      offset: Offset(0, 1.2),
                      blurRadius: 2.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
