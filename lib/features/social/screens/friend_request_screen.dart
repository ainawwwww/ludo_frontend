import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

class FriendRequestScreen extends StatelessWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppBackground(),
          Container(color: AppColors.surfaceOverlayLight),
          Center(
            child: Container(
              width: 367 * scale,
              margin: EdgeInsets.symmetric(horizontal: 13 * scale),
              decoration: BoxDecoration(
                gradient: AppColors.modalGradient,
                borderRadius: BorderRadius.circular(AppConstants.radius29),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowDark,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16 * scale),
                  Text(
                    'Friend Request',
                    style: AppTextStyles.h1.copyWith(fontSize: 24 * scale),
                  ),
                  SizedBox(height: 16 * scale),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                    padding: EdgeInsets.all(20 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDisabled,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radius15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Please Enter player ID',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 18 * scale,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radius8,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.modalAccent,
                                width: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.buttonCancel.copyWith(
                        fontSize: 18 * scale,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
