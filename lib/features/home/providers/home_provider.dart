import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/home/models/home_data_model.dart';

enum BottomNavItem { events, battle, chat, social }

enum GameModeTab { ludo, domino, jackpot, other }

class HomeState {
  final BottomNavItem bottomNav;
  final GameModeTab gameMode;
  final int cardPageIndex;
  final int myFriendsTabIndex;

  const HomeState({
    this.bottomNav = BottomNavItem.battle,
    this.gameMode = GameModeTab.ludo,
    this.cardPageIndex = 0,
    this.myFriendsTabIndex = 0,
  });

  HomeState copyWith({
    BottomNavItem? bottomNav,
    GameModeTab? gameMode,
    int? cardPageIndex,
    int? myFriendsTabIndex,
  }) {
    return HomeState(
      bottomNav: bottomNav ?? this.bottomNav,
      gameMode: gameMode ?? this.gameMode,
      cardPageIndex: cardPageIndex ?? this.cardPageIndex,
      myFriendsTabIndex: myFriendsTabIndex ?? this.myFriendsTabIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setBottomNav(BottomNavItem item) {
    state = state.copyWith(bottomNav: item);
  }

  void setGameMode(GameModeTab mode) {
    state = state.copyWith(gameMode: mode);
  }

  void setCardPage(int index) {
    state = state.copyWith(cardPageIndex: index);
  }

  void setMyFriendsTab(int index) {
    state = state.copyWith(myFriendsTabIndex: index);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier());

class CountryItem {
  final String name;
  final String flagEmoji;

  const CountryItem({required this.name, required this.flagEmoji});
}

final countriesProvider = Provider<List<CountryItem>>((ref) {
  return const [
    CountryItem(name: 'Pakistan', flagEmoji: '🇵🇰'),
    CountryItem(name: 'India', flagEmoji: '🇮🇳'),
    CountryItem(name: 'Saudi Arabia', flagEmoji: '🇸🇦'),
    CountryItem(name: 'Bangladesh', flagEmoji: '🇧🇩'),
    CountryItem(name: 'UAE', flagEmoji: '🇦🇪'),
    CountryItem(name: 'United Kingdom', flagEmoji: '🇬🇧'),
    CountryItem(name: 'United States', flagEmoji: '🇺🇸'),
  ];
});

class FriendItem {
  final String name;
  final bool isOnline;

  const FriendItem({required this.name, required this.isOnline});
}

final myFriendsProvider = Provider<List<FriendItem>>((ref) {
  return const [];
});

final friendRequestsProvider = Provider<List<FriendItem>>((ref) {
  return const [];
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient: apiClient);
});

final homeDataProvider = FutureProvider.autoDispose<HomeDataModel>((ref) async {
  final homeRepository = ref.watch(homeRepositoryProvider);
  return await homeRepository.getHomeData();
});

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<HomeDataModel> getHomeData() async {
    final response = await _apiClient.get(ApiEndpoints.home);
    return HomeDataModel.fromJson(response);
  }
}
