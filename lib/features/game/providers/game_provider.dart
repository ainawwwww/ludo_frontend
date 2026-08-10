import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/game/models/game_state_model.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameRepository(apiClient: apiClient, webSocketService: webSocketService);
});

final gameEngineProvider = StateNotifierProvider.family<GameEngineNotifier, GameStateModel?, int>((ref, roomId) {
  final gameRepository = ref.watch(gameRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameEngineNotifier(roomId: roomId, gameRepository: gameRepository, webSocketService: webSocketService);
});

class GameEngineNotifier extends StateNotifier<GameStateModel?> {
  final int roomId;
  final GameRepository _gameRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;

  GameEngineNotifier({
    required this.roomId,
    required GameRepository gameRepository,
    required WebSocketService webSocketService,
  })  : _gameRepository = gameRepository,
        _webSocketService = webSocketService,
        super(null) {
    initGame();
  }

  Future<void> initGame() async {
    _webSocketService.subscribeToRoomChannel(roomId);
    _listenToRoomEvents();
    await fetchGameState();
  }

  Future<void> fetchGameState() async {
    try {
      final gameState = await _gameRepository.getGameState(roomId);
      state = gameState;
    } catch (_) {}
  }

  void _listenToRoomEvents() {
    _wsSubscription = _webSocketService.eventStream.listen((wsEvent) {
      if (wsEvent.channel != 'room.$roomId' && wsEvent.channel != 'private-room.$roomId') return;

      switch (wsEvent.event) {
        case 'DiceRolled':
          final diceValue = wsEvent.payload['dice_value'] is int
              ? wsEvent.payload['dice_value'] as int
              : int.tryParse(wsEvent.payload['dice_value']?.toString() ?? '1') ?? 1;
          final userId = wsEvent.payload['user_id'] is int
              ? wsEvent.payload['user_id'] as int
              : int.tryParse(wsEvent.payload['user_id']?.toString() ?? '0') ?? 0;

          if (state != null) {
            state = state!.copyWith(
              diceValue: diceValue,
              hasRolled: true,
              currentTurnUserId: userId,
            );
          }
          break;

        case 'TokenMoved':
          fetchGameState();
          break;

        case 'TurnChanged':
          final nextUserId = wsEvent.payload['next_user_id'] is int
              ? wsEvent.payload['next_user_id'] as int
              : int.tryParse(wsEvent.payload['next_user_id']?.toString() ?? '0') ?? 0;

          if (state != null) {
            state = state!.copyWith(
              currentTurnUserId: nextUserId,
              hasRolled: false,
              diceValue: null,
            );
          }
          break;

        case 'GameEnded':
          final winnerId = wsEvent.payload['winner_id'] is int
              ? wsEvent.payload['winner_id'] as int
              : int.tryParse(wsEvent.payload['winner_id']?.toString() ?? '0');

          if (state != null) {
            state = state!.copyWith(winnerUserId: winnerId);
          }
          break;
      }
    });
  }

  Future<void> rollDice() async {
    if (state == null) return;
    try {
      await _gameRepository.rollDice(roomId);
    } catch (_) {}
  }

  Future<void> moveToken(int tokenIndex) async {
    if (state == null) return;
    try {
      await _gameRepository.moveToken(roomId, tokenIndex);
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeChannel('private-room.$roomId');
    super.dispose();
  }
}

class GameRepository {
  final ApiClient _apiClient;
  final WebSocketService _webSocketService;

  GameRepository({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  Future<void> startGame(int roomId) async {
    await _apiClient.post(
      ApiEndpoints.gameStart,
      data: {'room_id': roomId},
    );
  }

  Future<GameStateModel> getGameState(int roomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.gameState,
      queryParameters: {'room_id': roomId},
    );
    return GameStateModel.fromJson(response);
  }

  Future<void> rollDice(int roomId) async {
    await _apiClient.post(
      ApiEndpoints.gameRoll,
      data: {'room_id': roomId},
    );
  }

  Future<void> moveToken(int roomId, int tokenIndex) async {
    await _apiClient.post(
      ApiEndpoints.gameMove,
      data: {
        'room_id': roomId,
        'token_index': tokenIndex,
      },
    );
  }
}
