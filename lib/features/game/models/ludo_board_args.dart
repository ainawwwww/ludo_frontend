import 'room_mode.dart';

/// Strongly-typed arguments for [AppConstants.ludoBoardRoute].
/// Replaces the legacy untyped `Map<String, dynamic>` extra.
class LudoBoardArgs {
  const LudoBoardArgs({
    this.players = 4,
    this.bet = 500,
    this.roomId,
    this.gameId,
    this.roomMode = RoomMode.quickMatch,
    this.roomCode,
    this.turnSeconds = 15,
    this.isOnline = true,
    this.isTournament = false,
    this.tournamentRound,
    this.tournamentMode,
    this.isPractice = false,
  });

  final int players;
  final int bet;
  final int? roomId;
  final int? gameId;
  final RoomMode roomMode;
  final String? roomCode;
  final int turnSeconds;
  final bool isOnline;
  final bool isTournament;
  final int? tournamentRound;
  final String? tournamentMode;
  final bool isPractice;

  factory LudoBoardArgs.fromMap(Map<String, dynamic> map) {
    final dynamic roomIdRaw = map['quick_match_id'] ?? map['room_id'];
    final dynamic gameIdRaw = map['game_id'];
    final dynamic roomModeRaw = map['roomMode'];

    return LudoBoardArgs(
      players: map['players'] as int? ?? 4,
      bet: map['bet'] as int? ?? 500,
      roomId: roomIdRaw is int
          ? roomIdRaw
          : int.tryParse(roomIdRaw?.toString() ?? ''),
      gameId: gameIdRaw is int
          ? gameIdRaw
          : int.tryParse(gameIdRaw?.toString() ?? ''),
      roomMode: roomModeRaw is RoomMode
          ? roomModeRaw
          : RoomMode.fromString(roomModeRaw?.toString()),
      roomCode: map['roomCode']?.toString(),
      turnSeconds: map['turnSeconds'] as int? ?? 15,
      isOnline: map['isOnline'] == true,
      isTournament: map['isTournament'] == true,
      tournamentRound: map['tournamentRound'] as int?,
      tournamentMode: map['tournamentMode'] as String?,
      isPractice: map['isPractice'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'players': players,
        'bet': bet,
        'room_id': roomId,
        'quick_match_id': roomId,
        'game_id': gameId,
        'roomMode': roomMode,
        'roomCode': roomCode,
        'turnSeconds': turnSeconds,
        'isOnline': isOnline,
        'isTournament': isTournament,
        'tournamentRound': tournamentRound,
        'tournamentMode': tournamentMode,
        'isPractice': isPractice,
      };
}
