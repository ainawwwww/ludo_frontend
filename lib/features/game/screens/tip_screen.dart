import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class TipScreen extends StatelessWidget {
  const TipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: AppColors.surfaceOverlay,
      body: Center(
        child: Container(
          width: 320 * scale,
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            gradient: AppColors.modalInnerGradient,
            borderRadius: BorderRadius.circular(AppConstants.radius19),
            border: Border.all(color: AppColors.modalBorder, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 48 * scale,
              ),
              SizedBox(height: 16 * scale),
              Text(
                'Tip',
                style: AppTextStyles.h1.copyWith(fontSize: 24 * scale),
              ),
              SizedBox(height: 12 * scale),
              Text(
                'If your microphone is not working, check the microphone settings in your phone settings.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13 * scale,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24 * scale),
              OrangeButton(
                label: 'Got it',
                width: 160 * scale,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
