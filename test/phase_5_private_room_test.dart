// test/phase_5_private_room_test.dart
//
// Phase 5 tests:
// 1. PrivateRoomDto  — JSON parsing (all fields, missing fields, canStart logic)
// 2. RoomFailure     — sealed type coverage
// 3. PrivateRoomController — state transitions (mock repository)
// 4. PrivateRoomJoinScreen — UI validation (local-only, no network)
// 5. PrivateRoomCreateScreen — settings selection + create button state
//
// All tests are OFFLINE (no network, no Pusher).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_join_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/private_room_create_screen.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';

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
  String username = 'Alice',
  int seat = 1,
  String color = 'red',
  bool isReady = false,
  bool isHost = false,
}) =>
    {
      'user_id': userId,
      'username': username,
      'seat_position': seat,
      'color': color,
      'is_ready': isReady,
      'is_host': isHost,
    };

// ---------------------------------------------------------------------------
// 1. DTO Parsing

void main() {
  group('PrivateRoomDto JSON parsing', () {
    test('parses all fields correctly', () {
      final host = _makePlayer(
          userId: 1, username: 'Alice', seat: 1, isHost: true, isReady: true);
      final guest = _makePlayer(
          userId: 2, username: 'Bob', seat: 2, isHost: false, isReady: true);
      final json = _makeRoomJson(players: [host, guest], gameId: 99);

      final dto = PrivateRoomDto.fromApiResponse(json);

      expect(dto.id, 42);
      expect(dto.roomCode, 'ABCDE1');
      expect(dto.status, RoomStatusDto.waiting);
      expect(dto.maxPlayers, 2);
      expect(dto.entryFee, 500);
      expect(dto.turnSeconds, 15);
      expect(dto.stateVersion, 3);
      expect(dto.gameId, 99);
      expect(dto.participants.length, 2);
    });

    test('canStart is true when room full and all guests ready', () {
      final host = _makePlayer(
          userId: 1, isHost: true, isReady: true, seat: 1, color: 'red');
      final guest = _makePlayer(
          userId: 2, isHost: false, isReady: true, seat: 2, color: 'green');
      final dto = PrivateRoomDto.fromApiResponse(
          _makeRoomJson(maxPlayers: 2, players: [host, guest]));
      expect(dto.canStart, isTrue);
    });

    test('canStart is false when guest is not ready', () {
      final host = _makePlayer(
          userId: 1, isHost: true, isReady: true, seat: 1, color: 'red');
      final guest = _makePlayer(
          userId: 2, isHost: false, isReady: false, seat: 2, color: 'green');
      final dto = PrivateRoomDto.fromApiResponse(
          _makeRoomJson(maxPlayers: 2, players: [host, guest]));
      expect(dto.canStart, isFalse);
    });

    test('canStart is false when room is not full', () {
      final host = _makePlayer(
          userId: 1, isHost: true, isReady: true, seat: 1, color: 'red');
      final dto = PrivateRoomDto.fromApiResponse(
          _makeRoomJson(maxPlayers: 2, players: [host]));
      expect(dto.canStart, isFalse);
    });

    test('missing fields fall back to defaults', () {
      final dto = PrivateRoomDto.fromApiResponse({'data': {'id': 7, 'room_code': 'XY1234'}});
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

    test('RoomParticipantDto parses is_ready as int 1', () {
      final p = RoomParticipantDto.fromJson({
        'user_id': 5,
        'username': 'Charlie',
        'seat_position': 2,
        'color': 'blue',
        'is_ready': 1, // integer form
        'is_host': 0,
      });
      expect(p.isReady, isTrue);
      expect(p.isHost, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // 2. RoomFailure sealed types

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
  // 3. PrivateRoomController state transitions (mock repository)

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
      await ctrl.create(
          maxPlayers: 2, entryFee: 0, myUserId: 1);
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
      // After restoration, room id comes from show(99)
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
  });

  // -------------------------------------------------------------------------
  // 4. PrivateRoomJoinScreen — local validation only

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

    testWidgets('shows code input and join button', (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.byKey(const Key('input_room_code')), findsOneWidget);
      expect(find.byKey(const Key('btn_join_room')), findsOneWidget);
    });

    testWidgets('code input uppercases input and limits to 6 chars',
        (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      final input = find.byKey(const Key('input_room_code'));
      await tester.enterText(input, 'abcde1xyz');
      await tester.pump();

      // Formatter should uppercase and limit
      final tf = tester.widget<TextField>(input);
      final text = tf.controller?.text ?? '';
      expect(text.length, lessThanOrEqualTo(6));
      expect(text, equals(text.toUpperCase()));
    });
  });

  // -------------------------------------------------------------------------
  // 5. PrivateRoomCreateScreen — settings selection

  group('PrivateRoomCreateScreen UI', () {
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

    testWidgets('shows player and entry fee options', (tester) async {
      final container = makeContainer();
      await tester.pumpWidget(buildSubject(container));
      await tester.pump();

      expect(find.text('2 Players'), findsOneWidget);
      expect(find.text('4 Players'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Fakes

class _FakeApiRoomRepository implements ApiRoomRepository {
  bool shouldFail = false;
  int? alreadyInRoomId; // non-null -> join() throws RoomAlreadyActive

  @override
  Future<PrivateRoomDto> create({
    required int maxPlayers,
    required int entryFee,
    int? turnSeconds,
    String? title,
  }) async {
    if (shouldFail) throw const RoomNetworkFailure();
    return _fakeRoom(1, 'ABCDE1');
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
    if (shouldFail) throw const RoomNotFound();
    return _fakeRoom(roomId, 'ABCDE1');
  }

  @override
  Future<PrivateRoomDto?> getActiveRoom() async {
    if (shouldFail) throw const RoomNetworkFailure();
    return null;
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

  static PrivateRoomDto _fakeRoom(int id, String code,
      {String status = 'waiting'}) {
    return PrivateRoomDto.fromServerSnapshot({
      'id': id,
      'room_code': code,
      'status': status,
      'max_players': 2,
      'entry_fee': 0,
      'turn_seconds': 15,
      'state_version': 1,
      'players': <dynamic>[],
    });
  }

  // Satisfy the interface — delegate private members via noSuchMethod.
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWebSocketService implements WebSocketService {
  @override
  bool get isConnected => false;
  @override
  String? get socketId => null;
  @override
  Stream<WebSocketEvent> get eventStream => const Stream.empty();
  @override
  Future<void> subscribeChannel(String channelName) async {}
  @override
  void unsubscribeChannel(String channelName) {}
  @override
  void sendRawEvent(String eventName, Map<String, dynamic> data) {}
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
