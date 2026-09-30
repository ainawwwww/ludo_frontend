import 'package:ludo_vibe/features/battle/models/room_model.dart';

class GameStateModel {
  final int roomId;
  final int gameId;
  final String status;
  final int? currentTurnUserId;
  final int currentTurnSeat;
  final int? diceValue;
  final bool canRoll;
  final bool mustMove;
  final bool hasRolled;
  final int consecutiveSixes;
  final int turnSeconds;
  final Map<String, List<int>> tokenPositions;
  final List<TokenStateModel> tokens;
  final List<RoomPlayerModel> players;
  final Map<String, dynamic> rawPlayers;
  final List<int> movableTokens;
  final int? winnerUserId;
  final String? lastActionAt;
  final Map<String, dynamic> rawJson;

  GameStateModel({
    required this.roomId,
    required this.gameId,
    this.status = 'in_progress',
    this.currentTurnUserId,
    this.currentTurnSeat = 0,
    this.diceValue,
    this.canRoll = true,
    this.mustMove = false,
    this.hasRolled = false,
    this.consecutiveSixes = 0,
    this.turnSeconds = 15,
    this.tokenPositions = const {},
    this.tokens = const [],
    this.players = const [],
    this.rawPlayers = const {},
    this.movableTokens = const [],
    this.winnerUserId,
    this.lastActionAt,
    this.rawJson = const {},
  });

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    final data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    // 1. Parse legacy tokens list if present
    final tokensList = (data['tokens'] as List<dynamic>?)
            ?.map((t) => TokenStateModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    // 2. Parse authoritative token_positions map
    final parsedPositions = <String, List<int>>{};
    if (data['token_positions'] is Map) {
      final posMap = data['token_positions'] as Map<dynamic, dynamic>;
      posMap.forEach((colorKey, positions) {
        if (positions is List) {
          parsedPositions[colorKey.toString().toLowerCase()] = positions
              .map((p) => int.tryParse(p.toString()) ?? -1)
              .toList();
        }
      });
    }

    // 3. Parse players
    final playersList = <RoomPlayerModel>[];
    final rawPlayersMap = <String, dynamic>{};
    if (data['players'] is List) {
      for (final p in data['players'] as List) {
        if (p is Map<String, dynamic>) {
          playersList.add(RoomPlayerModel.fromJson(p));
        }
      }
    } else if (data['players'] is Map) {
      final pMap = data['players'] as Map<dynamic, dynamic>;
      pMap.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          rawPlayersMap[key.toString()] = val;
          playersList.add(RoomPlayerModel.fromJson(val));
        }
      });
    }

    // 4. Parse movable tokens
    final movable = (data['movable_tokens'] as List<dynamic>?)
            ?.map((t) => int.tryParse(t.toString()) ?? 0)
            .toList() ??
        [];

    final roomId = data['room_id'] is int
        ? data['room_id'] as int
        : (data['quick_match_id'] is int
            ? data['quick_match_id'] as int
            : int.tryParse(data['room_id']?.toString() ??
                    data['quick_match_id']?.toString() ??
                    '0') ??
                0);

    final gameId = data['game_id'] is int
        ? data['game_id'] as int
        : int.tryParse(data['game_id']?.toString() ?? '0') ?? 0;

    final currentTurnUserId = data['current_turn_user_id'] is int
        ? data['current_turn_user_id'] as int
        : int.tryParse(data['current_turn_user_id']?.toString() ?? '');

    final currentTurnSeat = data['current_turn_seat'] is int
        ? data['current_turn_seat'] as int
        : int.tryParse(data['current_turn_seat']?.toString() ?? '0') ?? 0;

    final diceVal = data['dice_value'] is int
        ? data['dice_value'] as int
        : int.tryParse(data['dice_value']?.toString() ?? '');

    final canRoll = data['can_roll'] == true;
    final mustMove = data['must_move'] == true;
    final hasRolled = data['has_rolled'] == true || (!canRoll && diceVal != null);

    return GameStateModel(
      roomId: roomId,
      gameId: gameId,
      status: data['status']?.toString() ?? 'in_progress',
      currentTurnUserId: currentTurnUserId,
      currentTurnSeat: currentTurnSeat,
      diceValue: diceVal,
      canRoll: canRoll,
      mustMove: mustMove,
      hasRolled: hasRolled,
      consecutiveSixes: data['consecutive_sixes'] is int
          ? data['consecutive_sixes'] as int
          : int.tryParse(data['consecutive_sixes']?.toString() ?? '0') ?? 0,
      turnSeconds: data['turn_seconds'] is int
          ? data['turn_seconds'] as int
          : int.tryParse(data['turn_seconds']?.toString() ?? '15') ?? 15,
      tokenPositions: parsedPositions,
      tokens: tokensList,
      players: playersList,
      rawPlayers: rawPlayersMap,
      movableTokens: movable,
      winnerUserId: data['winner_user_id'] is int
          ? data['winner_user_id'] as int
          : (data['winner_id'] is int
              ? data['winner_id'] as int
              : int.tryParse(data['winner_user_id']?.toString() ??
                  data['winner_id']?.toString() ??
                  '')),
      lastActionAt: data['last_action_at']?.toString(),
      rawJson: data,
    );
  }

  GameStateModel copyWith({
    int? roomId,
    int? gameId,
    String? status,
    int? currentTurnUserId,
    int? currentTurnSeat,
    int? diceValue,
    bool? canRoll,
    bool? mustMove,
    bool? hasRolled,
    int? consecutiveSixes,
    int? turnSeconds,
    Map<String, List<int>>? tokenPositions,
    List<TokenStateModel>? tokens,
    List<RoomPlayerModel>? players,
    Map<String, dynamic>? rawPlayers,
    List<int>? movableTokens,
    int? winnerUserId,
    String? lastActionAt,
    Map<String, dynamic>? rawJson,
  }) {
    return GameStateModel(
      roomId: roomId ?? this.roomId,
      gameId: gameId ?? this.gameId,
      status: status ?? this.status,
      currentTurnUserId: currentTurnUserId ?? this.currentTurnUserId,
      currentTurnSeat: currentTurnSeat ?? this.currentTurnSeat,
      diceValue: diceValue ?? this.diceValue,
      canRoll: canRoll ?? this.canRoll,
      mustMove: mustMove ?? this.mustMove,
      hasRolled: hasRolled ?? this.hasRolled,
      consecutiveSixes: consecutiveSixes ?? this.consecutiveSixes,
      turnSeconds: turnSeconds ?? this.turnSeconds,
      tokenPositions: tokenPositions ?? this.tokenPositions,
      tokens: tokens ?? this.tokens,
      players: players ?? this.players,
      rawPlayers: rawPlayers ?? this.rawPlayers,
      movableTokens: movableTokens ?? this.movableTokens,
      winnerUserId: winnerUserId ?? this.winnerUserId,
      lastActionAt: lastActionAt ?? this.lastActionAt,
      rawJson: rawJson ?? this.rawJson,
    );
  }
}

class TokenStateModel {
  final int userId;
  final int tokenIndex;
  final int position;
  final bool isHome;
  final bool isSafe;

  TokenStateModel({
    required this.userId,
    required this.tokenIndex,
    required this.position,
    this.isHome = false,
    this.isSafe = false,
  });

  factory TokenStateModel.fromJson(Map<String, dynamic> json) {
    return TokenStateModel(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      tokenIndex: json['token_index'] is int
          ? json['token_index']
          : int.tryParse(json['token_index'].toString()) ?? 0,
      position: json['position'] is int
          ? json['position']
          : int.tryParse(json['position'].toString()) ?? 0,
      isHome: json['is_home'] == true || json['is_home'] == 1,
      isSafe: json['is_safe'] == true || json['is_safe'] == 1,
    );
  }
}
