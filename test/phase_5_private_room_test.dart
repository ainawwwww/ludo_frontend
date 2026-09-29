// test/phase_5_private_room_test.dart
//
// Phase 5 tests:
// 1. PrivateRoomDto  — JSON parsing (all fields, missing fields, canStart logic, status mapping)
// 2. RoomFailure     — sealed type coverage
// 3. LudoBoardArgs   — typed navigation argument serialization and defaults
// 4. PrivateRoomController — state transitions, restoreActiveRoom, version gap resync, double-nav guard
// 5. PrivateRoomJoinScreen — UI validation, paste button
// 6. PrivateRoomCreateScreen — settings whitelist (2/4 players only, allowed entry fees only)
//
// All tests are OFFLINE (no network, no Pusher).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/game/models/ludo_board_args.dart';
import 'package:ludo_vibe/features/game/models/room_mode.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_create_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_join_screen.dart';

// ---------------------------------------------------------------------------
// Helpers

Map<String, dynamic> _makeRoomJson({
  int id = 42,
  String roomCode = 'ABCDE1',
  String status = 'waiting',
  int maxPlayers = 2,
  int entryFee = 500,
  int turnSeconds = 15,
  int stateVersion = 3,
  List<Map<String, dynamic>> players = const [],
  int? gameId,
}) =>
    {
      'data': {
        'id': id,
        'room_code': roomCode,
        'status': status,
        'max_players': maxPlayers,
        'entry_fee': entryFee,
        'turn_seconds': turnSeconds,
        'state_version': stateVersion,
        'players': players,
        if (gameId != null) 'game_id': gameId,
      }
    };

Map<String, dynamic> _makePlayer({
  int userId = 1,
  String name = 'Alice',
  int seat = 1,
  String color = 'red',
  bool isReady = false,
  bool isHost = false,
}) =>
    {
      'user_id': userId,
      'username': name,
      'seat_position': seat,
      'color': color,
      'is_ready': isReady,
      'is_host': isHost,
    };

// ---------------------------------------------------------------------------
// Test Suite

void main() {
  // -------------------------------------------------------------------------
  // 1. DTO parsing & status mapping
  // -------------------------------------------------------------------------
  group('PrivateRoomDto & Whitelist Validation', () {
    test('backend whitelist mirrors config/private_room.php exactly', () {
      // Backend: config/private_room.php allowed_entry_fees: [0, 500, 1000, 5000]
      expect(kAllowedEntryFees, equals([0, 500, 1000, 5000]));
      // Backend: config/private_room.php allowed_max_players: [2, 4]
      expect(kAllowedMaxPlayers, equals([2, 4]));
      // Backend: config/private_room.php allowed_turn_seconds: [10, 15, 30]
      expect(kAllowedTurnSeconds, equals([10, 15, 30]));
    });

    test('status mapping: finished maps to completed, cancelled to cancelled', () {
      final finishedDto = PrivateRoomDto.fromServerSnapshot({
        'id': 1,
        'room_code': 'FIN123',
        'status': 'finished',
        'max_players': 2,
        'entry_fee': 0,
        'turn_seconds': 15,
        'state_version': 1,
        'players': <dynamic>[],
      });
      expect(finishedDto.status, RoomStatusDto.finished);
      expect(finishedDto.isFinished, isTrue);
      expect(finishedDto.toRoomStatus(), RoomStatus.completed);

      final cancelledDto = PrivateRoomDto.fromServerSnapshot({
        'id': 2,
        'room_code': 'CAN123',
        'status': 'cancelled',
        'max_players': 2,
        'entry_fee': 0,
        'turn_seconds': 15,
        'state_version': 1,
        'players': <dynamic>[],
      });
      expect(cancelledDto.status, RoomStatusDto.cancelled);
      expect(cancelledDto.isCancelled, isTrue);
      expect(cancelledDto.toRoomStatus(), RoomStatus.cancelled);

      final session = finishedDto.toRoomSession(currentUserId: 1);
      expect(session.status, RoomStatus.completed);
      expect(session.type, RoomType.private);
    });

    test('parses all fields correctly', () {
      final json = _makeRoomJson(
        id: 7,
        roomCode: 'X9K2P4',
        status: 'waiting',
        maxPlayers: 2,
        entryFee: 1000,
        turnSeconds: 30,
        stateVersion: 1,
        players: [
          _makePlayer(userId: 1, isHost: true),
          _makePlayer(userId: 2, isReady: true),
        ],
      );

      final dto = PrivateRoomDto.fromApiResponse(json);

      expect(dto.id, 7);
      expect(dto.roomCode, 'X9K2P4');
      expect(dto.status, RoomStatusDto.waiting);
      expect(dto.maxPlayers, 2);
      expect(dto.entryFee, 1000);
      expect(dto.turnSeconds, 30);
      expect(dto.stateVersion, 1);
      expect(dto.participants.length, 2);
      expect(dto.participants[0].userId, 1);
      expect(dto.participants[0].isHost, isTrue);
      expect(dto.participants[1].userId, 2);
      expect(dto.participants[1].isReady, isTrue);
    });

    test('canStart is true when room full and all guests ready', () {
      final json = _makeRoomJson(
        maxPlayers: 2,
        players: [
          _makePlayer(userId: 1, isHost: true, isReady: false),
          _makePlayer(userId: 2, isHost: false, isReady: true),
        ],
      );
      final dto = PrivateRoomDto.fromApiResponse(json);
      expect(dto.isFull, isTrue);
      expect(dto.allGuestsReady, isTrue);
      expect(dto.canStart, isTrue);
    });

    test('canStart is false when guest is not ready', () {
      final json = _makeRoomJson(
        maxPlayers: 2,
        players: [
          _makePlayer(userId: 1, isHost: true),
          _makePlayer(userId: 2, isHost: false, isReady: false),
        ],
      );
      final dto = PrivateRoomDto.fromApiResponse(json);
      expect(dto.canStart, isFalse);
    });

    test('canStart is false when room is not full', () {
      final json = _makeRoomJson(
        maxPlayers: 4,
        players: [
          _makePlayer(userId: 1, isHost: true),
          _makePlayer(userId: 2, isHost: false, isReady: true),
        ],
      );
      final dto = PrivateRoomDto.fromApiResponse(json);
      expect(dto.isFull, isFalse);
      expect(dto.canStart, isFalse);
    });

    test('missing fields fall back to defaults', () {
      final dto = PrivateRoomDto.fromApiResponse(
          {'data': {'id': 7, 'room_code': 'XY1234'}});
      expect(dto.id, 7);
      expect(dto.status, RoomStatusDto.unknown);
      expect(dto.entryFee, 0);
      expect(dto.maxPlayers, 2);
      expect(dto.turnSeconds, 15);
      expect(dto.participants, isEmpty);
    });

    test('fromServerSnapshot parses without data wrapper', () {
      final json = {
        'id': 10,
        'room_code': 'SNAP01',
        'status': 'playing',
        'max_players': 4,
        'entry_fee': 1000,
        'turn_seconds': 30,
        'state_version': 5,
        'players': <dynamic>[],
      };
      final dto = PrivateRoomDto.fromServerSnapshot(json);
      expect(dto.id, 10);
      expect(dto.status, RoomStatusDto.playing);
      expect(dto.isPlaying, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // 2. RoomFailure sealed types
  // -------------------------------------------------------------------------
  group('RoomFailure', () {
    test('message is accessible on all subtypes', () {
      final failures = <RoomFailure>[
        const RoomUnauthenticated(),
        const RoomForbidden(),
        const RoomNotFound(),
        const RoomConflict(),
        const RoomValidation('bad input'),
        const RoomInsufficientBalance('not enough coins'),
        const RoomAlreadyActive(existingRoomId: 7),
        const RoomFull(),
        const RoomAlreadyStarted(),
        const RoomNetworkFailure(),
        const RoomUnknown(),
      ];
      for (final f in failures) {
        expect(f.message, isNotEmpty,
            reason: '${f.runtimeType} message must not be empty');
      }
    });

    test('RoomAlreadyActive carries existingRoomId', () {
      const f = RoomAlreadyActive(existingRoomId: 42);
      expect(f.existingRoomId, 42);
    });

    test('pattern match is exhaustive', () {
      RoomFailure f = const RoomNotFound('missing');
      String result = switch (f) {
        RoomUnauthenticated() => 'unauth',
        RoomForbidden() => 'forbidden',
        RoomNotFound() => 'not_found',
        RoomConflict() => 'conflict',
        RoomValidation() => 'validation',
        RoomInsufficientBalance() => 'balance',
        RoomAlreadyActive() => 'already_active',
        RoomFull() => 'full',
        RoomAlreadyStarted() => 'started',
        RoomNetworkFailure() => 'network',
        RoomUnknown() => 'unknown',
      };
      expect(result, 'not_found');
    });
  });

  // -------------------------------------------------------------------------
  // 3. LudoBoardArgs strongly-typed model
  // -------------------------------------------------------------------------
  group('LudoBoardArgs', () {
    test('serializes to and from Map accurately', () {
      const original = LudoBoardArgs(
        players: 2,
        bet: 1000,
        roomId: 55,
        gameId: 101,
        roomMode: RoomMode.private,
        roomCode: 'PRIV01',
        turnSeconds: 30,
        isOnline: true,
      );

      final map = original.toMap();
      final restored = LudoBoardArgs.fromMap(map);

      expect(restored.players, 2);
      expect(restored.bet, 1000);
      expect(restored.roomId, 55);
      expect(restored.gameId, 101);
      expect(restored.roomMode, RoomMode.private);
      expect(restored.roomCode, 'PRIV01');
      expect(restored.turnSeconds, 30);
      expect(restored.isOnline, isTrue);
    });

    test('fromMap applies defaults for missing fields', () {
      final args = LudoBoardArgs.fromMap(const {});
      expect(args.players, 4);
      expect(args.bet, 500);
      expect(args.roomMode, RoomMode.quickMatch);
      expect(args.turnSeconds, 15);
      expect(args.roomId, isNull);
      expect(args.gameId, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // 4. PrivateRoomController state transitions & rules
  // -------------------------------------------------------------------------
  group('PrivateRoomController state', () {
    late _FakeApiRoomRepository fakeRepo;
    late _FakeWebSocketService fakeWs;

    setUp(() {
      fakeRepo = _FakeApiRoomRepository();
      fakeWs = _FakeWebSocketService();
    });

    PrivateRoomController makeController() =>
        PrivateRoomController(repository: fakeRepo, wsService: fakeWs);

    test('initial state is idle', () {
      final ctrl = makeController();
      expect(ctrl.state.isIdle, isTrue);
      expect(ctrl.state.room, isNull);
      expect(ctrl.state.failure, isNull);
    });

    test('create success sets room', () async {
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.room, isNotNull);
      expect(ctrl.state.room!.roomCode, 'ABCDE1');
      expect(ctrl.state.isLoading, isFalse);
      expect(ctrl.state.failure, isNull);
    });

    test('create failure sets RoomFailure', () async {
      fakeRepo.shouldFail = true;
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.room, isNull);
      expect(ctrl.state.failure, isA<RoomNetworkFailure>());
    });

    test('join success sets room', () async {
      final ctrl = makeController();
      await ctrl.join('ABCDE1', myUserId: 1);
      expect(ctrl.state.room, isNotNull);
    });

    test('join with ALREADY_IN_ROOM restores existing room', () async {
      fakeRepo.alreadyInRoomId = 99;
      final ctrl = makeController();
      await ctrl.join('ABCDE1', myUserId: 1);
      expect(ctrl.state.room, isNotNull);
      expect(ctrl.state.room!.id, 99);
    });

    test('leave clears room state', () async {
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.room, isNotNull);
      await ctrl.leave();
      expect(ctrl.state.room, isNull);
    });

    test('clearFailure removes error', () async {
      fakeRepo.shouldFail = true;
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.failure, isNotNull);
      ctrl.clearFailure();
      expect(ctrl.state.failure, isNull);
    });

    test('restoreActiveRoom waiting sets goToLobby navEvent', () async {
      fakeRepo.activeRoomToReturn = _FakeApiRoomRepository._fakeRoom(
        10,
        'WAIT01',
        status: 'waiting',
      );
      final ctrl = makeController();
      await ctrl.restoreActiveRoom(myUserId: 1);

      expect(ctrl.state.hasRoom, isTrue);
      expect(ctrl.state.navEvent, PrivateRoomNavEvent.goToLobby);
    });

    test('restoreActiveRoom playing sets goToGame navEvent', () async {
      fakeRepo.activeRoomToReturn = _FakeApiRoomRepository._fakeRoom(
        11,
        'PLAY01',
        status: 'playing',
      );
      final ctrl = makeController();
      await ctrl.restoreActiveRoom(myUserId: 1);

      expect(ctrl.state.hasRoom, isTrue);
      expect(ctrl.state.navEvent, PrivateRoomNavEvent.goToGame);
    });

    test('restoreActiveRoom null (404) leaves state idle on hub', () async {
      fakeRepo.activeRoomToReturn = null;
      final ctrl = makeController();
      await ctrl.restoreActiveRoom(myUserId: 1);

      expect(ctrl.state.hasRoom, isFalse);
      expect(ctrl.state.navEvent, isNull);
      expect(ctrl.state.isLoading, isFalse);
    });

    test('stale version event (version <= current) is ignored', () async {
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.room!.stateVersion, 1);

      // Version 1 event (stale, same as current version)
      fakeWs.emit(WebSocketEvent(
        channel: 'private-room-lobby.1',
        event: 'private_room.updated',
        payload: {
          'reason': 'ready',
          'version': 1,
          'snapshot': {'state_version': 1},
        },
      ));
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepo.showCalls, 0);
    });

    test('version gap triggers full GET resync from API', () async {
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);
      expect(ctrl.state.room!.stateVersion, 1);

      // Version 5 event (gap: missed v2, v3, v4)
      fakeWs.emit(WebSocketEvent(
        channel: 'private-room-lobby.1',
        event: 'private_room.updated',
        payload: {
          'reason': 'ready',
          'version': 5,
          'snapshot': {'state_version': 5},
        },
      ));
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepo.showCalls, 1);
    });

    test('startMatch and started event emit goToGame exactly once', () async {
      final ctrl = makeController();
      await ctrl.create(maxPlayers: 2, entryFee: 0, myUserId: 1);

      // Start match via API
      await ctrl.startMatch();
      expect(ctrl.state.navEvent, isNull); // startMatch waits for WS event

      // WS event arrives
      fakeWs.emit(WebSocketEvent(
        channel: 'private-room-lobby.1',
        event: 'private_room.updated',
        payload: {
          'reason': 'started',
          'version': 2,
          'snapshot': {'status': 'playing', 'state_version': 2, 'game_id': 88},
        },
      ));
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.state.navEvent, PrivateRoomNavEvent.goToGame);

      // Clear event
      ctrl.consumeNavEvent();
      expect(ctrl.state.navEvent, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // 5. PrivateRoomJoinScreen — local validation only
  // -------------------------------------------------------------------------
  group('PrivateRoomJoinScreen UI', () {
    ProviderContainer makeContainer() {
      return ProviderContainer(overrides: [
        privateRoomProvider.overrideWith(
            (ref) => PrivateRoomController(
                  repository: _FakeApiRoomRepository(),
                  wsService: _FakeWebSocketService(),
                )),
      ]);
    }

    Widget buildSubject(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PrivateRoomJoinScreen(),
        ),
      );
    }

    testWidgets('shows code input, paste button, and join button',
        (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.byKey(const Key('input_room_code')), findsOneWidget);
      expect(find.byKey(const Key('btn_paste_code')), findsOneWidget);
      expect(find.byKey(const Key('btn_join_room')), findsOneWidget);
    });

    testWidgets('code input uppercases input and limits to 6 chars',
        (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      await tester.enterText(find.byKey(const Key('input_room_code')), 'abc12345');
      await tester.pump();

      expect(find.text('ABC123'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // 6. PrivateRoomCreateScreen — strict whitelist enforcement
  // -------------------------------------------------------------------------
  group('PrivateRoomCreateScreen UI', () {
    ProviderContainer makeContainer() {
      final fakeAuth = _FakeAuthNotifier();
      return ProviderContainer(overrides: [
        authProvider.overrideWith((ref) => fakeAuth),
        privateRoomProvider.overrideWith(
            (ref) => PrivateRoomController(
                  repository: _FakeApiRoomRepository(),
                  wsService: _FakeWebSocketService(),
                )),
      ]);
    }

    Widget buildSubject(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PrivateRoomCreateScreen(),
        ),
      );
    }

    testWidgets('shows create button', (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.byKey(const Key('btn_create_room')), findsOneWidget);
    });

    testWidgets('strictly offers only 2 and 4 players (no 3 players)',
        (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.text('2 Players'), findsOneWidget);
      expect(find.text('4 Players'), findsOneWidget);
      expect(find.text('3 Players'), findsNothing);
    });

    testWidgets(
        'strictly offers only allowed entry fees [0, 500, 1000, 5000] matching backend whitelist',
        (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.text('Free'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);

      // Verify forbidden options are never offered
      expect(find.text('2500'), findsNothing);
      expect(find.text('10000'), findsNothing);
      expect(find.text('2.5K'), findsNothing);
      expect(find.text('10K'), findsNothing);
    });
  });
}

// ---------------------------------------------------------------------------
// Fakes

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier()
      : super(AuthState(
          user: UserModel(
            id: 1,
            username: 'testplayer',
            email: 'test@example.com',
            coins: 50000,
            diamonds: 100,
            level: 5,
          ),
        ));

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApiRoomRepository implements ApiRoomRepository {
  bool shouldFail = false;
  int? alreadyInRoomId;
  int showCalls = 0;
  PrivateRoomDto? activeRoomToReturn;

  @override
  Future<PrivateRoomDto> create({
    required int maxPlayers,
    required int entryFee,
    int? turnSeconds,
    String? title,
  }) async {
    if (shouldFail) throw const RoomNetworkFailure();
    return _fakeRoom(1, 'ABCDE1', maxPlayers: maxPlayers, entryFee: entryFee);
  }

  @override
  Future<PrivateRoomDto> join(String roomCode) async {
    if (shouldFail) throw const RoomNetworkFailure();
    if (alreadyInRoomId != null) {
      throw RoomAlreadyActive(existingRoomId: alreadyInRoomId);
    }
    return _fakeRoom(2, roomCode);
  }

  @override
  Future<PrivateRoomDto> show(int roomId) async {
    showCalls++;
    if (shouldFail) throw const RoomNotFound();
    return _fakeRoom(roomId, 'ABCDE1');
  }

  @override
  Future<PrivateRoomDto?> getActiveRoom() async {
    if (shouldFail) throw const RoomNetworkFailure();
    return activeRoomToReturn;
  }

  @override
  Future<PrivateRoomDto> toggleReady(int roomId, {required bool isReady}) async {
    return _fakeRoom(roomId, 'ABCDE1');
  }

  @override
  Future<PrivateRoomDto> start(int roomId) async {
    return _fakeRoom(roomId, 'ABCDE1', status: 'playing');
  }

  @override
  Future<void> leave(int roomId) async {}

  static PrivateRoomDto _fakeRoom(
    int id,
    String code, {
    String status = 'waiting',
    int maxPlayers = 2,
    int entryFee = 0,
  }) {
    return PrivateRoomDto.fromServerSnapshot({
      'id': id,
      'room_code': code,
      'status': status,
      'max_players': maxPlayers,
      'entry_fee': entryFee,
      'turn_seconds': 15,
      'state_version': 1,
      'players': <dynamic>[],
    });
  }
}

class _FakeWebSocketService implements WebSocketService {
  final _controller = StreamController<WebSocketEvent>.broadcast();

  void emit(WebSocketEvent event) => _controller.add(event);

  @override
  bool get isConnected => false;
  @override
  String? get socketId => null;
  @override
  Stream<WebSocketEvent> get eventStream => _controller.stream;
  @override
  Future<void> subscribeChannel(String channelName) async {}
  @override
  void unsubscribeChannel(String channelName) {}
  @override
  void sendRawEvent(String eventName, Map<String, dynamic> data) {}
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
