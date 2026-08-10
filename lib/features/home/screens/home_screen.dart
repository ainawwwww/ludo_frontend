import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/home/models/game_card_model.dart' as page_models;
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/features/home/widgets/settings_dialogs.dart';
import 'package:ludo_vibe/shared/widgets/bottom_nav_bar.dart';
import 'package:ludo_vibe/shared/widgets/game_card.dart';
import 'package:ludo_vibe/shared/widgets/game_mode_tabs.dart';
import 'package:ludo_vibe/shared/widgets/league_banner.dart';
import 'package:ludo_vibe/shared/widgets/page_dots_indicator.dart';
import 'package:ludo_vibe/shared/widgets/top_bar.dart';
import 'package:ludo_vibe/shared/widgets/welcome_popup.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static bool _welcomePopupShown = false;
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
            backgroundImagePath: 'assets/graphics/ludogamemode/2&4player Yellow button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.horizontalLeftImage,
            flex: 58,
          ),
          page_models.PageCardModel(
            title: 'Tournament',
            imagePath: 'assets/graphics/ludogamemode/Tournament_png.png',
            backgroundImagePath: 'assets/graphics/ludogamemode/tournament Green button.png',
            size: page_models.CardSize.large,
            flex: 40,
          ),
          page_models.PageCardModel(
            title: 'Team',
            imagePath: 'assets/graphics/ludogamemode/team_Png.png',
            backgroundImagePath: 'assets/graphics/ludogamemode/team orange_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Private',
            imagePath: 'assets/graphics/ludogamemode/privatepng2.png',
            backgroundImagePath: 'assets/graphics/ludogamemode/private_Green_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/ludogamemode/vip_png.png',
            backgroundImagePath: 'assets/graphics/ludogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 1: // Page 2 - Domino
        return [
          page_models.PageCardModel(
            title: '1 ON 1',
            imagePath: 'assets/graphics/dominogamemode/1on1_png.png',
            backgroundImagePath: 'assets/graphics/dominogamemode/1on1 blue button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: '4Player',
            imagePath: 'assets/graphics/dominogamemode/4player_png.png',
            backgroundImagePath: 'assets/graphics/dominogamemode/4player orange_button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Tournament',
            imagePath: 'assets/graphics/dominogamemode/Tournament_png.png',
            backgroundImagePath: 'assets/graphics/dominogamemode/tournament Green button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Private',
            imagePath: 'assets/graphics/dominogamemode/privatepng2.png',
            backgroundImagePath: 'assets/graphics/dominogamemode/private_Green_button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/dominogamemode/vip_png.png',
            backgroundImagePath: 'assets/graphics/dominogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 2: // Page 3 - Jackaroo
        return [
          page_models.PageCardModel(
            title: '1 VS 1',
            imagePath: 'assets/graphics/jackaroogamemode/1v1_png.png',
            backgroundImagePath: 'assets/graphics/jackaroogamemode/1vs1_greenbutton.png',
            size: page_models.CardSize.large,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: 'Basic',
            imagePath: 'assets/graphics/jackaroogamemode/basic_png.png',
            backgroundImagePath: 'assets/graphics/jackaroogamemode/basic_blue_button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Complex',
            imagePath: 'assets/graphics/jackaroogamemode/Complex_png.png',
            backgroundImagePath: 'assets/graphics/jackaroogamemode/complex_yellowbutton.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'VIP Room',
            imagePath: 'assets/graphics/jackaroogamemode/vip_png.png',
            backgroundImagePath: 'assets/graphics/jackaroogamemode/Vip_purple_button.png',
            size: page_models.CardSize.small,
          ),
        ];
      case 3: // Page 4 - Other
        return [
          page_models.PageCardModel(
            title: 'Jungle\nLudo',
            imagePath: 'assets/graphics/othergamemode/jungleludo_png.png',
            backgroundImagePath: 'assets/graphics/othergamemode/jungleludo orangebutton.png',
            size: page_models.CardSize.large,
            flex: 50,
          ),
          page_models.PageCardModel(
            title: 'Snakes &\nLadders',
            imagePath: 'assets/graphics/othergamemode/snakes and ladder png.png',
            backgroundImagePath: 'assets/graphics/othergamemode/snakesandladder button.png',
            size: page_models.CardSize.large,
            layoutType: page_models.CardLayoutType.vertical,
            flex: 48,
          ),
          page_models.PageCardModel(
            title: 'Night Ludo',
            imagePath: 'assets/graphics/othergamemode/nightludo_png.png',
            backgroundImagePath: 'assets/graphics/othergamemode/night ludo button.png',
            size: page_models.CardSize.small,
          ),
          page_models.PageCardModel(
            title: 'Fight Ludo',
            imagePath: 'assets/graphics/othergamemode/fight ludo png.png',
            backgroundImagePath: 'assets/graphics/othergamemode/fight ludo button.png',
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
          // Background main image
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Top Bar
                              ref.watch(homeDataProvider).when(
                                    data: (homeData) => TopBar(
                                      playerName: homeData.username,
                                      coins: '${homeData.coins}',
                                      diamonds: '${homeData.diamonds}',
                                      level: homeData.level,
                                      onSettingsTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const MainSettingsDialog(),
                                        );
                                      },
                                    ),
                                    loading: () => TopBar(
                                      onSettingsTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const MainSettingsDialog(),
                                        );
                                      },
                                    ),
                                    error: (_, __) => TopBar(
                                      onSettingsTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const MainSettingsDialog(),
                                        );
                                      },
                                    ),
                                  ),
                              SizedBox(height: 10 * scale),
                              // League banner
                              const LeagueBanner(),
                              
                              // Flexible spacer pushing cards further down
                              const Spacer(flex: 6),
                              
                              // PageView with 4 pages
                              SizedBox(
                                height: 270 * scale,
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    // Update homeProvider's cardPageIndex and gameMode
                                    ref.read(homeProvider.notifier).setCardPage(index);
                                    ref.read(homeProvider.notifier).setGameMode(_indexToGameMode(index));
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
                  }
                ),
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
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: _buildLayoutForPage(pageIndex, cards, scale),
    );
  }

  Widget _buildLayoutForPage(int pageIndex, List<page_models.PageCardModel> cards, double scale) {
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
    final card1 = cards[0]; // 2&4 Players
    final card2 = cards[1]; // Tournament
    final card3 = cards[2]; // Team
    final card4 = cards[3]; // Private
    final card5 = cards[4]; // VIP Room

    return Column(
      children: [
        SizedBox(
          height: 140 * scale,
          child: Row(
            children: [
              Expanded(
                flex: 58,
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card1, scale, 0),
                ),
              ),
              Expanded(
                flex: 42,
                child: _buildCard(card2, scale, 0),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          height: 110 * scale,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card3, scale, 0),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card4, scale, 0),
                ),
              ),
              Expanded(
                child: _buildCard(card5, scale, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDominoPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 5) return const SizedBox.shrink();
    final card1 = cards[0]; // 1 ON 1
    final card2 = cards[1]; // 4Player
    final card3 = cards[2]; // Tournament
    final card4 = cards[3]; // Private
    final card5 = cards[4]; // VIP Room

    return Column(
      children: [
        SizedBox(
          height: 140 * scale,
          child: Row(
            children: [
              Expanded(
                flex: 50,
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card1, scale, 1),
                ),
              ),
              Expanded(
                flex: 50,
                child: _buildCard(card2, scale, 1),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          height: 110 * scale,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card3, scale, 1),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8 * scale),
                  child: _buildCard(card4, scale, 1),
                ),
              ),
              Expanded(
                child: _buildCard(card5, scale, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJackarooPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 4) return const SizedBox.shrink();
    final card1 = cards[0]; // 1 VS 1
    final card2 = cards[1]; // Basic
    final card3 = cards[2]; // Complex
    final card4 = cards[3]; // VIP Room

    return SizedBox(
      height: 258 * scale,
      child: Row(
        children: [
          // Left Column
          Expanded(
            flex: 42,
            child: Padding(
              padding: EdgeInsets.only(right: 8 * scale),
              child: _buildCard(card1, scale, 2),
            ),
          ),
          // Right Column
          Expanded(
            flex: 58,
            child: Column(
              children: [
                SizedBox(
                  height: 140 * scale,
                  child: _buildCard(card2, scale, 2),
                ),
                SizedBox(height: 8 * scale),
                SizedBox(
                  height: 110 * scale,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 8 * scale),
                          child: _buildCard(card3, scale, 2),
                        ),
                      ),
                      Expanded(
                        child: _buildCard(card4, scale, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPage(List<page_models.PageCardModel> cards, double scale) {
    if (cards.length < 4) return const SizedBox.shrink();
    final card1 = cards[0]; // Jungle Ludo
    final card2 = cards[1]; // Snakes & Ladders
    final card3 = cards[2]; // Night Ludo
    final card4 = cards[3]; // Fight Ludo

    return SizedBox(
      height: 258 * scale,
      child: Row(
        children: [
          // Left Column
          Expanded(
            flex: 42,
            child: Padding(
              padding: EdgeInsets.only(right: 8 * scale),
              child: _buildCard(card1, scale, 3),
            ),
          ),
          // Right Column
          Expanded(
            flex: 58,
            child: Column(
              children: [
                SizedBox(
                  height: 140 * scale,
                  child: _buildCard(card2, scale, 3),
                ),
                SizedBox(height: 8 * scale),
                SizedBox(
                  height: 110 * scale,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 8 * scale),
                          child: _buildCard(card3, scale, 3),
                        ),
                      ),
                      Expanded(
                        child: _buildCard(card4, scale, 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(page_models.PageCardModel card, double scale, int pageIndex) {
    CardLayoutType gameCardLayout = CardLayoutType.vertical;
    switch (card.layoutType) {
      case page_models.CardLayoutType.vertical:
        gameCardLayout = CardLayoutType.vertical;
        break;
      case page_models.CardLayoutType.horizontalLeftImage:
        gameCardLayout = CardLayoutType.horizontalLeftImage;
        break;
      case page_models.CardLayoutType.horizontalRightImage:
        gameCardLayout = CardLayoutType.horizontalRightImage;
        break;
    }

    return GameCard(
      title: card.title,
      imagePath: card.imagePath,
      backgroundImagePath: card.backgroundImagePath,
      gradientColors: card.gradientColors,
      titleFontSize: card.size == page_models.CardSize.large ? 14.5 : 12.0,
      borderRadius: 14.0,
      layoutType: gameCardLayout,
      onTap: () => _onCardTap(card.title, pageIndex),
    );
  }
}
