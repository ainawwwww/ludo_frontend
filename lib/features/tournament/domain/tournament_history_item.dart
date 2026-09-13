import 'tournament_mode.dart';

enum TournamentHistoryResult {
  champion,
  eliminated;

  String get displayName {
    switch (this) {
      case TournamentHistoryResult.champion:
        return 'Champion 🏆';
      case TournamentHistoryResult.eliminated:
        return 'Eliminated';
    }
  }
}

class TournamentHistoryItem {
  final String id;
  final String tournamentTitle;
  final TournamentMode mode;
  final TournamentHistoryResult result;
  final int roundReached;
  final int rewardGold;
  final DateTime completedAt;

  const TournamentHistoryItem({
    required this.id,
    required this.tournamentTitle,
    required this.mode,
    required this.result,
    required this.roundReached,
    required this.rewardGold,
    required this.completedAt,
  });

  bool get isChampion => result == TournamentHistoryResult.champion;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentTitle': tournamentTitle,
      'mode': mode.name,
      'result': result.name,
      'roundReached': roundReached,
      'rewardGold': rewardGold,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory TournamentHistoryItem.fromJson(Map<String, dynamic> json) {
    return TournamentHistoryItem(
      id: json['id'] as String,
      tournamentTitle: json['tournamentTitle'] as String? ?? 'Tournament',
      mode: json['mode'] == 'quick' ? TournamentMode.quick : TournamentMode.classic,
      result: json['result'] == 'champion'
          ? TournamentHistoryResult.champion
          : TournamentHistoryResult.eliminated,
      roundReached: json['roundReached'] as int? ?? 1,
      rewardGold: json['rewardGold'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
