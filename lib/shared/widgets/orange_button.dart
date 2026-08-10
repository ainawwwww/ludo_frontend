import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';

class OrangeButton extends StatefulWidget {
  const OrangeButton({
    super.key,
    String? label,
    String? text,
    VoidCallback? onPressed,
    VoidCallback? onTap,
    this.width,
    this.height = AppConstants.buttonHeightMedium,
  })  : label = label ?? text ?? '',
        onPressed = onPressed ?? onTap ?? _noop;

  static void _noop() {}

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double height;

  @override
  State<OrangeButton> createState() => _OrangeButtonState();
}

class _OrangeButtonState extends State<OrangeButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: AppConstants.animationFast,
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radius9),
                  color: AppColors.actionOrange,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x24000000),
                      offset: Offset(0, 5),
                      blurRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.actionOrangeShadow,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: widget.height * 0.48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft:
                                Radius.circular(AppConstants.radius9),
                            topRight:
                                Radius.circular(AppConstants.radius9),
                          ),
                          gradient: AppColors.orangeButtonTopGradient,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.label,
                        style: AppTextStyles.buttonPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
