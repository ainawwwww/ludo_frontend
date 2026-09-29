// lib/features/rooms/providers/private_room_provider.dart
//
// State machine for private room lifecycle.
//
// Flow:
//   idle -> creating -> (roomSession active) -> joining/started/cancelled
//
// WebSocket events (private-room-lobby.{id}):
//   PrivateRoomUpdated: { reason, actor_user_id, snapshot, version }
//
// Navigation:
//   Provider emits [privateRoomNavigationProvider] events that the
//   lobby screen listens to (type-safe, no BuildContext needed in provider).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/repositories/api_room_repository.dart';
import 'dart:async';

// ---------------------------------------------------------------------------
// State

/// What the lobby screen should navigate to next (null = stay).
enum PrivateRoomNavEvent {
  goToGame,      // server sent 'started' or restored playing -> navigate to ludo board
  goToLobby,     // restored waiting room -> navigate to lobby
  goHome,        // room cancelled / left -> navigate to home
}

/// Combined lobby state.
class PrivateRoomState {
  const PrivateRoomState({
    this.room,
    this.isLoading = false,
    this.failure,
    this.navEvent,
    this.myUserId,
  });

  final PrivateRoomDto? room;
  final bool isLoading;
  final RoomFailure? failure;
  final PrivateRoomNavEvent? navEvent;
  final int? myUserId;

  bool get hasRoom => room != null;
  bool get isIdle => room == null && !isLoading;

  PrivateRoomState copyWith({
    PrivateRoomDto? room,
    bool clearRoom = false,
    bool? isLoading,
    RoomFailure? failure,
    bool clearFailure = false,
    PrivateRoomNavEvent? navEvent,
    bool clearNavEvent = false,
    int? myUserId,
  }) {
    return PrivateRoomState(
      room: clearRoom ? null : (room ?? this.room),
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      navEvent: clearNavEvent ? null : (navEvent ?? this.navEvent),
      myUserId: myUserId ?? this.myUserId,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider

final privateRoomProvider =
    StateNotifierProvider<PrivateRoomController, PrivateRoomState>((ref) {
  return PrivateRoomController(
    repository: ref.watch(apiRoomRepositoryProvider),
    wsService: ref.watch(webSocketServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Controller

class PrivateRoomController extends StateNotifier<PrivateRoomState> {
  PrivateRoomController({
    required ApiRoomRepository repository,
    required WebSocketService wsService,
  })  : _repo = repository,
        _ws = wsService,
        super(const PrivateRoomState());

  final ApiRoomRepository _repo;
  final WebSocketService _ws;
  StreamSubscription<WebSocketEvent>? _wsSub;
  int? _currentRoomId;

  // ---- PUBLIC API ---------------------------------------------------------

  /// Called once on startup or when opening Private Room Hub to restore active room.
  Future<void> restoreActiveRoom({required int myUserId}) async {
    if (state.hasRoom) return;
    state = state.copyWith(isLoading: true, myUserId: myUserId);
    try {
      final room = await _repo.getActiveRoom();
      if (room != null) {
        if (room.status == RoomStatusDto.playing) {
          state = state.copyWith(
            room: room,
            isLoading: false,
            navEvent: PrivateRoomNavEvent.goToGame,
          );
        } else if (room.status == RoomStatusDto.waiting) {
          state = state.copyWith(
            room: room,
            isLoading: false,
            navEvent: PrivateRoomNavEvent.goToLobby,
          );
          _subscribeToLobby(room.id);
        } else {
          state = state.copyWith(room: room, isLoading: false);
        }
      } else {
        // 404 / no active room: remain idle on hub
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Restoration is best-effort; swallow errors silently.
      state = state.copyWith(isLoading: false);
    }
  }

  /// Manually resync room from API (e.g. on socket reconnect, app resume, or version gap).
  Future<void> resync({required int myUserId}) async {
    final roomId = state.room?.id;
    if (roomId == null) return;
    await _restoreRoom(roomId, myUserId);
  }

  /// Create a new private room.
  Future<void> create({
    required int maxPlayers,
    required int entryFee,
    int? turnSeconds,
    String? title,
    required int myUserId,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true, myUserId: myUserId);
    try {
      final room = await _repo.create(
        maxPlayers: maxPlayers,
        entryFee: entryFee,
        turnSeconds: turnSeconds,
        title: title,
      );
      state = state.copyWith(room: room, isLoading: false);
      _subscribeToLobby(room.id);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// Join an existing room by code.
  Future<void> join(String roomCode, {required int myUserId}) async {
    state = state.copyWith(isLoading: true, clearFailure: true, myUserId: myUserId);
    try {
      final room = await _repo.join(roomCode);
      state = state.copyWith(room: room, isLoading: false);
      _subscribeToLobby(room.id);
    } on RoomFailure catch (f) {
      // If user is already in a room, the server returns ALREADY_IN_ROOM 409
      // with the existing room id; restore it.
      if (f is RoomAlreadyActive && f.existingRoomId != null) {
        await _restoreRoom(f.existingRoomId!, myUserId);
        return;
      }
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// Toggle my ready state.
  Future<void> setReady({required bool isReady}) async {
    final roomId = state.room?.id;
    if (roomId == null) return;
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final updated = await _repo.toggleReady(roomId, isReady: isReady);
      state = state.copyWith(room: updated, isLoading: false);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// Start the match (host only).
  Future<void> startMatch() async {
    final roomId = state.room?.id;
    if (roomId == null) return;
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      await _repo.start(roomId);
      // Don't update room here; wait for the WebSocket 'started' event.
      state = state.copyWith(isLoading: false);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  /// Leave the room / cancel (host).
  Future<void> leave() async {
    final roomId = state.room?.id;
    if (roomId == null) return;
    _unsubscribeFromLobby();
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      await _repo.leave(roomId);
    } on RoomFailure catch (f) {
      if (kDebugMode) print('⚠️ [PrivateRoom] leave() failed silently: $f');
    } finally {
      _clearRoom();
    }
  }

  /// Consume (clear) the nav event after acting on it.
  void consumeNavEvent() {
    state = state.copyWith(clearNavEvent: true);
  }

  /// Clear the current error.
  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  // ---- WEBSOCKET ----------------------------------------------------------

  /// Subscribe to private-room-lobby.{roomId}.
  void _subscribeToLobby(int roomId) {
    if (_currentRoomId == roomId) return; // already subscribed
    _unsubscribeFromLobby();
    _currentRoomId = roomId;

    final channelName = 'private-room-lobby.$roomId';
    _ws.subscribeChannel(channelName);

    _wsSub = _ws.eventStream.listen((event) {
      if (event.channel != channelName &&
          event.channel != 'private-$channelName') return;
      final ev = event.event;
      if (ev != 'private_room.updated' &&
          ev != '.private_room.updated' &&
          ev != 'private-room.updated' &&
          ev != 'App\\Events\\PrivateRoomUpdated') return;
      _handleLobbyEvent(event.payload);
    });

    if (kDebugMode) print('🔌 [PrivateRoom] Subscribed to $channelName');
  }

  void _unsubscribeFromLobby() {
    _wsSub?.cancel();
    _wsSub = null;
    if (_currentRoomId != null) {
      _ws.unsubscribeChannel('private-room-lobby.$_currentRoomId');
      _currentRoomId = null;
    }
  }

  /// Handle a PrivateRoomUpdated WebSocket event.
  void _handleLobbyEvent(Map<String, dynamic> payload) {
    final reason = payload['reason'] as String?;
    final serverVersion = payload['version'] as int?;
    final snapshotRaw = payload['snapshot'] as Map<String, dynamic>?;

    if (kDebugMode) {
      print('📡 [PrivateRoom] WS event reason=$reason v=$serverVersion');
    }

    // Discard stale events (out-of-order delivery).
    if (serverVersion != null && state.room != null) {
      if (serverVersion <= state.room!.stateVersion) {
        if (kDebugMode) {
          print('⏭️ [PrivateRoom] Discarding stale event v=$serverVersion '
              '(current=${state.room!.stateVersion})');
        }
        return;
      }

      // Version gap detected (missed an event): trigger GET resync from server
      if (serverVersion > state.room!.stateVersion + 1) {
        if (kDebugMode) {
          print('⚠️ [PrivateRoom] Version gap detected: current=${state.room!.stateVersion}, received=$serverVersion. Triggering resync.');
        }
        final roomId = state.room!.id;
        final myUserId = state.myUserId;
        if (myUserId != null) {
          _restoreRoom(roomId, myUserId);
          return;
        }
      }
    }

    switch (reason) {
      case 'joined':
      case 'left':
      case 'ready':
        if (snapshotRaw != null) {
          // Merge participant info from snapshot into existing room.
          final updated = PrivateRoomDto.fromServerSnapshot(
            snapshotRaw..putIfAbsent('id', () => state.room?.id ?? 0),
          );
          state = state.copyWith(room: updated);
        }

      case 'started':
        // Server started the match. Navigate to game.
        if (snapshotRaw != null) {
          final updated = PrivateRoomDto.fromServerSnapshot(
            snapshotRaw..putIfAbsent('id', () => state.room?.id ?? 0),
          );
          state = state.copyWith(room: updated, navEvent: PrivateRoomNavEvent.goToGame);
        } else {
          state = state.copyWith(navEvent: PrivateRoomNavEvent.goToGame);
        }

      case 'cancelled':
      case 'expired':
        // Room gone. Navigate home.
        _unsubscribeFromLobby();
        state = state.copyWith(
          clearRoom: true,
          isLoading: false,
          navEvent: PrivateRoomNavEvent.goHome,
        );

      default:
        if (kDebugMode) print('⚠️ [PrivateRoom] Unknown WS reason: $reason');
    }
  }

  void _clearRoom() {
    state = const PrivateRoomState();
  }

  Future<void> _restoreRoom(int roomId, int myUserId) async {
    try {
      final room = await _repo.show(roomId);
      state = state.copyWith(room: room, isLoading: false, myUserId: myUserId);
      _subscribeToLobby(room.id);
    } on RoomFailure catch (f) {
      state = state.copyWith(failure: f, isLoading: false);
    }
  }

  @override
  void dispose() {
    _unsubscribeFromLobby();
    super.dispose();
  }
}
