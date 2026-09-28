import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/game/providers/game_provider.dart';

class FakeApiClient implements ApiClient {
  Map<String, dynamic>? lastPostData;
  String? lastPostPath;

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastPostPath = path;
    lastPostData = data as Map<String, dynamic>?;
    return {
      'status': 'success',
      'data': {
        'dice_value': 6,
        'movable_tokens': [0],
        'token_positions': {
          'red': [0, -1, -1, -1],
          'yellow': [-1, -1, -1, -1],
        },
      },
    };
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return {
      'status': 'success',
      'data': {
        'room_id': 101,
        'game_id': 501,
        'current_turn_user_id': 1,
        'current_turn_seat': 0,
        'dice_value': null,
        'can_roll': true,
        'must_move': false,
        'turn_seconds': 15,
        'token_positions': {
          'red': [-1, -1, -1, -1],
          'yellow': [-1, -1, -1, -1],
        },
        'players': [
          {'user_id': 1, 'seat_position': 1, 'color': 'red', 'username': 'Alice'},
          {'user_id': 2, 'seat_position': 2, 'color': 'yellow', 'username': 'Bob'},
        ],
      },
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWebSocketService implements WebSocketService {
  final _controller = StreamController<WebSocketEvent>.broadcast();
  bool connected = true;

  @override
  bool get isConnected => connected;

  @override
  Stream<WebSocketEvent> get eventStream => _controller.stream;

  @override
  Future<void> subscribeToRoomChannel(int roomId) async {}

  @override
  Future<void> unsubscribeChannel(String channel) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void emit(String event, String channel, Map<String, dynamic> payload) {
    _controller.add(WebSocketEvent(event: event, channel: channel, payload: payload));
  }

  void close() {
    _controller.close();
  }
}

void main() {
  group('Phase 1d - GameEngineProvider Single Source of Truth', () {
    late FakeApiClient mockApi;
    late FakeWebSocketService fakeWs;
    late GameRepository repository;
    late GameEngineNotifier notifier;

    setUp(() {
      mockApi = FakeApiClient();
      fakeWs = FakeWebSocketService();
      repository = GameRepository(apiClient: mockApi, webSocketService: fakeWs);
      notifier = GameEngineNotifier(
        roomId: 101,
        gameRepository: repository,
        webSocketService: fakeWs,
      );
    });

    tearDown(() {
      notifier.dispose();
      fakeWs.close();
    });

    test('Initializes authoritative state from backend API', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final state = notifier.state;
      expect(state, isNotNull);
      expect(state!.roomId, 101);
      expect(state.currentTurnUserId, 1);
      expect(state.currentTurnSeat, 0);
      expect(state.canRoll, isTrue);
      expect(state.mustMove, isFalse);
      expect(state.tokenPositions['red'], [-1, -1, -1, -1]);
      expect(state.players.length, 2);
    });

    test('Processes dice.rolled WebSocket event and updates state', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      fakeWs.emit('dice.rolled', 'room.101', {
        'dice_value': 4,
        'user_id': 1,
        'movable_tokens': [0, 1],
      });

      await Future.delayed(const Duration(milliseconds: 50));
      final state = notifier.state!;
      expect(state.diceValue, 4);
      expect(state.canRoll, isFalse);
      expect(state.mustMove, isTrue);
      expect(state.movableTokens, [0, 1]);
    });

    test('Applies optimistic move immediately and updates state without snapping', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      // Optimistically move red token 0 from -1 to 0
      notifier.applyOptimisticMove('red', 0, 0);

      final state = notifier.state!;
      expect(state.tokenPositions['red']![0], 0);
      expect(state.mustMove, isFalse);
      expect(state.canRoll, isFalse);
    });

    test('Processes token.moved event with kill and resets victim to base', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      // Setup yellow token 0 at step 10
      notifier.applyOptimisticMove('yellow', 0, 10);
      expect(notifier.state!.tokenPositions['yellow']![0], 10);

      // Red moves to 10 and kills yellow 0
      fakeWs.emit('token.moved', 'room.101', {
        'color': 'red',
        'token_index': 0,
        'new_steps': 10,
        'is_kill': true,
        'killed_tokens': [
          {'color': 'yellow', 'token_index': 0}
        ],
      });

      await Future.delayed(const Duration(milliseconds: 50));
      final state = notifier.state!;
      expect(state.tokenPositions['red']![0], 10);
      expect(state.tokenPositions['yellow']![0], -1); // reset to base!
      expect(state.canRoll, isTrue);
      expect(state.mustMove, isFalse);
    });

    test('Processes turn.changed and resets turn state', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      fakeWs.emit('turn.changed', 'room.101', {
        'next_seat': 1,
        'next_user_id': 2,
      });

      await Future.delayed(const Duration(milliseconds: 50));
      final state = notifier.state!;
      expect(state.currentTurnSeat, 1);
      expect(state.currentTurnUserId, 2);
      expect(state.hasRolled, isFalse);
      expect(state.canRoll, isTrue);
      expect(state.diceValue, isNull);
      expect(state.movableTokens, isEmpty);
    });

    test('Processes game.ended and sets status completed', () async {
      await Future.delayed(const Duration(milliseconds: 50));

      fakeWs.emit('game.ended', 'room.101', {
        'winner_id': 1,
      });

      await Future.delayed(const Duration(milliseconds: 50));
      final state = notifier.state!;
      expect(state.status, 'completed');
      expect(state.winnerUserId, 1);
    });
  });
}
