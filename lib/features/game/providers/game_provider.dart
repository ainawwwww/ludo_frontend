import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/game/models/game_state_model.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameRepository(
      apiClient: apiClient, webSocketService: webSocketService);
});

final gameEngineProvider =
    StateNotifierProvider.family<GameEngineNotifier, GameStateModel?, int>(
        (ref, roomId) {
  final gameRepository = ref.watch(gameRepositoryProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return GameEngineNotifier(
      roomId: roomId,
      gameRepository: gameRepository,
      webSocketService: webSocketService);
});

class GameEngineNotifier extends StateNotifier<GameStateModel?> {
  final int roomId;
  final GameRepository _gameRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;
  String? _lastError;
  bool _isFetching = false;

  GameEngineNotifier({
    required this.roomId,
    required GameRepository gameRepository,
    required WebSocketService webSocketService,
  })  : _gameRepository = gameRepository,
        _webSocketService = webSocketService,
        super(null) {
    initGame();
  }

  String? get lastError => _lastError;

  Future<void> initGame() async {
    // Single authoritative subscription for this room
    if (!_webSocketService.isConnected) {
      _webSocketService.connect().then((_) {
        _webSocketService.subscribeToRoomChannel(roomId);
      });
    } else {
      _webSocketService.subscribeToRoomChannel(roomId);
    }

    _listenToRoomEvents();
    await fetchGameState();
  }

  Future<void> fetchGameState({bool silent = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final gameState = await _gameRepository.getGameState(roomId);
      state = gameState;
      if (!silent) _lastError = null;
    } on ApiException catch (e) {
      if (!silent) _lastError = e.message;
    } catch (e) {
      if (!silent) _lastError = 'Failed to fetch game state: $e';
    } finally {
      _isFetching = false;
    }
  }

  void _listenToRoomEvents() {
    _wsSubscription?.cancel();
    _wsSubscription = _webSocketService.eventStream.listen((wsEvent) {
      if (wsEvent.channel != 'private-room.$roomId' &&
          wsEvent.channel != 'room.$roomId') {
        return;
      }

      final evt = wsEvent.event.toLowerCase();
      final payload = wsEvent.payload;

      if (evt == 'dice.rolled' || evt == '.dice.rolled' || evt == 'dicerolled') {
        final diceValue = payload['dice_value'] is int
            ? payload['dice_value'] as int
            : int.tryParse(payload['dice_value']?.toString() ?? '1') ?? 1;
        final userId = payload['user_id'] is int
            ? payload['user_id'] as int
            : int.tryParse(payload['user_id']?.toString() ?? '0') ?? 0;

        final movable = (payload['movable_tokens'] as List<dynamic>?)
                ?.map((t) => int.tryParse(t.toString()) ?? 0)
                .toList() ??
            [];

        if (state != null) {
          state = state!.copyWith(
            diceValue: diceValue,
            hasRolled: true,
            canRoll: false,
            mustMove: movable.isNotEmpty,
            currentTurnUserId: userId,
            movableTokens: movable,
          );
        }
      } else if (evt == 'token.moved' || evt == '.token.moved' || evt == 'tokenmoved') {
        final color = payload['color']?.toString().toLowerCase() ?? '';
        final tokenIndex = payload['token_index'] is int
            ? payload['token_index'] as int
            : int.tryParse(payload['token_index']?.toString() ?? '0') ?? 0;
        final newSteps = payload['new_steps'] is int
            ? payload['new_steps'] as int
            : int.tryParse(payload['new_steps']?.toString() ?? '-1') ?? -1;
        final isKill = payload['is_kill'] == true;
        final killedTokens = payload['killed_tokens'] as List<dynamic>?;

        if (state != null) {
          final updatedPositions = Map<String, List<int>>.from(state!.tokenPositions);
          if (updatedPositions.containsKey(color) &&
              tokenIndex >= 0 &&
              tokenIndex < updatedPositions[color]!.length) {
            final list = List<int>.from(updatedPositions[color]!);
            list[tokenIndex] = newSteps;
            updatedPositions[color] = list;
          }

          if (isKill && killedTokens != null) {
            for (final k in killedTokens) {
              if (k is Map<String, dynamic>) {
                final kColor = k['color']?.toString().toLowerCase();
                final kIdx = k['token_index'] is int
                    ? k['token_index'] as int
                    : int.tryParse(k['token_index']?.toString() ?? '0') ?? 0;
                if (kColor != null && updatedPositions.containsKey(kColor)) {
                  final list = List<int>.from(updatedPositions[kColor]!);
                  if (kIdx >= 0 && kIdx < list.length) {
                    list[kIdx] = -1;
                    updatedPositions[kColor] = list;
                  }
                }
              }
            }
          }

          state = state!.copyWith(
            tokenPositions: updatedPositions,
            canRoll: true,
            mustMove: false,
          );
        }
      } else if (evt == 'turn.changed' || evt == '.turn.changed' || evt == 'turnchanged') {
        final nextSeat = payload['next_seat'] is int
            ? payload['next_seat'] as int
            : int.tryParse(payload['next_seat']?.toString() ??
                    payload['current_turn_seat']?.toString() ??
                    '0') ??
                0;

        final nextUserId = payload['next_user_id'] is int
            ? payload['next_user_id'] as int
            : int.tryParse(payload['next_user_id']?.toString() ??
                    payload['current_turn_user_id']?.toString() ??
                    '0');

        if (state != null) {
          state = state!.copyWith(
            currentTurnSeat: nextSeat,
            currentTurnUserId: nextUserId,
            hasRolled: false,
            canRoll: true,
            mustMove: false,
            diceValue: null,
            movableTokens: [],
          );
        }
      } else if (evt == 'game.ended' || evt == '.game.ended' || evt == 'gameended') {
        final winnerId = payload['winner_id'] is int
            ? payload['winner_id'] as int
            : int.tryParse(payload['winner_id']?.toString() ?? '0');

        if (state != null) {
          state = state!.copyWith(
            status: 'completed',
            winnerUserId: winnerId,
          );
        }
      } else if (evt == 'player.forfeited' ||
          evt == 'game.started' ||
          evt == 'room.updated') {
        fetchGameState(silent: true);
      }
    });
  }

  /// Optimistically update a token's position for smooth local UI response (defaults to OFF)
  static bool enableOptimisticMoves = false;

  void applyOptimisticMove(String color, int tokenIndex, int targetStep) {
    if (!enableOptimisticMoves || state == null) return;
    final updatedPositions = Map<String, List<int>>.from(state!.tokenPositions);
    final c = color.toLowerCase();
    if (updatedPositions.containsKey(c) &&
        tokenIndex >= 0 &&
        tokenIndex < updatedPositions[c]!.length) {
      final list = List<int>.from(updatedPositions[c]!);
      list[tokenIndex] = targetStep;
      updatedPositions[c] = list;

      state = state!.copyWith(
        tokenPositions: updatedPositions,
        mustMove: false,
        canRoll: false,
        movableTokens: [],
      );
    }
  }

  Future<bool> rollDice() async {
    if (state == null) return false;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final res = await _gameRepository.rollDice(roomId);
        if (res != null && res['data'] is Map<String, dynamic>) {
          final data = res['data'] as Map<String, dynamic>;
          if (data.containsKey('game_state') && data['game_state'] is Map<String, dynamic>) {
            state = GameStateModel.fromJson(data['game_state'] as Map<String, dynamic>);
          } else if (data.containsKey('token_positions')) {
            state = GameStateModel.fromJson(data);
          }
        }
        _lastError = null;
        return true;
      } on ApiException catch (e) {
        if (e.statusCode == 409 && attempt == 0) {
          // Retry once after ~300ms on HTTP 409 Conflict / Lock contention
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        _lastError = e.message;
        await fetchGameState(silent: true); // Reconcile authoritative state; never leave UI stuck
        return false;
      } catch (e) {
        _lastError = 'Dice roll failed.';
        await fetchGameState(silent: true);
        return false;
      }
    }
    return false;
  }

  Future<bool> moveToken(int tokenIndex) async {
    if (state == null) return false;
    final previousState = state;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final res = await _gameRepository.moveToken(roomId, tokenIndex);
        if (res != null && res['data'] is Map<String, dynamic>) {
          final data = res['data'] as Map<String, dynamic>;
          if (data.containsKey('game_state') && data['game_state'] is Map<String, dynamic>) {
            state = GameStateModel.fromJson(data['game_state'] as Map<String, dynamic>);
          } else if (data.containsKey('token_positions')) {
            state = GameStateModel.fromJson(data);
          }
        }
        _lastError = null;
        return true;
      } on ApiException catch (e) {
        if (e.statusCode == 409 && attempt == 0) {
          // Retry once after ~300ms on HTTP 409 Conflict / Lock contention
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        _lastError = e.message;
        if (enableOptimisticMoves && previousState != null) {
          state = previousState;
        }
        await fetchGameState(silent: true); // Server state always wins; reconcile to never leave UI stuck
        return false;
      } catch (e) {
        _lastError = 'Token move failed.';
        if (enableOptimisticMoves && previousState != null) {
          state = previousState;
        }
        await fetchGameState(silent: true);
        return false;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeChannel('private-room.$roomId');
    _webSocketService.unsubscribeChannel('room.$roomId');
    super.dispose();
  }
}

class GameRepository {
  final ApiClient _apiClient;

  GameRepository({
    required ApiClient apiClient,
    WebSocketService? webSocketService,
  })  : _apiClient = apiClient;

  Future<void> startGame(int roomId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.gameStart,
        data: {'room_id': roomId},
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await _apiClient.post(
          '/quick-match/start',
          data: {'quick_match_id': roomId},
        );
      } else {
        rethrow;
      }
    }
  }

  Future<GameStateModel> getGameState(int roomId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.gameState,
        queryParameters: {'room_id': roomId},
      );
      return GameStateModel.fromJson(response);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final response = await _apiClient.get(
          ApiEndpoints.quickMatchState,
          queryParameters: {'quick_match_id': roomId},
        );
        return GameStateModel.fromJson(response);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> rollDice(int roomId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.gameRoll,
        data: {'room_id': roomId},
      );
      return response is Map<String, dynamic> ? response : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final response = await _apiClient.post(
          ApiEndpoints.quickMatchRoll,
          data: {'quick_match_id': roomId},
        );
        return response is Map<String, dynamic> ? response : null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> moveToken(int roomId, int tokenIndex) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.gameMove,
        data: {
          'room_id': roomId,
          'token_index': tokenIndex,
        },
      );
      return response is Map<String, dynamic> ? response : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final response = await _apiClient.post(
          ApiEndpoints.quickMatchMove,
          data: {
            'quick_match_id': roomId,
            'token_index': tokenIndex,
          },
        );
        return response is Map<String, dynamic> ? response : null;
      }
      rethrow;
    }
  }
}

