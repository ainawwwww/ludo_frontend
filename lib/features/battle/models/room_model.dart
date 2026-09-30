class RoomModel {
  final int roomId;
  final String? roomCode;
  final int? gameId;
  final String status; // waiting, matched, idle, queued
  final String title;
  final String category;
  final List<String> tags;
  final String? countryCode;
  final String? coverImage;
  final int memberCount;
  final bool isLive;
  final bool isMine;
  final int maxPlayers;
  final int entryFee;
  final int? createdBy;
  final int? queuePosition;
  final int? queueSize;
  final List<RoomPlayerModel> players;

  RoomModel({
    required this.roomId,
    this.roomCode,
    this.gameId,
    required this.status,
    this.title = 'Ludo Room',
    this.category = 'social',
    this.tags = const ['Ludo', 'Social'],
    this.countryCode,
    this.coverImage,
    this.memberCount = 1,
    this.isLive = true,
    this.isMine = false,
    this.maxPlayers = 4,
    this.entryFee = 0,
    this.createdBy,
    this.queuePosition,
    this.queueSize,
    required this.players,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final playersList = (data['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayerModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final rawTags = data['tags'];
    List<String> parsedTags = const ['Ludo', 'Social'];
    if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString()).toList();
    }

    final rawRoomId = data['room_id'] ?? data['id'];

    return RoomModel(
      roomId: rawRoomId is int ? rawRoomId : int.tryParse(rawRoomId?.toString() ?? '0') ?? 0,
      roomCode: data['room_code']?.toString(),
      gameId: data['game_id'] is int ? data['game_id'] : int.tryParse(data['game_id']?.toString() ?? ''),
      status: data['status']?.toString() ?? 'waiting',
      title: data['title']?.toString() ?? data['name']?.toString() ?? 'Ludo Room',
      category: data['category']?.toString() ?? 'social',
      tags: parsedTags,
      countryCode: data['country_code']?.toString(),
      coverImage: data['cover_image']?.toString(),
      memberCount: data['member_count'] is int
          ? data['member_count']
          : int.tryParse(data['member_count']?.toString() ?? '1') ?? 1,
      isLive: data['is_live'] == true || data['is_live'] == 1,
      isMine: data['is_mine'] == true || data['is_mine'] == 1,
      maxPlayers: data['max_players'] is int
          ? data['max_players']
          : int.tryParse(data['max_players']?.toString() ?? '4') ?? 4,
      entryFee: data['entry_fee'] is int
          ? data['entry_fee']
          : int.tryParse(data['entry_fee']?.toString() ?? '0') ?? 0,
      createdBy: data['created_by'] is int
          ? data['created_by']
          : int.tryParse(data['created_by']?.toString() ?? ''),
      queuePosition: data['queue_position'] is int
          ? data['queue_position']
          : int.tryParse(data['queue_position']?.toString() ?? ''),
      queueSize: data['queue_size'] is int
          ? data['queue_size']
          : int.tryParse(data['queue_size']?.toString() ?? ''),
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
  final bool isReady;
  final int score;
  final Map<String, dynamic>? equippedDice;
  final Map<String, dynamic>? equippedToken;
  final Map<String, dynamic>? equippedTheme;
  final Map<String, dynamic>? avatarFrame;

  RoomPlayerModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.seatPosition,
    required this.color,
    this.isReady = true,
    this.score = 0,
    this.equippedDice,
    this.equippedToken,
    this.equippedTheme,
    this.avatarFrame,
  });

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['user_id'] ?? json['id'];
    return RoomPlayerModel(
      userId: rawUserId is int ? rawUserId : int.tryParse(rawUserId?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      seatPosition: json['seat_position'] is int
          ? json['seat_position']
          : int.tryParse(json['seat_position']?.toString() ?? '1') ?? 1,
      color: json['color']?.toString() ?? 'red',
      isReady: json['is_ready'] == true || json['is_ready'] == 1,
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      equippedDice: json['equipped_dice'] is Map<String, dynamic> ? json['equipped_dice'] as Map<String, dynamic> : null,
      equippedToken: json['equipped_token'] is Map<String, dynamic> ? json['equipped_token'] as Map<String, dynamic> : null,
      equippedTheme: json['equipped_theme'] is Map<String, dynamic> ? json['equipped_theme'] as Map<String, dynamic> : null,
      avatarFrame: json['avatar_frame'] is Map<String, dynamic> ? json['avatar_frame'] as Map<String, dynamic> : null,
    );
  }
}
