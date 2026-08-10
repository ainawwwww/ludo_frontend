import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameModeTab { ludo, domino, jackpot, other }

enum BottomNavItem { events, battle, chat, social }

class GameCardModel {
  const GameCardModel({
    required this.title,
    required this.gradientColors,
    required this.icon,
    this.isLarge = false,
    this.subtitle,
  });

  final String title;
  final List<Color> gradientColors;
  final IconData icon;
  final bool isLarge;
  final String? subtitle;
}

class FriendModel {
  const FriendModel({
    required this.name,
    required this.isOnline,
    this.level,
  });

  final String name;
  final bool isOnline;
  final int? level;
}

class CountryModel {
  const CountryModel({
    required this.name,
    required this.flagEmoji,
  });

  final String name;
  final String flagEmoji;
}

class HomeState {
  const HomeState({
    this.gameMode = GameModeTab.ludo,
    this.bottomNav = BottomNavItem.battle,
    this.cardPageIndex = 0,
    this.myFriendsTabIndex = 0,
  });

  final GameModeTab gameMode;
  final BottomNavItem bottomNav;
  final int cardPageIndex;
  final int myFriendsTabIndex;

  HomeState copyWith({
    GameModeTab? gameMode,
    BottomNavItem? bottomNav,
    int? cardPageIndex,
    int? myFriendsTabIndex,
  }) {
    return HomeState(
      gameMode: gameMode ?? this.gameMode,
      bottomNav: bottomNav ?? this.bottomNav,
      cardPageIndex: cardPageIndex ?? this.cardPageIndex,
      myFriendsTabIndex: myFriendsTabIndex ?? this.myFriendsTabIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setGameMode(GameModeTab mode) {
    int index = 0;
    switch (mode) {
      case GameModeTab.ludo:
        index = 0;
        break;
      case GameModeTab.domino:
        index = 1;
        break;
      case GameModeTab.jackpot:
        index = 2;
        break;
      case GameModeTab.other:
        index = 3;
        break;
    }
    state = state.copyWith(gameMode: mode, cardPageIndex: index);
  }

  void setBottomNav(BottomNavItem item) {
    state = state.copyWith(bottomNav: item);
  }

  void setCardPage(int index) {
    state = state.copyWith(cardPageIndex: index);
  }

  void setMyFriendsTab(int index) {
    state = state.copyWith(myFriendsTabIndex: index);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);

final gameCardsProvider = Provider<List<GameCardModel>>((ref) {
  final mode = ref.watch(homeProvider).gameMode;
  return _cardsForMode(mode);
});

List<GameCardModel> _cardsForMode(GameModeTab mode) {
  switch (mode) {
    case GameModeTab.ludo:
      return const [
        GameCardModel(
          title: '2&4\nPlayers',
          gradientColors: [Color(0xFFFFD200), Color(0xFFFF8C00)],
          icon: Icons.casino_outlined,
          isLarge: true,
        ),
        GameCardModel(
          title: 'Tournament',
          gradientColors: [Color(0xFF56AB2F), Color(0xFF1D976C)],
          icon: Icons.emoji_events_outlined,
        ),
        GameCardModel(
          title: 'Team',
          gradientColors: [Color(0xFFFF8C00), Color(0xFFE31E24)],
          icon: Icons.flag_outlined,
        ),
        GameCardModel(
          title: 'Private',
          gradientColors: [Color(0xFF00D2FF), Color(0xFF0072BC)],
          icon: Icons.lock_outline,
        ),
        GameCardModel(
          title: 'VIP Room',
          gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          icon: Icons.workspace_premium_outlined,
        ),
      ];
    case GameModeTab.domino:
      return const [
        GameCardModel(
          title: '1 ON 1',
          gradientColors: [Color(0xFF5641F8), Color(0xFF36289E)],
          icon: Icons.style_outlined,
          isLarge: true,
        ),
        GameCardModel(
          title: '4 Player',
          gradientColors: [Color(0xFF6D55D0), Color(0xFF3C00A5)],
          icon: Icons.groups_outlined,
        ),
        GameCardModel(
          title: 'Tournament',
          gradientColors: [Color(0xFF56AB2F), Color(0xFF1D976C)],
          icon: Icons.emoji_events_outlined,
        ),
        GameCardModel(
          title: 'Private',
          gradientColors: [Color(0xFF00D2FF), Color(0xFF0072BC)],
          icon: Icons.lock_outline,
        ),
        GameCardModel(
          title: 'VIP Room',
          gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          icon: Icons.workspace_premium_outlined,
        ),
      ];
    case GameModeTab.jackpot:
      return const [
        GameCardModel(
          title: '1 VS 1',
          gradientColors: [Color(0xFFFFD200), Color(0xFFFF6B00)],
          icon: Icons.flash_on_outlined,
          isLarge: true,
        ),
        GameCardModel(
          title: 'Calculator',
          gradientColors: [Color(0xFF5641F8), Color(0xFF221793)],
          icon: Icons.calculate_outlined,
        ),
        GameCardModel(
          title: 'VIP Room',
          gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          icon: Icons.workspace_premium_outlined,
        ),
      ];
    case GameModeTab.other:
      return const [
        GameCardModel(
          title: 'Snakes &\nLadders',
          gradientColors: [Color(0xFF00A859), Color(0xFF1D976C)],
          icon: Icons.timeline_outlined,
          isLarge: true,
        ),
        GameCardModel(
          title: 'Jungle Ludo',
          gradientColors: [Color(0xFF56AB2F), Color(0xFF2E7D32)],
          icon: Icons.park_outlined,
        ),
        GameCardModel(
          title: 'Night Ludo',
          gradientColors: [Color(0xFF3C00A5), Color(0xFF0A0022)],
          icon: Icons.nightlight_round,
        ),
      ];
  }
}

final springFriendsProvider = Provider<List<FriendModel>>((_) {
  return const [
    FriendModel(name: 'Ahmed', isOnline: true, level: 22),
    FriendModel(name: 'Sara', isOnline: true, level: 18),
    FriendModel(name: 'Omar', isOnline: false, level: 31),
    FriendModel(name: 'Fatima', isOnline: true, level: 15),
    FriendModel(name: 'Hassan', isOnline: false, level: 27),
  ];
});

final myFriendsProvider = Provider<List<FriendModel>>((_) {
  return const [
    FriendModel(name: 'Ali', isOnline: true, level: 33),
    FriendModel(name: 'Bilal', isOnline: false, level: 19),
    FriendModel(name: 'Zain', isOnline: true, level: 24),
    FriendModel(name: 'Maryam', isOnline: false, level: 12),
  ];
});

final friendRequestsProvider = Provider<List<FriendModel>>((_) {
  return const [
    FriendModel(name: 'Khalid', isOnline: true, level: 20),
    FriendModel(name: 'Noor', isOnline: false, level: 16),
  ];
});

final countriesProvider = Provider<List<CountryModel>>((_) {
  return const [
    CountryModel(name: 'Malta', flagEmoji: '🇲🇹'),
    CountryModel(name: 'Kosovo', flagEmoji: '🇽🇰'),
    CountryModel(name: 'Denmark', flagEmoji: '🇩🇰'),
    CountryModel(name: 'Kyrgyzstan', flagEmoji: '🇰🇬'),
    CountryModel(name: 'Bulgaria', flagEmoji: '🇧🇬'),
    CountryModel(name: 'Tanzania', flagEmoji: '🇹🇿'),
    CountryModel(name: 'Bosnia and Herzegovina', flagEmoji: '🇧🇦'),
    CountryModel(name: 'Chad', flagEmoji: '🇹🇩'),
    CountryModel(name: 'Mauritania', flagEmoji: '🇲🇷'),
    CountryModel(name: 'Moldova', flagEmoji: '🇲🇩'),
    CountryModel(name: 'Mauritius', flagEmoji: '🇲🇺'),
    CountryModel(name: 'Chile', flagEmoji: '🇨🇱'),
    CountryModel(name: 'Czechia', flagEmoji: '🇨🇿'),
    CountryModel(name: 'Ukraine', flagEmoji: '🇺🇦'),
    CountryModel(name: 'Poland', flagEmoji: '🇵🇱'),
    CountryModel(name: 'Pakistan', flagEmoji: '🇵🇰'),
    CountryModel(name: 'India', flagEmoji: '🇮🇳'),
    CountryModel(name: 'KSA', flagEmoji: '🇸🇦'),
    CountryModel(name: 'UAE', flagEmoji: '🇦🇪'),
    CountryModel(name: 'Algeria', flagEmoji: '🇩🇿'),
  ];
});
