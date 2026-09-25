class ProfileModel {
  final int id;
  final String name;
  final int level;
  final int xp;
  final String? avatarUrl;
  final String? country;
  final String? gender;
  final String? dob;
  final String? bio;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final double winRate;
  final LeagueInfo? leagueInfo;
  final AchievementsInfo? achievements;

  ProfileModel({
    required this.id,
    required this.name,
    required this.level,
    this.xp = 0,
    this.avatarUrl,
    this.country,
    this.gender,
    this.dob,
    this.bio,
    required this.totalGamesPlayed,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    this.leagueInfo,
    this.achievements,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data =
        json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return ProfileModel(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id'].toString()) ?? 0,
      name: data['name']?.toString() ?? 'Player',
      level: data['level'] is int
          ? data['level']
          : int.tryParse(data['level'].toString()) ?? 1,
      xp: data['xp'] is int
          ? data['xp']
          : int.tryParse(data['xp']?.toString() ?? '0') ?? 0,
      avatarUrl: data['avatar_url']?.toString(),
      country: data['country']?.toString(),
      gender: data['gender']?.toString(),
      dob: data['dob']?.toString(),
      bio: data['bio']?.toString(),
      totalGamesPlayed: data['total_games_played'] is int
          ? data['total_games_played']
          : int.tryParse(data['total_games_played'].toString()) ?? 0,
      totalWins: data['total_wins'] is int
          ? data['total_wins']
          : int.tryParse(data['total_wins'].toString()) ?? 0,
      totalLosses: data['total_losses'] is int
          ? data['total_losses']
          : int.tryParse(data['total_losses'].toString()) ?? 0,
      winRate: (data['win_rate'] is num)
          ? (data['win_rate'] as num).toDouble()
          : double.tryParse(data['win_rate'].toString()) ?? 0.0,
      leagueInfo: data['league_info'] is Map<String, dynamic>
          ? LeagueInfo.fromJson(data['league_info'] as Map<String, dynamic>)
          : null,
      achievements: data['achievements'] is Map<String, dynamic>
          ? AchievementsInfo.fromJson(
              data['achievements'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeagueInfo {
  final String currentTier;
  final int points;
  final String progressStatus;
  final String? nextTier;

  LeagueInfo({
    required this.currentTier,
    required this.points,
    required this.progressStatus,
    this.nextTier,
  });

  factory LeagueInfo.fromJson(Map<String, dynamic> json) {
    return LeagueInfo(
      currentTier: json['current_tier']?.toString() ?? 'Bronze',
      points: json['points'] is int
          ? json['points']
          : int.tryParse(json['points'].toString()) ?? 0,
      progressStatus: json['progress_status']?.toString() ?? 'low',
      nextTier: json['next_tier']?.toString(),
    );
  }
}

class AchievementsInfo {
  final LevelBadge? levelBadge;
  final String? favoriteDice;

  AchievementsInfo({
    this.levelBadge,
    this.favoriteDice,
  });

  factory AchievementsInfo.fromJson(Map<String, dynamic> json) {
    return AchievementsInfo(
      levelBadge: json['level_badge'] is Map<String, dynamic>
          ? LevelBadge.fromJson(json['level_badge'] as Map<String, dynamic>)
          : null,
      favoriteDice: json['favorite_dice']?.toString(),
    );
  }
}

class LevelBadge {
  final String name;
  final String icon;
  final int level;

  LevelBadge({
    required this.name,
    required this.icon,
    required this.level,
  });

  factory LevelBadge.fromJson(Map<String, dynamic> json) {
    return LevelBadge(
      name: json['name']?.toString() ?? 'Badge',
      icon: json['icon']?.toString() ?? '',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level'].toString()) ?? 1,
    );
  }
}
