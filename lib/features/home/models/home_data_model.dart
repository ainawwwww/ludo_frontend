class HomeDataModel {
  final String username;
  final int level;
  final int coins;
  final int diamonds;
  final LeagueSummary? currentLeague;
  final bool isLeagueLocked;
  final int leagueUnlockLevel;
  final int globalRank;
  final String? avatarUrl;

  HomeDataModel({
    required this.username,
    required this.level,
    required this.coins,
    required this.diamonds,
    this.currentLeague,
    this.isLeagueLocked = false,
    this.leagueUnlockLevel = 4,
    required this.globalRank,
    this.avatarUrl,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    final lvl = data['level'] is int ? data['level'] : int.tryParse(data['level'].toString()) ?? 1;

    return HomeDataModel(
      username: data['username']?.toString() ?? 'Player',
      level: lvl,
      coins: data['coins'] is int ? data['coins'] : int.tryParse(data['coins'].toString()) ?? 0,
      diamonds: data['diamonds'] is int ? data['diamonds'] : int.tryParse(data['diamonds'].toString()) ?? 0,
      currentLeague: data['current_league'] is Map<String, dynamic>
          ? LeagueSummary.fromJson(data['current_league'] as Map<String, dynamic>)
          : null,
      isLeagueLocked: data['is_league_locked'] == true || lvl < 4,
      leagueUnlockLevel: data['league_unlock_level'] is int ? data['league_unlock_level'] : 4,
      globalRank: data['global_rank'] is int ? data['global_rank'] : int.tryParse(data['global_rank'].toString()) ?? 0,
      avatarUrl: data['avatar_url']?.toString(),
    );
  }
}

class LeagueSummary {
  final String name;
  final String? iconUrl;

  LeagueSummary({
    required this.name,
    this.iconUrl,
  });

  factory LeagueSummary.fromJson(Map<String, dynamic> json) {
    return LeagueSummary(
      name: json['name']?.toString() ?? 'Bronze',
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
