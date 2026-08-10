class RoomModel {
  final int roomId;
  final String? roomCode;
  final int? gameId;
  final String status; // waiting, matched, idle, queued
  final int? queuePosition;
  final int? queueSize;
  final List<RoomPlayerModel> players;

  RoomModel({
    required this.roomId,
    this.roomCode,
    this.gameId,
    required this.status,
    this.queuePosition,
    this.queueSize,
    required this.players,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayerModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return RoomModel(
      roomId: data['room_id'] is int ? data['room_id'] : int.tryParse(data['room_id'].toString()) ?? 0,
      roomCode: data['room_code']?.toString(),
      gameId: data['game_id'] is int ? data['game_id'] : int.tryParse(data['game_id'].toString()),
      status: data['status']?.toString() ?? 'waiting',
      queuePosition: data['queue_position'] is int ? data['queue_position'] : int.tryParse(data['queue_position'].toString()),
      queueSize: data['queue_size'] is int ? data['queue_size'] : int.tryParse(data['queue_size'].toString()),
      players: playersList,
    );
  }
}

class RoomPlayerModel {
  final int userId;
  final String username;
  final String? avatarUrl;
  final int seatPosition;
  final String color; // red, green, yellow, blue

  RoomPlayerModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.seatPosition,
    required this.color,
  });

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) {
    return RoomPlayerModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      seatPosition: json['seat_position'] is int ? json['seat_position'] : int.tryParse(json['seat_position'].toString()) ?? 1,
      color: json['color']?.toString() ?? 'red',
    );
  }
}
