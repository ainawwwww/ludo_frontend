import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/features/profile/providers/profile_customization_provider.dart';

/// AppBackground renders the main app background
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.assetPath = 'assets/graphics/bg_main.png',
    this.child,
  });

  final String? assetPath;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveAsset = assetPath ?? 'assets/graphics/bg_main.png';

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
                    effectiveAsset,
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
