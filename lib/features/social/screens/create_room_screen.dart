import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/core/theme/app_theme.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Create My Room',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(fontSize: 20 * scale),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingTile(
                        scale: scale,
                        icon: Icons.lock_outline,
                        title: 'Room Privacy',
                        subtitle: 'Private Room',
                      ),
                      _SettingTile(
                        scale: scale,
                        icon: Icons.people_outline,
                        title: 'Max Players',
                        subtitle: '4 Players',
                      ),
                      _SettingTile(
                        scale: scale,
                        icon: Icons.timer_outlined,
                        title: 'Turn Timer',
                        subtitle: '15 seconds',
                      ),
                      _SettingTile(
                        scale: scale,
                        icon: Icons.monetization_on_outlined,
                        title: 'Entry Fee',
                        subtitle: '1000 Coins',
                      ),
                      SizedBox(height: 24 * scale),
                      Text(
                        'Friend Request',
                        style: AppTextStyles.sectionHeader.copyWith(
                          fontSize: 15 * scale,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          gradient: AppColors.modalInnerGradient,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radius14),
                          border: Border.all(
                            color: AppColors.primaryBorderSoft,
                          ),
                        ),
                        child: Text(
                          'Your friend list displays playing status',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12 * scale,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: OrangeButton(
                  label: 'Create Room',
                  width: double.infinity,
                  onPressed: () => context.push(AppConstants.battleLobbyRoute),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.scale,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8 * scale),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.rewardCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radius10),
        boxShadow: AppTheme.purpleInsetGlow,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 15 * scale),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 12 * scale),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
