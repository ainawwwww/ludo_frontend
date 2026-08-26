class LeagueTierModel {
  final int id;
  final String name;
  final int tierOrder;
  final int minPoints;
  final int? maxPoints;
  final String? iconUrl;

  LeagueTierModel({
    required this.id,
    required this.name,
    required this.tierOrder,
    required this.minPoints,
    this.maxPoints,
    this.iconUrl,
  });

  factory LeagueTierModel.fromJson(Map<String, dynamic> json) {
    return LeagueTierModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Bronze',
      tierOrder: json['tier_order'] is int ? json['tier_order'] : int.tryParse(json['tier_order'].toString()) ?? 1,
      minPoints: json['min_points'] is int ? json['min_points'] : int.tryParse(json['min_points'].toString()) ?? 0,
      maxPoints: json['max_points'] != null ? (json['max_points'] is int ? json['max_points'] : int.tryParse(json['max_points'].toString())) : null,
      iconUrl: json['icon_url']?.toString(),
    );
  }
}

class LeagueSeasonInfo {
  final int id;
  final int seasonNumber;
  final DateTime startsAt;
  final DateTime endsAt;
  final int secondsRemaining;

  LeagueSeasonInfo({
    required this.id,
    required this.seasonNumber,
    required this.startsAt,
    required this.endsAt,
    required this.secondsRemaining,
  });

  factory LeagueSeasonInfo.fromJson(Map<String, dynamic> json) {
    return LeagueSeasonInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      seasonNumber: json['season_number'] is int ? json['season_number'] : int.tryParse(json['season_number'].toString()) ?? 1,
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      secondsRemaining: json['seconds_remaining'] is int ? json['seconds_remaining'] : int.tryParse(json['seconds_remaining'].toString()) ?? 0,
    );
  }
}

class LeagueUserSummary {
  final String tierName;
  final int tierOrder;
  final String? iconUrl;
  final int lifetimePoints;
  final int divisionNumber;
  final int myRankInDivision;
  final int pointsNeededForNextTier;
  final bool isLocked;
  final int unlockLevel;

  LeagueUserSummary({
    required this.tierName,
    required this.tierOrder,
    this.iconUrl,
    required this.lifetimePoints,
    required this.divisionNumber,
    required this.myRankInDivision,
    required this.pointsNeededForNextTier,
    this.isLocked = false,
    this.unlockLevel = 4,
  });

  factory LeagueUserSummary.fromJson(Map<String, dynamic> json) {
    return LeagueUserSummary(
      tierName: json['tier_name']?.toString() ?? 'Bronze',
      tierOrder: json['tier_order'] is int ? json['tier_order'] : int.tryParse(json['tier_order'].toString()) ?? 1,
      iconUrl: json['icon_url']?.toString(),
      lifetimePoints: json['lifetime_points'] is int ? json['lifetime_points'] : int.tryParse(json['lifetime_points'].toString()) ?? 0,
      divisionNumber: json['division_number'] is int ? json['division_number'] : int.tryParse(json['division_number'].toString()) ?? 1,
      myRankInDivision: json['my_rank_in_division'] is int ? json['my_rank_in_division'] : int.tryParse(json['my_rank_in_division'].toString()) ?? 1,
      pointsNeededForNextTier: json['points_needed_for_next_tier'] is int ? json['points_needed_for_next_tier'] : int.tryParse(json['points_needed_for_next_tier'].toString()) ?? 0,
      isLocked: json['is_locked'] == true,
      unlockLevel: json['unlock_level'] is int ? json['unlock_level'] : int.tryParse(json['unlock_level']?.toString() ?? '') ?? 4,
    );
  }
}

class LeagueDivisionMemberModel {
  final int rank;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String country;
  final int pointsInDivision;
  final bool isMe;

  LeagueDivisionMemberModel({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.country,
    required this.pointsInDivision,
    required this.isMe,
  });

  factory LeagueDivisionMemberModel.fromJson(Map<String, dynamic> json) {
    return LeagueDivisionMemberModel(
      rank: json['rank'] is int ? json['rank'] : int.tryParse(json['rank'].toString()) ?? 1,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      country: json['country']?.toString() ?? 'PK',
      pointsInDivision: json['points_in_division'] is int ? json['points_in_division'] : int.tryParse(json['points_in_division'].toString()) ?? 0,
      isMe: json['is_me'] == true,
    );
  }
}

class LeagueDivisionResponse {
  final LeagueSeasonInfo season;
  final LeagueUserSummary userSummary;
  final List<LeagueDivisionMemberModel> divisionMembers;

  LeagueDivisionResponse({
    required this.season,
    required this.userSummary,
    required this.divisionMembers,
  });

  factory LeagueDivisionResponse.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    final membersList = (data['division_members'] as List<dynamic>?)
            ?.map((e) => LeagueDivisionMemberModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return LeagueDivisionResponse(
      season: LeagueSeasonInfo.fromJson(data['season'] as Map<String, dynamic>),
      userSummary: LeagueUserSummary.fromJson(data['user_summary'] as Map<String, dynamic>),
      divisionMembers: membersList,
    );
  }
}
