import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/battle/models/lobby_model.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

final battleRepositoryProvider = Provider<BattleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return BattleRepository(
      apiClient: apiClient, webSocketService: webSocketService);
});

// ======================== Matchmaking State ========================

class MatchmakingState {
  final RoomModel? room;
  final bool isQueueing;
  final String? statusMessage;
  final String? error;

  MatchmakingState({
    this.room,
    this.isQueueing = false,
    this.statusMessage,
    this.error,
  });

  MatchmakingState copyWith({
    RoomModel? room,
    bool? isQueueing,
    String? statusMessage,
    String? error,
  }) {
    return MatchmakingState(
      room: room ?? this.room,
      isQueueing: isQueueing ?? this.isQueueing,
      statusMessage: statusMessage,
      error: error,
    );
  }
}

final matchmakingProvider =
    StateNotifierProvider<MatchmakingNotifier, MatchmakingState>((ref) {
  final battleRepository = ref.watch(battleRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return MatchmakingNotifier(
      battleRepository: battleRepository, webSocketService: webSocketService);
});

class MatchmakingNotifier extends StateNotifier<MatchmakingState> {
  final BattleRepository _battleRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;

  MatchmakingNotifier({
    required BattleRepository battleRepository,
    required WebSocketService webSocketService,
  })  : _battleRepository = battleRepository,
        _webSocketService = webSocketService,
        super(MatchmakingState()) {
    _listenToMatchFoundEvents();
  }

  void _listenToMatchFoundEvents() {
    _wsSubscription = _webSocketService.eventStream.listen((event) {
      if (event.event == 'match.found' || event.event == 'MatchFound') {
        final room = RoomModel.fromJson(event.payload);
        state = state.copyWith(
          room: room,
          isQueueing: false,
          statusMessage: 'Match Found! Starting Game...',
        );
      }
    });
  }

  Future<void> joinQuickMatch({int maxPlayers = 2, int entryFee = 0}) async {
    state = state.copyWith(
        isQueueing: true,
        statusMessage: 'Searching for players...',
        error: null);
    try {
      final room = await _battleRepository.joinMatchmaking(
          maxPlayers: maxPlayers, entryFee: entryFee);
      if (room.status == 'matched') {
        state = state.copyWith(
            room: room, isQueueing: false, statusMessage: 'Match Found!');
      } else {
        state = state.copyWith(
            room: room, isQueueing: true, statusMessage: 'Waiting in queue...');
      }
    } on ApiException catch (e) {
      state = state.copyWith(isQueueing: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isQueueing: false, error: 'Failed to join matchmaking.');
    }
  }

  Future<void> leaveQuickMatch() async {
    try {
      await _battleRepository.leaveMatchmaking();
      state = MatchmakingState();
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: 'Failed to leave matchmaking.');
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}

// ======================== Battle Lobby State ========================

class BattleLobbyState {
  final int selectedTab; // 0 = Explore, 1 = Hot, 2 = My
  final int selectedMySubTab; // 0 = Recently, 1 = Joined, 2 = Following, 3 = Friends
  final String? selectedCountry; // Country code or null for All
  final bool isLoading;
  final String? error;
  final LobbyExploreData? exploreData;
  final LobbyHotData? hotData;
  final Map<String, LobbyMyData> myDataByFilter;

  BattleLobbyState({
    this.selectedTab = 0,
    this.selectedMySubTab = 0,
    this.selectedCountry,
    this.isLoading = false,
    this.error,
    this.exploreData,
    this.hotData,
    this.myDataByFilter = const {},
  });

  BattleLobbyState copyWith({
    int? selectedTab,
    int? selectedMySubTab,
    String? selectedCountry,
    bool clearCountry = false,
    bool? isLoading,
    String? error,
    LobbyExploreData? exploreData,
    LobbyHotData? hotData,
    Map<String, LobbyMyData>? myDataByFilter,
  }) {
    return BattleLobbyState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedMySubTab: selectedMySubTab ?? this.selectedMySubTab,
      selectedCountry: clearCountry ? null : (selectedCountry ?? this.selectedCountry),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      exploreData: exploreData ?? this.exploreData,
      hotData: hotData ?? this.hotData,
      myDataByFilter: myDataByFilter ?? this.myDataByFilter,
    );
  }

  static const List<String> mySubTabFilters = [
    'recently',
    'joined',
    'following',
    'friends',
  ];
}

final battleLobbyProvider = StateNotifierProvider<BattleLobbyNotifier, BattleLobbyState>((ref) {
  final battleRepository = ref.watch(battleRepositoryProvider);
  return BattleLobbyNotifier(battleRepository: battleRepository);
});

class BattleLobbyNotifier extends StateNotifier<BattleLobbyState> {
  final BattleRepository _battleRepository;

  BattleLobbyNotifier({
    required BattleRepository battleRepository,
  })  : _battleRepository = battleRepository,
        super(BattleLobbyState()) {
    loadExploreData();
  }

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
    if (index == 0 && state.exploreData == null) {
      loadExploreData();
    } else if (index == 1 && state.hotData == null) {
      loadHotData();
    } else if (index == 2) {
      loadMyRoomsData(BattleLobbyState.mySubTabFilters[state.selectedMySubTab]);
    }
  }

  void setMySubTab(int subTabIndex) {
    state = state.copyWith(selectedMySubTab: subTabIndex);
    final filter = BattleLobbyState.mySubTabFilters[subTabIndex];
    loadMyRoomsData(filter);
  }

  void selectCountry(String? countryCode) {
    if (state.selectedCountry == countryCode) {
      // Toggle off
      state = state.copyWith(clearCountry: true);
    } else {
      state = state.copyWith(selectedCountry: countryCode);
    }
    loadExploreData();
  }

  Future<void> loadExploreData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _battleRepository.fetchExplore(country: state.selectedCountry);
      state = state.copyWith(exploreData: data, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load lobby explore data');
    }
  }

  Future<void> loadHotData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _battleRepository.fetchHot();
      state = state.copyWith(hotData: data, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load hot lobby data');
    }
  }

  Future<void> loadMyRoomsData(String filter) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _battleRepository.fetchMyRooms(filter: filter);
      final updatedMap = Map<String, LobbyMyData>.from(state.myDataByFilter);
      updatedMap[filter] = data;
      state = state.copyWith(myDataByFilter: updatedMap, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load my rooms data');
    }
  }

  Future<RoomModel?> joinRoomAsListener(int roomId) async {
    try {
      final room = await _battleRepository.joinRoomAsListener(roomId);
      return room;
    } catch (_) {
      return null;
    }
  }
}

// ======================== Battle Repository ========================

class BattleRepository {
  final ApiClient _apiClient;
  final WebSocketService _webSocketService;

  BattleRepository({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  Future<RoomModel> joinMatchmaking(
      {required int maxPlayers, required int entryFee}) async {
    final response = await _apiClient.post(
      ApiEndpoints.matchmakingJoin,
      data: {
        'max_players': maxPlayers,
        'entry_fee': entryFee,
      },
    );
    return RoomModel.fromJson(response);
  }

  Future<void> leaveMatchmaking() async {
    await _apiClient.post(ApiEndpoints.matchmakingLeave);
  }

  Future<RoomModel> createRoom({
    String? title,
    String type = 'public',
    int maxPlayers = 4,
    int entryFee = 0,
  }) async {
    final Map<String, dynamic> data = {
      'type': type,
      'max_players': maxPlayers,
      'entry_fee': entryFee,
    };
    if (title != null && title.isNotEmpty) {
      data['title'] = title;
    }
    final response = await _apiClient.post(
      ApiEndpoints.rooms,
      data: data,
    );
    final room = RoomModel.fromJson(response);
    _webSocketService.subscribeToRoomChannel(room.roomId);
    return room;
  }

  Future<RoomModel> joinRoom(String roomCode) async {
    final response = await _apiClient.post(
      ApiEndpoints.joinRoom,
      data: {'room_code': roomCode},
    );
    final room = RoomModel.fromJson(response);
    _webSocketService.subscribeToRoomChannel(room.roomId);
    return room;
  }

  Future<LobbyExploreData> fetchExplore({String? country, int page = 1}) async {
    final Map<String, dynamic> params = {'page': page};
    if (country != null && country.isNotEmpty) {
      params['country'] = country;
    }
    final response = await _apiClient.get(
      ApiEndpoints.lobbyExplore,
      queryParameters: params,
    );
    return LobbyExploreData.fromJson(response);
  }

  Future<LobbyHotData> fetchHot({int page = 1}) async {
    final response = await _apiClient.get(
      ApiEndpoints.lobbyHot,
      queryParameters: {'page': page},
    );
    return LobbyHotData.fromJson(response);
  }

  Future<LobbyMyData> fetchMyRooms({required String filter, int page = 1}) async {
    final response = await _apiClient.get(
      ApiEndpoints.lobbyMy,
      queryParameters: {
        'filter': filter,
        'page': page,
      },
    );
    return LobbyMyData.fromJson(response);
  }

  Future<RoomModel> joinRoomAsListener(int roomId) async {
    final response = await _apiClient.post(ApiEndpoints.roomJoinListener(roomId));
    final room = RoomModel.fromJson(response);
    _webSocketService.subscribeToRoomChannel(room.roomId);
    return room;
  }
}
