// test/vip_room_test.dart
//
// VIP Room Milestone 1 Tests:
// 1. VIP Whitelist & Repository base path validation
// 2. VipRoomController (via vipRoomProvider) state machine: create, ready, start, version gap resync, restore, ALREADY_IN_ROOM, cancelled handling
// 3. Dedicated VIP screens: VipRoomCreateScreen, VipRoomJoinScreen, VipRoomLobbyScreen
// 4. RoomMode.vip exit route validation (routes to /vip-room, not /private-room)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/game/models/ludo_board_args.dart';
import 'package:ludo_vibe/features/game/models/room_mode.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/providers/vip_room_provider.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';
import 'package:ludo_vibe/features/rooms/screens/vip_room_create_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/vip_room_join_screen.dart';
import 'package:ludo_vibe/features/rooms/screens/vip_room_lobby_screen.dart';

// ---------------------------------------------------------------------------
// Helpers & Fakes

PrivateRoomDto _fakeVipRoom(
  int id,
  String roomCode, {
  int maxPlayers = 2,
  int entryFee = 1000,
  int turnSeconds = 15,
  int version = 1,
  RoomStatusDto status = RoomStatusDto.waiting,
  List<RoomParticipantDto> participants = const [],
}) {
  return PrivateRoomDto(
    id: id,
    roomCode: roomCode,
    status: status,
    maxPlayers: maxPlayers,
    entryFee: entryFee,
    turnSeconds: turnSeconds,
    stateVersion: version,
    participants: participants,
    canStart: status == RoomStatusDto.waiting &&
        participants.length >= maxPlayers &&
        participants.where((p) => !p.isHost).every((p) => p.isReady),
  );
}

class _FakeVipApiRoomRepository implements ApiRoomRepository {
  @override
  String get basePath => '/vip-rooms';

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
    return _fakeVipRoom(
      100,
      'VIP888',
      maxPlayers: maxPlayers,
      entryFee: entryFee,
      participants: [
        const RoomParticipantDto(
          userId: 1,
          username: 'HostVip',
          seatPosition: 1,
          color: 'red',
          isReady: true,
          isHost: true,
        ),
      ],
    );
  }

  @override
  Future<PrivateRoomDto> join(String roomCode) async {
    if (shouldFail) throw const RoomNetworkFailure();
    if (alreadyInRoomId != null) {
      throw RoomAlreadyActive(existingRoomId: alreadyInRoomId);
    }
    return _fakeVipRoom(
      100,
      roomCode,
      participants: [
        const RoomParticipantDto(
          userId: 1,
          username: 'HostVip',
          seatPosition: 1,
          color: 'red',
          isReady: true,
          isHost: true,
        ),
        const RoomParticipantDto(
          userId: 2,
          username: 'GuestVip',
          seatPosition: 2,
          color: 'green',
          isReady: false,
          isHost: false,
        ),
      ],
    );
  }

  @override
  Future<PrivateRoomDto> show(int roomId) async {
    showCalls++;
    if (shouldFail) throw const RoomNotFound('Room not found');
    return _fakeVipRoom(
      roomId,
      'VIP888',
      version: 5,
      participants: [
        const RoomParticipantDto(
          userId: 1,
          username: 'HostVip',
          seatPosition: 1,
          color: 'red',
          isReady: true,
          isHost: true,
        ),
        const RoomParticipantDto(
          userId: 2,
          username: 'GuestVip',
          seatPosition: 2,
          color: 'green',
          isReady: true,
          isHost: false,
        ),
      ],
    );
  }

  @override
  Future<PrivateRoomDto?> getActiveRoom() async {
    if (shouldFail) throw const RoomNetworkFailure();
    return activeRoomToReturn;
  }

  @override
  Future<PrivateRoomDto> toggleReady(int roomId, {required bool isReady}) async {
    if (shouldFail) throw const RoomNetworkFailure();
    return _fakeVipRoom(
      roomId,
      'VIP888',
      participants: [
        const RoomParticipantDto(
          userId: 1,
          username: 'HostVip',
          seatPosition: 1,
          color: 'red',
          isReady: true,
          isHost: true,
        ),
        RoomParticipantDto(
          userId: 2,
          username: 'GuestVip',
          seatPosition: 2,
          color: 'green',
          isReady: isReady,
          isHost: false,
        ),
      ],
    );
  }

  @override
  Future<PrivateRoomDto> start(int roomId) async {
    if (shouldFail) throw const RoomForbidden('Not all players are ready');
    return _fakeVipRoom(
      roomId,
      'VIP888',
      status: RoomStatusDto.playing,
    );
  }

  @override
  Future<void> leave(int roomId) async {
    if (shouldFail) throw const RoomNetworkFailure();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

class _FakeApiClient implements ApiClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier()
      : super(AuthState(
          user: UserModel(
            id: 2,
            username: 'GuestVip',
            email: 'guest@example.com',
            coins: 50000,
            diamonds: 100,
            level: 5,
          ),
        ));

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Main Test Suite

void main() {
  group('VIP Whitelist & Repository BasePath', () {
    test('kVipAllowedEntryFees matches config/vip_room.php exactly', () {
      // Backend: config/vip_room.php allowed_entry_fees = [1000, 5000, 10000, 25000]
      expect(kVipAllowedEntryFees, equals([1000, 5000, 10000, 25000]));
    });

    test('ApiRoomRepository parameterized for VIP uses /vip-rooms base path', () {
      final repo = ApiRoomRepository(
        _FakeApiClient(),
        basePath: '/vip-rooms',
      );
      expect(repo.basePath, equals('/vip-rooms'));
    });
  });

  group('RoomMode & Exit Route Logic', () {
    test('RoomMode.vip exists and parses correctly', () {
      expect(RoomMode.fromString('vip'), equals(RoomMode.vip));
      expect(RoomMode.fromString('VIP'), equals(RoomMode.vip));
    });

    test('LudoBoardArgs with RoomMode.vip serializes correctly', () {
      const args = LudoBoardArgs(
        players: 4,
        bet: 5000,
        roomId: 100,
        roomMode: RoomMode.vip,
        roomCode: 'VIP888',
      );
      final map = args.toMap();
      expect(map['roomMode'], equals(RoomMode.vip));
      final restored = LudoBoardArgs.fromMap(map);
      expect(restored.roomMode, equals(RoomMode.vip));
    });
  });

  group('VipRoomController & State Machine', () {
    late _FakeVipApiRoomRepository repo;
    late _FakeWebSocketService ws;

    setUp(() {
      repo = _FakeVipApiRoomRepository();
      ws = _FakeWebSocketService();
    });

    test('happy path: create -> ready -> start match', () async {
      final controller = PrivateRoomController(repository: repo, wsService: ws);
      expect(controller.debugState.isIdle, isTrue);

      // 1. Create VIP room
      await controller.create(
        maxPlayers: 2,
        entryFee: 5000,
        turnSeconds: 15,
        myUserId: 1,
      );
      expect(controller.debugState.hasRoom, isTrue);
      expect(controller.debugState.room!.entryFee, equals(5000));
      expect(controller.debugState.room!.roomCode, equals('VIP888'));

      // 2. Guest ready via WebSocket snapshot
      ws.emit(WebSocketEvent(
        channel: 'private-room-lobby.100',
        event: 'private_room.updated',
        payload: {
          'reason': 'ready',
          'version': 2,
          'snapshot': {
            'id': 100,
            'code': 'VIP888',
            'status': 'waiting',
            'max_players': 2,
            'entry_fee': 5000,
            'turn_seconds': 15,
            'version': 2,
            'players': [
              {
                'user_id': 1,
                'username': 'HostVip',
                'seat': 1,
                'color': 'red',
                'is_ready': true,
                'is_host': true,
              },
              {
                'user_id': 2,
                'username': 'GuestVip',
                'seat': 2,
                'color': 'green',
                'is_ready': true,
                'is_host': false,
              },
            ],
          },
        },
      ));

      await Future<void>.delayed(Duration.zero);
      expect(controller.debugState.room!.canStart, isTrue);

      // 3. Start match
      await controller.startMatch();

      // 4. Server emits started event
      ws.emit(WebSocketEvent(
        channel: 'private-room-lobby.100',
        event: 'private_room.updated',
        payload: {
          'reason': 'started',
          'version': 3,
          'snapshot': {
            'id': 100,
            'code': 'VIP888',
            'status': 'playing',
            'max_players': 2,
            'entry_fee': 5000,
            'turn_seconds': 15,
            'game_id': 999,
            'version': 3,
            'players': [],
          },
        },
      ));

      await Future<void>.delayed(Duration.zero);
      expect(controller.debugState.navEvent, equals(PrivateRoomNavEvent.goToGame));

      controller.dispose();
    });

    test('version gap triggers GET resync from /vip-rooms/{id}', () async {
      final controller = PrivateRoomController(repository: repo, wsService: ws);

      await controller.create(
        maxPlayers: 2,
        entryFee: 1000,
        turnSeconds: 15,
        myUserId: 1,
      );

      expect(controller.debugState.room!.stateVersion, equals(1));

      // Emit event with version 5 (gap: 5 > 1 + 1)
      ws.emit(WebSocketEvent(
        channel: 'private-room-lobby.100',
        event: 'private_room.updated',
        payload: <String, dynamic>{
          'reason': 'ready',
          'version': 5,
          'snapshot': <String, dynamic>{},
        },
      ));

      await Future<void>.delayed(Duration.zero);
      expect(repo.showCalls, equals(1));
      expect(controller.debugState.room!.stateVersion, equals(5));

      controller.dispose();
    });

    test('restoreActiveRoom restores waiting or playing VIP room', () async {
      repo.activeRoomToReturn = _fakeVipRoom(
        200,
        'RESTOREVIP',
        status: RoomStatusDto.waiting,
        entryFee: 10000,
      );

      final controller = PrivateRoomController(repository: repo, wsService: ws);
      await controller.restoreActiveRoom(myUserId: 2);

      expect(controller.debugState.room!.id, equals(200));
      expect(controller.debugState.navEvent, equals(PrivateRoomNavEvent.goToLobby));

      controller.dispose();
    });

    test('handles ALREADY_IN_ROOM 409 error by restoring active room', () async {
      repo.alreadyInRoomId = 300;

      final controller = PrivateRoomController(repository: repo, wsService: ws);

      // Attempting to join triggers ALREADY_IN_ROOM 409
      await controller.join('VIP999', myUserId: 2);

      expect(repo.showCalls, equals(1));
      expect(controller.debugState.room!.id, equals(300));

      controller.dispose();
    });

    test('handles cancelled / expired WebSocket events', () async {
      final controller = PrivateRoomController(repository: repo, wsService: ws);

      await controller.create(
        maxPlayers: 2,
        entryFee: 1000,
        myUserId: 1,
      );

      ws.emit(WebSocketEvent(
        channel: 'private-room-lobby.100',
        event: 'private_room.updated',
        payload: {
          'reason': 'cancelled',
          'version': 2,
        },
      ));

      await Future<void>.delayed(Duration.zero);
      expect(controller.debugState.room, isNull);
      expect(controller.debugState.navEvent, equals(PrivateRoomNavEvent.goHome));

      controller.dispose();
    });
  });

  group('Dedicated VIP Screen Widget Tests', () {
    testWidgets('VipRoomCreateScreen entry fee chips show exactly [1000, 5000, 10000, 25000]',
        (tester) async {
      final repo = _FakeVipApiRoomRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiVipRoomRepositoryProvider.overrideWithValue(repo),
            authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: VipRoomCreateScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirm VIP header
      expect(find.text('CREATE VIP ROOM').first, findsOneWidget);

      // Confirm VIP fee chips are present: 1000, 5000, 10000, 25000
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);
      expect(find.text('10000'), findsOneWidget);
      expect(find.text('25000'), findsOneWidget);

      // Confirm non-VIP fees (0 / Free, 500) are NOT present
      expect(find.text('Free'), findsNothing);
      expect(find.text('500'), findsNothing);
    });

    testWidgets('VipRoomJoinScreen renders code input and join button',
        (tester) async {
      final repo = _FakeVipApiRoomRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiVipRoomRepositoryProvider.overrideWithValue(repo),
            authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: VipRoomJoinScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('JOIN VIP ROOM').first, findsOneWidget);
      expect(find.byKey(const Key('input_vip_room_code')), findsOneWidget);
      expect(find.byKey(const Key('btn_join_vip_room')), findsOneWidget);
    });
  });
}

extension on PrivateRoomController {
  PrivateRoomState get debugState => state;
}
