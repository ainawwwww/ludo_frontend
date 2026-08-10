import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';

/// Assets: home_background.png, splash_background.png
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.assetPath = 'assets/graphics/bg_main.png',
    this.child,
  });

  final String assetPath;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.scaffoldBackground),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: width * AppConstants.splashBackgroundOffsetLeft,
                  top: height * AppConstants.splashBackgroundOffsetTop,
                  width: width * AppConstants.splashBackgroundScaleWidth,
                  height: height * AppConstants.splashBackgroundScaleHeight,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.splashBackgroundGradient,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (child != null) child!,
      ],
    );
  }
}
