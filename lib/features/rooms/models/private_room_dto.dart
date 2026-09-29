// lib/features/rooms/models/private_room_dto.dart
//
// Data-Transfer Objects that map 1:1 to the backend JSON contracts.
// All parsing is null-safe; unknown values fall back to defaults so old
// server snapshots don't crash the app.

import 'room_models.dart';

/// Allowed entry fees, mirroring backend config('private_room.allowed_entry_fees').
const List<int> kAllowedEntryFees = [0, 500, 1000, 5000];

/// Allowed entry fees for VIP rooms, mirroring backend config('vip_room.allowed_entry_fees').
const List<int> kVipAllowedEntryFees = [1000, 5000, 10000, 25000];

/// Allowed max_players values.
const List<int> kAllowedMaxPlayers = [2, 4];

/// Turn-timer values offered in the UI (seconds).
const List<int> kAllowedTurnSeconds = [10, 15, 30];

/// Room code alphabet: uppercase, no ambiguous characters.
/// Backend: ABCDEFGHJKMNPQRSTUVWXYZ23456789
const String kRoomCodePattern = r'^[A-Z0-9]{6}$';

// ---------------------------------------------------------------------------

/// One participant row from the `room_players` pivot.
class RoomParticipantDto {
  const RoomParticipantDto({
    required this.userId,
    required this.username,
    required this.seatPosition,
    required this.color,
    required this.isReady,
    required this.isHost,
  });

  final int userId;
  final String username;
  final int seatPosition; // 1-indexed (server side)
  final String color;     // 'red' | 'green' | 'yellow' | 'blue'
  final bool isReady;
  final bool isHost;

  factory RoomParticipantDto.fromJson(Map<String, dynamic> json) {
    return RoomParticipantDto(
      userId: _asInt(json['user_id']),
      username: (json['name'] as String?) ??
          (json['username'] as String?) ??
          'Player',
      seatPosition: _asInt(json['seat'] ?? json['seat_position']),
      color: (json['color'] as String?) ?? 'red',
      isReady: _asBool(json['is_ready']),
      isHost: _asBool(json['is_host']),
    );
  }

  @override
  String toString() =>
      'RoomParticipantDto(userId: $userId, username: $username, '
      'seat: $seatPosition, color: $color, ready: $isReady, host: $isHost)';
}

// ---------------------------------------------------------------------------

/// Status values the server can send. Keeps Flutter decoupled from string literals.
enum RoomStatusDto { waiting, playing, finished, cancelled, unknown }

RoomStatusDto _parseStatus(String? raw) => switch (raw) {
  'waiting'   => RoomStatusDto.waiting,
  'playing'   => RoomStatusDto.playing,
  'finished'  => RoomStatusDto.finished,
  'cancelled' => RoomStatusDto.cancelled,
  _           => RoomStatusDto.unknown,
};

// ---------------------------------------------------------------------------

/// Full room snapshot DTO — used by GET /api/v1/private-rooms/{id}
/// and by the PrivateRoomUpdated WebSocket event's `snapshot` field.
class PrivateRoomDto {
  const PrivateRoomDto({
    required this.id,
    required this.roomCode,
    required this.status,
    required this.maxPlayers,
    required this.entryFee,
    required this.turnSeconds,
    required this.stateVersion,
    required this.participants,
    this.gameId,
    this.createdBy,
    this.title,
    this.canStart = false,
    this.isHostDirect,
    this.mySeat,
  });

  final int id;
  final String roomCode;
  final RoomStatusDto status;
  final int maxPlayers;
  final int entryFee;
  final int turnSeconds;
  final int stateVersion;
  final List<RoomParticipantDto> participants;
  final int? gameId;
  final int? createdBy;
  final String? title;
  final bool? isHostDirect;
  final int? mySeat;

  /// Derived: can the host start the match right now?
  /// Server is authoritative, but the client uses this for UI hints only.
  final bool canStart;

  bool get isWaiting  => status == RoomStatusDto.waiting;
  bool get isPlaying  => status == RoomStatusDto.playing;
  bool get isFinished => status == RoomStatusDto.finished;
  bool get isCancelled => status == RoomStatusDto.cancelled;

  int get playerCount => participants.length;
  bool get isFull => participants.length >= maxPlayers;
  bool get allGuestsReady {
    final guests = participants.where((p) => !p.isHost).toList();
    return guests.isNotEmpty && guests.every((p) => p.isReady);
  }

  bool isHost(int? userId) {
    if (isHostDirect == true) return true;
    if (userId != null && createdBy == userId) return true;
    return userId != null &&
        participants.any((p) => p.userId == userId && p.isHost);
  }

  /// Map backend status to Flutter RoomStatus:
  /// backend "finished" -> Flutter "completed"
  RoomStatus toRoomStatus() => switch (status) {
        RoomStatusDto.waiting => RoomStatus.waiting,
        RoomStatusDto.playing => RoomStatus.playing,
        RoomStatusDto.finished => RoomStatus.completed,
        RoomStatusDto.cancelled => RoomStatus.cancelled,
        _ => RoomStatus.waiting,
      };

  /// Convert to domain model [RoomSession].
  RoomSession toRoomSession({
    required int currentUserId,
    RoomType roomType = RoomType.private,
  }) {
    return RoomSession(
      id: id,
      code: roomCode,
      type: roomType,
      settings: RoomSettings(
        maxPlayers: maxPlayers,
        entryFee: entryFee,
        turnSeconds: turnSeconds,
      ),
      participants: participants
          .map((p) => RoomParticipant(
                id: p.userId.toString(),
                name: p.username,
                seat: p.seatPosition,
                role: p.isHost ? RoomRole.host : RoomRole.guest,
                ready: p.isHost ? true : p.isReady,
              ))
          .toList(),
      currentUserRole: isHost(currentUserId) ? RoomRole.host : RoomRole.guest,
      status: toRoomStatus(),
    );
  }

  /// Parse from the API response body: { "data": { ... } }
  factory PrivateRoomDto.fromApiResponse(Map<String, dynamic> json) {
    // Unwrap `data` wrapper if present
    final body = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;
    return PrivateRoomDto._fromBody(body);
  }

  /// Parse from a PrivateRoomUpdated websocket snapshot.
  /// The snapshot does NOT have user-specific fields; it is user-agnostic.
  factory PrivateRoomDto.fromServerSnapshot(Map<String, dynamic> snapshot) {
    return PrivateRoomDto._fromBody(snapshot);
  }

  factory PrivateRoomDto._fromBody(Map<String, dynamic> body) {
    final rawParticipants =
        (body['players'] ?? body['participants']) as List<dynamic>? ??
            <dynamic>[];
    final participants = rawParticipants
        .map((p) => RoomParticipantDto.fromJson(p as Map<String, dynamic>))
        .toList();

    final status = _parseStatus(body['status'] as String?);
    final maxPlayers = _asInt(body['max_players'], fallback: 2);
    final entryFee = _asInt(body['entry_fee']);
    final turnSeconds = _asInt(body['turn_seconds'], fallback: 15);
    final guestCount = participants.where((p) => !p.isHost).length;
    final allGuestsReady = guestCount > 0 &&
        participants
            .where((p) => !p.isHost)
            .every((p) => p.isReady);
    final isFull = participants.length >= maxPlayers;
    final canStartServer = _asBool(body['can_start']);
    final canStart = canStartServer ||
        (status == RoomStatusDto.waiting && isFull && allGuestsReady);

    final roomCode = (body['code'] as String?) ??
        (body['room_code'] as String?) ??
        '';
    final createdBy = _asIntOrNull(body['host_user_id'] ?? body['created_by']);
    final stateVersion =
        _asInt(body['version'] ?? body['state_version']);
    final isHostDirect =
        body.containsKey('is_host') ? _asBool(body['is_host']) : null;
    final mySeat = _asIntOrNull(body['my_seat']);

    return PrivateRoomDto(
      id: _asInt(body['id']),
      roomCode: roomCode,
      status: status,
      maxPlayers: maxPlayers,
      entryFee: entryFee,
      turnSeconds: turnSeconds,
      stateVersion: stateVersion,
      participants: participants,
      gameId: _asIntOrNull(body['game_id']),
      createdBy: createdBy,
      title: body['title'] as String?,
      canStart: canStart,
      isHostDirect: isHostDirect,
      mySeat: mySeat,
    );
  }

  PrivateRoomDto copyWith({
    RoomStatusDto? status,
    List<RoomParticipantDto>? participants,
    bool? canStart,
    int? stateVersion,
    int? gameId,
    bool? isHostDirect,
    int? mySeat,
  }) {
    return PrivateRoomDto(
      id: id,
      roomCode: roomCode,
      status: status ?? this.status,
      maxPlayers: maxPlayers,
      entryFee: entryFee,
      turnSeconds: turnSeconds,
      stateVersion: stateVersion ?? this.stateVersion,
      participants: participants ?? this.participants,
      gameId: gameId ?? this.gameId,
      createdBy: createdBy,
      title: title,
      canStart: canStart ?? this.canStart,
      isHostDirect: isHostDirect ?? this.isHostDirect,
      mySeat: mySeat ?? this.mySeat,
    );
  }

  @override
  String toString() =>
      'PrivateRoomDto(id: $id, code: $roomCode, status: $status, '
      'players: ${participants.length}/$maxPlayers, version: $stateVersion)';
}

// ---------------------------------------------------------------------------
// helpers

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? fallback;
}

int? _asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

bool _asBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  return v.toString() == 'true' || v.toString() == '1';
}
