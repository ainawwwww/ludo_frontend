// lib/features/rooms/providers/team_room_provider.dart
//
// State machine for 2v2 Team Mode party lobbies & matchmaking.
// Supports 3 pathways: SINGLE (solo), CREATE (party host), JOIN (party guest).

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_team_room_repository.dart';

enum TeamRoomNavEvent {
  goToMatchmaking, // navigate to TeamVsScreen (searching opponents)
  goToGame,        // TeamMatchFound -> navigate to LudoBoardScreen
  goToLobby,       // party lobby created / joined
  goHome,          // left / disbanded -> navigate to home
}

class TeamRoomState {
  const TeamRoomState({
    this.room,
    this.isLoading = false,
    this.failure,
    this.navEvent,
    this.myUserId,
    this.matchData,
    this.isSingle = false,
    this.queueStatus = 'idle',
  });

  final PrivateRoomDto? room;
  final bool isLoading;
  final RoomFailure? failure;
  final TeamRoomNavEvent? navEvent;
  final int? myUserId;
  final Map<String, dynamic>? matchData;
  final bool isSingle;
  final String queueStatus;

  bool get hasRoom => room != null;

  TeamRoomState copyWith({
    PrivateRoomDto? room,
    bool clearRoom = false,
    bool? isLoading,
    RoomFailure? failure,
    bool clearFailure = false,
    TeamRoomNavEvent? navEvent,
    bool clearNavEvent = false,
    int? myUserId,
    Map<String, dynamic>? matchData,
    bool clearMatchData = false,
    bool? isSingle,
    String? queueStatus,
  }) {
    return TeamRoomState(
      room: clearRoom ? null : (room ?? this.room),
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      navEvent: clearNavEvent ? null : (navEvent ?? this.navEvent),
      myUserId: myUserId ?? this.myUserId,
      matchData: clearMatchData ? null : (matchData ?? this.matchData),
      isSingle: isSingle ?? this.isSingle,
      queueStatus: queueStatus ?? this.queueStatus,
    );
  }
}

final teamRoomProvider =
    StateNotifierProvider<TeamRoomController, TeamRoomState>((ref) {
  return TeamRoomController(
    repository: ref.watch(apiTeamRoomRepositoryProvider),
    wsService: ref.watch(webSocketServiceProvider),
  );
});

class TeamRoomController extends StateNotifier<TeamRoomState> {
  TeamRoomController({
    required ApiTeamRoomRepository repository,
    required WebSocketService wsService,
  })  : _repo = repository,
        _ws = wsService,
        super(const TeamRoomState());

  final ApiTeamRoomRepository _repo;
  final WebSocketService _ws;
  StreamSubscription<WebSocketEvent>? _wsSub;
  StreamSubscription<WebSocketEvent>? _userWsSub;
  int? _currentRoomId;

  /// CREATE party lobby (CREATE pathway)
  Future<void> create({
    required int entryFee,
    int? turnSeconds,
    required int myUserId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      myUserId: myUserId,
      isSingle: false,
    );
    try {
      final room = await _repo.create(entryFee: entryFee, turnSeconds: turnSeconds);
      state = state.copyWith(
        room: room,
        isLoading: false,
        navEvent: TeamRoomNavEvent.goToLobby,
      );
      _subscribeToLobby(room.id);
      _subscribeToUserChannel(myUserId);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// JOIN party lobby (JOIN pathway)
  Future<void> join(String code, {required int myUserId}) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      myUserId: myUserId,
      isSingle: false,
    );
    try {
      final room = await _repo.join(code);
      state = state.copyWith(
        room: room,
        isLoading: false,
        navEvent: TeamRoomNavEvent.goToLobby,
      );
      _subscribeToLobby(room.id);
      _subscribeToUserChannel(myUserId);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// JOIN solo matchmaking (SINGLE pathway)
  Future<void> joinSolo({
    required int entryFee,
    required int myUserId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      myUserId: myUserId,
      isSingle: true,
      queueStatus: 'queued',
    );
    _subscribeToUserChannel(myUserId);

    try {
      final res = await _repo.joinSolo(entryFee: entryFee);
      final data = res['data'] is Map<String, dynamic>
          ? res['data'] as Map<String, dynamic>
          : res;

      final status = data['status']?.toString() ?? 'queued';
      if (status == 'matched' || data['game_id'] != null) {
        state = state.copyWith(
          isLoading: false,
          queueStatus: 'matched',
          matchData: data,
          navEvent: TeamRoomNavEvent.goToGame,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          queueStatus: 'queued',
          navEvent: TeamRoomNavEvent.goToMatchmaking,
        );
      }
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false, queueStatus: 'idle');
    }
  }

  /// TOGGLE guest ready state in party lobby
  Future<void> setReady({required bool isReady}) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final updated = await _repo.toggleReady(isReady: isReady);
      state = state.copyWith(room: updated, isLoading: false);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// HOST initiates 2v2 matchmaking for ready party lobby
  Future<void> startMatchmaking() async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      queueStatus: 'queued',
    );
    try {
      final res = await _repo.readyForMatch();
      final data = res['data'] is Map<String, dynamic>
          ? res['data'] as Map<String, dynamic>
          : res;

      final status = data['status']?.toString() ?? 'queued';
      if (status == 'matched' || data['game_id'] != null) {
        state = state.copyWith(
          isLoading: false,
          queueStatus: 'matched',
          matchData: data,
          navEvent: TeamRoomNavEvent.goToGame,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          queueStatus: 'queued',
          navEvent: TeamRoomNavEvent.goToMatchmaking,
        );
      }
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false, queueStatus: 'idle');
    }
  }

  /// LEAVE party lobby or queue
  Future<void> leave() async {
    _unsubscribeFromLobby();
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      if (!state.isSingle) {
        await _repo.leave();
      }
    } on RoomFailure catch (f) {
      if (kDebugMode) print('⚠️ [TeamRoom] leave() failed: $f');
    } finally {
      state = const TeamRoomState();
    }
  }

  /// Consume nav event
  void consumeNavEvent() {
    state = state.copyWith(clearNavEvent: true);
  }

  /// Clear failure
  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  void _subscribeToLobby(int roomId) {
    if (_currentRoomId == roomId) return;
    _unsubscribeFromLobby();
    _currentRoomId = roomId;

    final channelName = 'room-lobby.$roomId';
    _ws.subscribeChannel(channelName);

    _wsSub = _ws.eventStream.listen((event) {
      if (event.channel != channelName &&
          event.channel != 'private-$channelName') return;
      final ev = event.event;
      if (ev == 'team_partner.joined' ||
          ev == '.team_partner.joined' ||
          ev == 'App\\Events\\TeamPartnerJoined') {
        _handlePartnerJoinedEvent(event.payload);
      } else if (ev == 'private_room.updated' ||
          ev == '.private_room.updated' ||
          ev == 'App\\Events\\PrivateRoomUpdated') {
        _handleLobbyUpdatedEvent(event.payload);
      }
    });
  }

  void _subscribeToUserChannel(int userId) {
    _ws.subscribeToUserChannel(userId);
    _userWsSub?.cancel();
    _userWsSub = _ws.eventStream.listen((event) {
      final ev = event.event.toLowerCase();
      if (ev.contains('team_match.found') ||
          ev.contains('teammatchfound') ||
          ev.contains('match.found')) {
        _handleMatchFoundEvent(event.payload);
      }
    });
  }

  void _unsubscribeFromLobby() {
    _wsSub?.cancel();
    _wsSub = null;
    _userWsSub?.cancel();
    _userWsSub = null;
    if (_currentRoomId != null) {
      _ws.unsubscribeChannel('room-lobby.$_currentRoomId');
      _currentRoomId = null;
    }
  }

  void _handlePartnerJoinedEvent(Map<String, dynamic> payload) {
    final snapshotRaw = payload['snapshot'] as Map<String, dynamic>?;
    if (snapshotRaw != null) {
      final updated = PrivateRoomDto.fromServerSnapshot(
        snapshotRaw..putIfAbsent('id', () => state.room?.id ?? 0),
      );
      state = state.copyWith(room: updated);
    }
  }

  void _handleLobbyUpdatedEvent(Map<String, dynamic> payload) {
    final reason = payload['reason'] as String?;
    final snapshotRaw = payload['snapshot'] as Map<String, dynamic>?;

    if (reason == 'cancelled' || reason == 'expired') {
      _unsubscribeFromLobby();
      state = state.copyWith(
        clearRoom: true,
        isLoading: false,
        navEvent: TeamRoomNavEvent.goHome,
      );
    } else if (snapshotRaw != null) {
      final updated = PrivateRoomDto.fromServerSnapshot(
        snapshotRaw..putIfAbsent('id', () => state.room?.id ?? 0),
      );
      state = state.copyWith(room: updated);
    }
  }

  void _handleMatchFoundEvent(Map<String, dynamic> payload) {
    if (kDebugMode) {
      print('🎮 [TeamRoom] TeamMatchFound event received: $payload');
    }
    state = state.copyWith(
      queueStatus: 'matched',
      matchData: payload,
      navEvent: TeamRoomNavEvent.goToGame,
    );
  }

  @override
  void dispose() {
    _unsubscribeFromLobby();
    super.dispose();
  }
}
