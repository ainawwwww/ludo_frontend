import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/core/theme/app_theme.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';

class MyFriendsScreen extends ConsumerWidget {
  const MyFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final tabIndex = ref.watch(homeProvider).myFriendsTabIndex;
    final friends = ref.watch(myFriendsProvider);
    final requests = ref.watch(friendRequestsProvider);
    final list = tabIndex == 0 ? friends : requests;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 8 * scale,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                        size: 20 * scale,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'My Friends',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(fontSize: 20 * scale),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                children: [
                  _TabChip(
                    label: 'My Friends',
                    isSelected: tabIndex == 0,
                    onTap: () =>
                        ref.read(homeProvider.notifier).setMyFriendsTab(0),
                    scale: scale,
                  ),
                  SizedBox(width: 8 * scale),
                  _TabChip(
                    label: 'Friend Request',
                    isSelected: tabIndex == 1,
                    onTap: () =>
                        ref.read(homeProvider.notifier).setMyFriendsTab(1),
                    scale: scale,
                    badgeCount: requests.length,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                itemCount: list.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.primaryBorderSoft.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final friend = list[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24 * scale,
                      backgroundColor: AppColors.surfaceCard,
                      child: Icon(Icons.person, color: AppColors.white),
                    ),
                    title: Text(
                      friend.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 15 * scale,
                      ),
                    ),
                    trailing: tabIndex == 1
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.cancel,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.circle,
                            size: 10 * scale,
                            color: friend.isOnline
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                  );
                },
              ),
            ),
            const BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.scale,
    this.badgeCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationNormal,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.primaryDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radius6),
            topRight: Radius.circular(AppConstants.radius6),
          ),
          boxShadow: isSelected ? AppTheme.purpleInsetGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: (isSelected
                      ? AppTextStyles.tabLabelActive
                      : AppTextStyles.tabLabel)
                  .copyWith(fontSize: 13 * scale),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              SizedBox(width: 6 * scale),
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
