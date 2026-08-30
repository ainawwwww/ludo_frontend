import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/battle/models/room_model.dart';

final battleRepositoryProvider = Provider<BattleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return BattleRepository(
      apiClient: apiClient, webSocketService: webSocketService);
});

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

  Future<RoomModel> createRoom(
      {String type = 'public', int maxPlayers = 4, int entryFee = 0}) async {
    final response = await _apiClient.post(
      ApiEndpoints.rooms,
      data: {
        'type': type,
        'max_players': maxPlayers,
        'entry_fee': entryFee,
      },
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
}
