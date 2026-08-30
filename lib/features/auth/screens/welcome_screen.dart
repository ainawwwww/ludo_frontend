import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

import 'package:ludo_vibe/shared/widgets/ludo_loading_overlay.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAuthenticating = false;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      title: 'PLAY & WIN DAILY REWARDS',
      subtitle:
          'Compete in high-stakes Ludo matches and claim gold coins, gems & exclusive rewards every single day!',
      iconData: Icons.emoji_events_rounded,
      accentColor: Color(0xFFFFD700),
    ),
    _OnboardingItem(
      title: 'MULTIPLAYER BETTING BATTLES',
      subtitle:
          'Experience classic Ludo, Domino & Jackaroo with smooth real-time betting lobbies.',
      iconData: Icons.casino_rounded,
      accentColor: Color(0xFFF97023),
    ),
    _OnboardingItem(
      title: 'LIVE VOICE ROOMS & CHAT',
      subtitle:
          'Talk with teammates, join battle rooms, send gift drops, and build your gaming community.',
      iconData: Icons.record_voice_over_rounded,
      accentColor: Color(0xFFB173FF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleStartOrNext() async {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      await _performGuestAuthAndNavigate();
    }
  }

  Future<void> _performGuestAuthAndNavigate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        await ref.read(authProvider.notifier).guestLogin();
      }
      if (mounted) {
        context.go(AppConstants.homeRoute);
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final authState = ref.watch(authProvider);
    final isLoading = _isAuthenticating || authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Top skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: 16 * scale, top: 12 * scale),
                      child: TextButton(
                        onPressed: _performGuestAuthAndNavigate,
                        child: Text(
                          'SKIP',
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3-Slide Carousel
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Illustration Card Container
                              Container(
                                width: 220 * scale,
                                height: 220 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      item.accentColor.withOpacity(0.35),
                                      AppColors.primaryDark.withOpacity(0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.accentColor.withOpacity(0.4),
                                      blurRadius: 30 * scale,
                                      spreadRadius: 4 * scale,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.iconData,
                                  size: 110 * scale,
                                  color: item.accentColor,
                                ),
                              ),
                              SizedBox(height: 40 * scale),

                              // Title
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headingMedium.copyWith(
                                  fontSize: 22 * scale,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14 * scale),

                              // Subtitle
                              Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14 * scale,
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Pagination Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: AppConstants.animationFast,
                        margin: EdgeInsets.symmetric(horizontal: 4 * scale),
                        width: _currentPage == index ? 24 * scale : 8 * scale,
                        height: 8 * scale,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.actionOrange
                              : AppColors.primaryBorderSoft.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * scale),

                  // Bottom Action Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32 * scale),
                    child: OrangeButton(
                      text: _currentPage == _items.length - 1
                          ? 'GET STARTED'
                          : 'NEXT',
                      onPressed: _handleStartOrNext,
                      width: double.infinity,
                      height: 52 * scale,
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                ],
              ),
            ),
          ),

          // Blurred glass LudoLoadingOverlay during guest auth
          if (isLoading)
            const Positioned.fill(
              child: LudoLoadingOverlay(),
            ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color accentColor;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.accentColor,
  });
}
