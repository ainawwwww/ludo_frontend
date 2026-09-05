class LeaderboardItemModel {
  final int rank;
  final int userId;
  final String username;
  final String? avatarUrl;
  final int totalWins;
  final int totalGames;
  final double winRate;

  LeaderboardItemModel({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalWins,
    required this.totalGames,
    required this.winRate,
  });

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      rank: json['rank'] is int
          ? json['rank']
          : int.tryParse(json['rank'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatar_url']?.toString(),
      totalWins: json['total_wins'] is int
          ? json['total_wins']
          : int.tryParse(json['total_wins'].toString()) ?? 0,
      totalGames: json['total_games'] is int
          ? json['total_games']
          : int.tryParse(json['total_games'].toString()) ?? 0,
      winRate: (json['win_rate'] is num)
          ? (json['win_rate'] as num).toDouble()
          : double.tryParse(json['win_rate'].toString()) ?? 0.0,
    );
  }
}
