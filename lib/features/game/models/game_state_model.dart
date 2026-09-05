import 'package:ludo_vibe/features/battle/models/room_model.dart';

class GameStateModel {
  final int roomId;
  final int gameId;
  final int currentTurnUserId;
  final int? diceValue;
  final bool hasRolled;
  final List<TokenStateModel> tokens;
  final List<RoomPlayerModel> players;
  final int? winnerUserId;

  GameStateModel({
    required this.roomId,
    required this.gameId,
    required this.currentTurnUserId,
    this.diceValue,
    this.hasRolled = false,
    required this.tokens,
    required this.players,
    this.winnerUserId,
  });

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    final data =
        json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    final tokensList = (data['tokens'] as List<dynamic>?)
            ?.map((t) => TokenStateModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayerModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return GameStateModel(
      roomId: data['room_id'] is int
          ? data['room_id']
          : int.tryParse(data['room_id'].toString()) ?? 0,
      gameId: data['game_id'] is int
          ? data['game_id']
          : int.tryParse(data['game_id'].toString()) ?? 0,
      currentTurnUserId: data['current_turn_user_id'] is int
          ? data['current_turn_user_id']
          : int.tryParse(data['current_turn_user_id'].toString()) ?? 0,
      diceValue: data['dice_value'] is int
          ? data['dice_value']
          : int.tryParse(data['dice_value'].toString()),
      hasRolled: data['has_rolled'] == true,
      tokens: tokensList,
      players: playersList,
      winnerUserId: data['winner_user_id'] is int
          ? data['winner_user_id']
          : int.tryParse(data['winner_user_id'].toString()),
    );
  }

  GameStateModel copyWith({
    int? roomId,
    int? gameId,
    int? currentTurnUserId,
    int? diceValue,
    bool? hasRolled,
    List<TokenStateModel>? tokens,
    List<RoomPlayerModel>? players,
    int? winnerUserId,
  }) {
    return GameStateModel(
      roomId: roomId ?? this.roomId,
      gameId: gameId ?? this.gameId,
      currentTurnUserId: currentTurnUserId ?? this.currentTurnUserId,
      diceValue: diceValue ?? this.diceValue,
      hasRolled: hasRolled ?? this.hasRolled,
      tokens: tokens ?? this.tokens,
      players: players ?? this.players,
      winnerUserId: winnerUserId ?? this.winnerUserId,
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
