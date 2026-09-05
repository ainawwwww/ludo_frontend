import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/home/models/game_card_model.dart'
    as page_models;
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/features/home/widgets/settings_dialogs.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';
import 'package:ludo_vibe/shared/widgets/game_card.dart';
import 'package:ludo_vibe/shared/widgets/game_mode_tabs.dart';
import 'package:ludo_vibe/shared/widgets/league_banner.dart';
import 'package:ludo_vibe/shared/widgets/page_dots_indicator.dart';
import 'package:ludo_vibe/shared/widgets/top_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).setBottomNav(BottomNavItem.battle);

      // Welcome dialog has been disabled as requested
      /*
      if (!_welcomePopupShown) {
        _welcomePopupShown = true;
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          barrierDismissible: false,
          builder: (context) => const WelcomePopup(),
        );
      }
      */
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCardTap(String title, int pageIndex) {
    if (pageIndex != 0) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0F69),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8C7DF5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Text(
                'Coming Soon',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return;
    }

    if (pageIndex == 0 && title.contains('2&4')) {
      context.push(AppConstants.ludoLobbyRoute);
    } else if (title.contains('Private') || title.contains('VIP')) {
      context.push(AppConstants.createRoomRoute);
    } else {
      context.push(AppConstants.battleLobbyRoute);
    }
  }

  GameModeTab _indexToGameMode(int index) {
    switch (index) {
      case 0:
        return GameModeTab.ludo;
      case 1:
        return GameModeTab.domino;
      case 2:
        return GameModeTab.jackpot;
      case 3:
        return GameModeTab.other;
      default:
        return GameModeTab.ludo;
    }
  }

  int _gameModeToIndex(GameModeTab mode) {
    switch (mode) {
      case GameModeTab.ludo:
        return 0;
      case GameModeTab.domino:
        return 1;
      case GameModeTab.jackpot:
        return 2;
      case GameModeTab.other:
        return 3;
    }
  }

  List<page_models.PageCardModel> _getPageCards(int pageIndex) {
    switch (pageIndex) {
      case 0: // Page 1 - Ludo
        return [
          page_models.PageCardModel(
            title: '2&4\nPlayers',
            imagePath: 'assets/graphics/ludogamemode/2 and 4 png.png',
            backgroundImagePath:
                'assets/graphics/ludogamemode/2&4player Yellow button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.horizontalLeftImage,
            flex: 58,
          ),
          page_models.PageCardModel(
            title: 'Tournament',
            imagePath: 'assets/graphics/ludogamemode/Tournament_png.png',
            backgroundImagePath:
                'assets/graphics/ludogamemode/tournament Green button.png',
            size: page_models.CardSize.large,
            flex: 40,
          ),
          page_models.PageCardModel(
            title: 'Team',
            imagePath: 'assets/graphics/ludogamemode/team_Png.png',
            backgroundImagePath:
                'assets/graphics/ludogamemode/team orange_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Private',
            imagePath: 'assets/graphics/ludogamemode/privatepng2.png',
            backgroundImagePath:
                'assets/graphics/ludogamemode/private_Green_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/ludogamemode/vip_png.png',
            backgroundImagePath:
                'assets/graphics/ludogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 1: // Page 2 - Domino
        return [
          page_models.PageCardModel(
            title: '1 ON 1',
            imagePath: 'assets/graphics/dominogamemode/1on1_png.png',
            backgroundImagePath:
                'assets/graphics/dominogamemode/1on1 blue button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: '4Player',
            imagePath: 'assets/graphics/dominogamemode/4player_png.png',
            backgroundImagePath:
                'assets/graphics/dominogamemode/4player orange_button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Tournament',
            imagePath: 'assets/graphics/dominogamemode/Tournament_png.png',
            backgroundImagePath:
                'assets/graphics/dominogamemode/tournament Green button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Private',
            imagePath: 'assets/graphics/dominogamemode/privatepng2.png',
            backgroundImagePath:
                'assets/graphics/dominogamemode/private_Green_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/dominogamemode/vip_png.png',
            backgroundImagePath:
                'assets/graphics/dominogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 2: // Page 3 - Jackaroo
        return [
          page_models.PageCardModel(
            title: '1 VS 1',
            imagePath: 'assets/graphics/jackaroogamemode/1v1_png.png',
            backgroundImagePath:
                'assets/graphics/jackaroogamemode/1vs1_greenbutton.png',
            size: page_models.CardSize.large,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: 'Basic',
            imagePath: 'assets/graphics/jackaroogamemode/basic_png.png',
            backgroundImagePath:
                'assets/graphics/jackaroogamemode/basic_blue_button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Complex',
            imagePath: 'assets/graphics/jackaroogamemode/Complex_png.png',
            backgroundImagePath:
                'assets/graphics/jackaroogamemode/complex_yellowbutton.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/jackaroogamemode/vip_png.png',
            backgroundImagePath:
                'assets/graphics/jackaroogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 3: // Page 4 - Other
        return [
          page_models.PageCardModel(
            title: 'Jungle\nLudo',
            imagePath: 'assets/graphics/othergamemode/jungleludo_png.png',
            backgroundImagePath:
                'assets/graphics/othergamemode/jungleludo orangebutton.png',
            size: page_models.CardSize.large,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: 'Snakes & Ladders',
            imagePath:
                'assets/graphics/othergamemode/snakes and ladder png.png',
            backgroundImagePath:
                'assets/graphics/othergamemode/snakesandladder button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Night Ludo',
            imagePath: 'assets/graphics/othergamemode/nightludo_png.png',
            backgroundImagePath:
                'assets/graphics/othergamemode/night ludo button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Fight Ludo',
            imagePath: 'assets/graphics/othergamemode/fight ludo png.png',
            backgroundImagePath:
                'assets/graphics/othergamemode/fight ludo button.png',
            size: page_models.CardSize.small,
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;
    final topPadding = MediaQuery.paddingOf(context).top;
    final requiredSectionGap = 149 * scale - topPadding;
    final sectionTopGap = requiredSectionGap > 0 ? requiredSectionGap : 0.0;
    final homeState = ref.watch(homeProvider);

    // Listen for gameMode changes and jump PageView instantly
    ref.listen<HomeState>(homeProvider, (previous, next) {
      if (previous?.gameMode != next.gameMode) {
        final index = _gameModeToIndex(next.gameMode);
        if (_pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Standard Home Background
          Image.asset(
            'assets/graphics/bg_home.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Main content column dividing scrollable content from fixed bottom nav
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top Bar & League Banner
                            ref.watch(homeDataProvider).when(
                                  data: (homeData) {
                                    final isLocked = homeData.isLeagueLocked;
                                    final leagueText = isLocked
                                        ? 'Unlocks at Level 4'
                                        : (homeData.currentLeague?.name ??
                                            'Bronze');

                                    final rankText = homeData.globalRank <= 0
                                        ? 'No. 0'
                                        : 'No. ${homeData.globalRank}';

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TopBar(
                                          playerName: homeData.username,
                                          coins: '${homeData.coins}',
                                          diamonds: '${homeData.diamonds}',
                                          level: homeData.level,
                                          onSettingsTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  const MainSettingsDialog(),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 10 * scale),
                                        LeagueBanner(
                                          leagueRank: leagueText,
                                          playerRank: rankText,
                                          isLeagueLocked: isLocked,
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TopBar(
                                        onSettingsTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const MainSettingsDialog(),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 10 * scale),
                                      const LeagueBanner(
                                        leagueRank: 'Locked',
                                        playerRank: 'No. 0',
                                        isLeagueLocked: true,
                                      ),
                                    ],
                                  ),
                                  error: (_, __) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TopBar(
                                        onSettingsTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const MainSettingsDialog(),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 10 * scale),
                                      const LeagueBanner(
                                        leagueRank: 'Locked',
                                        playerRank: 'No. 0',
                                        isLeagueLocked: true,
                                      ),
                                    ],
                                  ),
                                ),

                            // Keeps the game section at reference screen Y=289.
                            SizedBox(height: sectionTopGap),

                            // PageView with 4 pages
                            SizedBox(
                              height: 301 * scale,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  // Update homeProvider's cardPageIndex and gameMode
                                  ref
                                      .read(homeProvider.notifier)
                                      .setCardPage(index);
                                  ref
                                      .read(homeProvider.notifier)
                                      .setGameMode(_indexToGameMode(index));
                                },
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return _buildPageContent(index, scale);
                                },
                              ),
                            ),
                            SizedBox(height: 14 * scale),
                            // Game Mode Tabs
                            const GameModeTabs(),
                            SizedBox(height: 14 * scale),
                            // Page dots indicator
                            PageDotsIndicator(
                              currentPage: homeState.cardPageIndex,
                              totalPages: 4,
                            ),

                            // Shorter spacer at the bottom
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Fixed Bottom Navigation docked at the bottom of the screen
              const BottomNavBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int pageIndex, double scale) {
    final cards = _getPageCards(pageIndex);

    return _buildLayoutForPage(pageIndex, cards, scale);
  }

  Widget _buildLayoutForPage(
      int pageIndex, List<page_models.PageCardModel> cards, double scale) {
    switch (pageIndex) {
      case 0:
        return _buildLudoPage(cards, scale);
      case 1:
        return _buildDominoPage(cards, scale);
      case 2:
        return _buildJackarooPage(cards, scale);
      case 3:
        return _buildOtherPage(cards, scale);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLudoPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 5) return const SizedBox.shrink();
    return _buildSectionStack(
      scale,
      [
        _buildCard(
          cards[0],
          scale,
          0,
          backgroundLeft: 9,
          backgroundTop: 10,
          backgroundWidth: 263,
          backgroundHeight: 128,
          artworkLeft: 0,
          artworkTop: 10,
          artworkWidth: 151,
          artworkHeight: 117,
          textLeft: 150.60,
          textTop: 40.35,
          textWidth: 100.15,
          textHeight: 61.06,
          hitLeft: 0,
          hitTop: 10,
          hitWidth: 272,
          hitHeight: 128,
          titleFontSize: 20,
        ),
        _buildCard(
          cards[1],
          scale,
          0,
          backgroundLeft: 260,
          backgroundTop: 10,
          backgroundWidth: 141,
          backgroundHeight: 117,
          artworkLeft: 271.06,
          artworkTop: 15.05,
          artworkWidth: 117.33,
          artworkHeight: 78.22,
          textLeft: 287.44,
          textTop: 93.27,
          textWidth: 100.96,
          textHeight: 12.97,
          hitLeft: 260,
          hitTop: 10,
          hitWidth: 141,
          hitHeight: 117,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[2],
          scale,
          0,
          backgroundLeft: 9,
          backgroundTop: 150,
          backgroundWidth: 120,
          backgroundHeight: 120,
          artworkLeft: 22,
          artworkTop: 157,
          artworkWidth: 98,
          artworkHeight: 78,
          textLeft: 52,
          textTop: 243,
          textWidth: 33,
          textHeight: 13,
          hitLeft: 9,
          hitTop: 150,
          hitWidth: 120,
          hitHeight: 120,
          titleFontSize: 10,
        ),
        _buildCard(
          cards[3],
          scale,
          0,
          backgroundLeft: 133,
          backgroundTop: 138,
          backgroundWidth: 127,
          backgroundHeight: 138,
          artworkLeft: 146,
          artworkTop: 157,
          artworkWidth: 101,
          artworkHeight: 84,
          textLeft: 178,
          textTop: 242,
          textWidth: 46.49,
          textHeight: 12.97,
          hitLeft: 133,
          hitTop: 138,
          hitWidth: 127,
          hitHeight: 138,
          titleFontSize: 10,
        ),
        _buildCard(
          cards[4],
          scale,
          0,
          backgroundLeft: 260,
          backgroundTop: 138,
          backgroundWidth: 127,
          backgroundHeight: 138,
          artworkLeft: 280,
          artworkTop: 159,
          artworkWidth: 94,
          artworkHeight: 83,
          textLeft: 300,
          textTop: 241,
          textWidth: 59,
          textHeight: 13,
          hitLeft: 260,
          hitTop: 138,
          hitWidth: 127,
          hitHeight: 138,
          titleFontSize: 10,
        ),
      ],
    );
  }

  Widget _buildDominoPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 5) return const SizedBox.shrink();
    return _buildSectionStack(
      scale,
      [
        _buildCard(
          cards[0],
          scale,
          1,
          backgroundLeft: -7.81,
          backgroundTop: 0.47,
          backgroundWidth: 204.31,
          backgroundHeight: 140.49,
          artworkLeft: 52,
          artworkTop: 10,
          artworkWidth: 99,
          artworkHeight: 96,
          textLeft: 79.42,
          textTop: 105.64,
          textWidth: 43.09,
          textHeight: 12.97,
          hitLeft: -7.81,
          hitTop: 0.47,
          hitWidth: 204.31,
          hitHeight: 140.49,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[1],
          scale,
          1,
          backgroundLeft: 186,
          backgroundTop: 0,
          backgroundWidth: 203,
          backgroundHeight: 141,
          artworkLeft: 228,
          artworkTop: 18,
          artworkWidth: 106,
          artworkHeight: 88,
          textLeft: 258.39,
          textTop: 99.15,
          textWidth: 59.11,
          textHeight: 12.97,
          hitLeft: 186,
          hitTop: 0,
          hitWidth: 203,
          hitHeight: 141,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[2],
          scale,
          1,
          backgroundLeft: -48.23,
          backgroundTop: 137,
          backgroundWidth: 224.03,
          backgroundHeight: 149.35,
          artworkLeft: 5.61,
          artworkTop: 158.76,
          artworkWidth: 117.33,
          artworkHeight: 78.22,
          textLeft: 21.98,
          textTop: 236.98,
          textWidth: 100.96,
          textHeight: 12.97,
          hitLeft: -48.23,
          hitTop: 137,
          hitWidth: 224.03,
          hitHeight: 149.35,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[3],
          scale,
          1,
          backgroundLeft: 133,
          backgroundTop: 138,
          backgroundWidth: 127,
          backgroundHeight: 138,
          artworkLeft: 145,
          artworkTop: 157,
          artworkWidth: 101,
          artworkHeight: 84,
          textLeft: 171.96,
          textTop: 242.34,
          textWidth: 46.49,
          textHeight: 12.97,
          hitLeft: 133,
          hitTop: 138,
          hitWidth: 127,
          hitHeight: 138,
          titleFontSize: 10,
        ),
        _buildCard(
          cards[4],
          scale,
          1,
          backgroundLeft: 259,
          backgroundTop: 138,
          backgroundWidth: 127,
          backgroundHeight: 138,
          artworkLeft: 275,
          artworkTop: 159,
          artworkWidth: 94,
          artworkHeight: 83,
          textLeft: 295,
          textTop: 241,
          textWidth: 59,
          textHeight: 13,
          hitLeft: 259,
          hitTop: 138,
          hitWidth: 127,
          hitHeight: 138,
          titleFontSize: 10,
        ),
      ],
    );
  }

  Widget _buildJackarooPage(
      List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 4) return const SizedBox.shrink();
    return _buildSectionStack(
      scale,
      [
        _buildCard(
          cards[0],
          scale,
          2,
          backgroundLeft: 1,
          backgroundTop: 6.61,
          backgroundWidth: 173.85,
          backgroundHeight: 260.78,
          artworkLeft: -21.44,
          artworkTop: 43.82,
          artworkWidth: 210.88,
          artworkHeight: 140.59,
          textLeft: 43.5,
          textTop: 198,
          textWidth: 82,
          textHeight: 24,
          hitLeft: 9,
          hitTop: 25,
          hitWidth: 151,
          hitHeight: 235,
          titleFontSize: 20,
        ),
        _buildCard(
          cards[1],
          scale,
          2,
          backgroundLeft: 162,
          backgroundTop: 13,
          backgroundWidth: 238,
          backgroundHeight: 138,
          artworkLeft: 214.35,
          artworkTop: 26.49,
          artworkWidth: 121.86,
          artworkHeight: 95.81,
          textLeft: 247.5,
          textTop: 116,
          textWidth: 58,
          textHeight: 19,
          hitLeft: 170,
          hitTop: 26,
          hitWidth: 213,
          hitHeight: 120,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[2],
          scale,
          2,
          backgroundLeft: 168.19,
          backgroundTop: 162.69,
          backgroundWidth: 111.75,
          backgroundHeight: 104.70,
          artworkLeft: 177.83,
          artworkTop: 165.63,
          artworkWidth: 92.47,
          artworkHeight: 76.21,
          textLeft: 188,
          textTop: 239,
          textWidth: 72,
          textHeight: 13,
          hitLeft: 170,
          hitTop: 164,
          hitWidth: 106,
          hitHeight: 94,
          titleFontSize: 10,
        ),
        _buildCard(
          cards[3],
          scale,
          2,
          backgroundLeft: 283,
          backgroundTop: 163,
          backgroundWidth: 100,
          backgroundHeight: 96,
          artworkLeft: 290,
          artworkTop: 160,
          artworkWidth: 87,
          artworkHeight: 76,
          textLeft: 304,
          textTop: 239,
          textWidth: 59,
          textHeight: 13,
          hitLeft: 284,
          hitTop: 164,
          hitWidth: 99,
          hitHeight: 94,
          titleFontSize: 10,
        ),
      ],
    );
  }

  Widget _buildOtherPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 4) return const SizedBox.shrink();
    return _buildSectionStack(
      scale,
      [
        _buildCard(
          cards[0],
          scale,
          3,
          backgroundLeft: -1.71,
          backgroundTop: -0.41,
          backgroundWidth: 180.08,
          backgroundHeight: 270.12,
          artworkLeft: -1.75,
          artworkTop: 41.52,
          artworkWidth: 181.29,
          artworkHeight: 181.29,
          textLeft: 45.92,
          textTop: 196.71,
          textWidth: 85.94,
          textHeight: 46.43,
          hitLeft: -1.71,
          hitTop: -0.41,
          hitWidth: 180.08,
          hitHeight: 270.12,
          titleFontSize: 20,
          titleLineHeight: 0.95625,
        ),
        _buildCard(
          cards[1],
          scale,
          3,
          backgroundLeft: 168,
          backgroundTop: 15,
          backgroundWidth: 220,
          backgroundHeight: 116,
          artworkLeft: 212.22,
          artworkTop: 21.34,
          artworkWidth: 126.18,
          artworkHeight: 84.12,
          textLeft: 211.16,
          textTop: 102.03,
          textWidth: 133.77,
          textHeight: 12.97,
          hitLeft: 168,
          hitTop: 15,
          hitWidth: 220,
          hitHeight: 116,
          titleFontSize: 13,
        ),
        _buildCard(
          cards[2],
          scale,
          3,
          backgroundLeft: 172,
          backgroundTop: 131,
          backgroundWidth: 107,
          backgroundHeight: 139,
          artworkLeft: 179.68,
          artworkTop: 144.92,
          artworkWidth: 92.01,
          artworkHeight: 92.01,
          textLeft: 195.11,
          textTop: 238.71,
          textWidth: 64.44,
          textHeight: 12.97,
          hitLeft: 172,
          hitTop: 131,
          hitWidth: 107,
          hitHeight: 139,
          titleFontSize: 10,
        ),
        _buildCard(
          cards[3],
          scale,
          3,
          backgroundLeft: 278,
          backgroundTop: 131,
          backgroundWidth: 107,
          backgroundHeight: 139,
          artworkLeft: 285.68,
          artworkTop: 144.92,
          artworkWidth: 92.01,
          artworkHeight: 92.01,
          textLeft: 300.86,
          textTop: 238.71,
          textWidth: 64.44,
          textHeight: 12.97,
          hitLeft: 278,
          hitTop: 131,
          hitWidth: 107,
          hitHeight: 139,
          titleFontSize: 10,
        ),
      ],
    );
  }

  Widget _buildSectionStack(double scale, List<Widget> cards) {
    return SizedBox(
      width: 393 * scale,
      height: 301 * scale,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: cards,
      ),
    );
  }

  Widget _buildCard(
    page_models.PageCardModel card,
    double scale,
    int pageIndex, {
    required double backgroundLeft,
    required double backgroundTop,
    required double backgroundWidth,
    required double backgroundHeight,
    required double artworkLeft,
    required double artworkTop,
    required double artworkWidth,
    required double artworkHeight,
    required double textLeft,
    required double textTop,
    required double textWidth,
    required double textHeight,
    required double hitLeft,
    required double hitTop,
    required double hitWidth,
    required double hitHeight,
    required double titleFontSize,
    double titleLineHeight = 1.0,
  }) {
    return FigmaGameCard(
      scale: scale,
      sectionWidth: 393,
      sectionHeight: 301,
      title: card.title,
      imagePath: card.imagePath,
      backgroundImagePath: card.backgroundImagePath!,
      backgroundLeft: backgroundLeft,
      backgroundTop: backgroundTop,
      backgroundWidth: backgroundWidth,
      backgroundHeight: backgroundHeight,
      artworkLeft: artworkLeft,
      artworkTop: artworkTop,
      artworkWidth: artworkWidth,
      artworkHeight: artworkHeight,
      textLeft: textLeft,
      textTop: textTop,
      textWidth: textWidth,
      textHeight: textHeight,
      hitLeft: hitLeft,
      hitTop: hitTop,
      hitWidth: hitWidth,
      hitHeight: hitHeight,
      titleFontSize: titleFontSize,
      titleLineHeight: titleLineHeight,
      onTap: () => _onCardTap(card.title, pageIndex),
    );
  }
}
