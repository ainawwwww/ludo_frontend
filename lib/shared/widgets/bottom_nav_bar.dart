import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';

import 'package:ludo_vibe/core/services/sound_service.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  static const _items = [
    (
      BottomNavItem.events,
      'assets/graphics/nav_events.png',
      'Events',
      AppConstants.eventsRoute
    ),
    (
      BottomNavItem.battle,
      'assets/graphics/nav_battle.png',
      'Battle',
      AppConstants.homeRoute
    ),
    (
      BottomNavItem.chat,
      'assets/graphics/nav_chat.png',
      'Chat',
      AppConstants.battleLobbyRoute
    ),
    (
      BottomNavItem.social,
      'assets/graphics/nav_social.png',
      'Social',
      AppConstants.friendsRoute
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final selectedItem = ref.watch(homeProvider).bottomNav;
    final soundService = ref.watch(soundServiceProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // Sleeker height: 66px + bottom padding for safe area on mobile
    final totalHeight = 66 * scale + bottomPadding;

    return Container(
      height: totalHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/graphics/bottom navbar.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _items.map((item) {
            final isSelected = selectedItem == item.$1;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                soundService.playButtonClick();
                ref.read(homeProvider.notifier).setBottomNav(item.$1);
                final currentRoute = GoRouterState.of(context).uri.toString();
                if (currentRoute != item.$4) {
                  context.go(item.$4);
                }
              },
              child: SizedBox(
                width: 80 * scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isSelected)
                          Container(
                            width: 44 * scale,
                            height: 44 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD500F9).withOpacity(
                                      0.85), // Bright glowing pink/purple
                                  blurRadius: 24 * scale,
                                  spreadRadius: 2 * scale,
                                ),
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(
                                      0.5), // Secondary blue glow layer
                                  blurRadius: 16 * scale,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        // Balanced icon size: 48px
                        Image.asset(
                          item.$2,
                          width: 48 * scale,
                          height: 48 * scale,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 1 * scale),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5 * scale, // Text size: 10.5px
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        height: 1.0,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color:
                                      const Color(0xFFD500F9).withOpacity(0.8),
                                  blurRadius: 6 * scale,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
