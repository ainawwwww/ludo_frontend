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
    final title = (json['tournament_title'] ?? json['tournamentTitle'] ?? 'Tournament').toString();
    final modeStr = (json['mode'] ?? 'classic').toString();
    final resultStr = (json['result'] ?? 'eliminated').toString();
    final roundReached = (json['round_reached'] as num?)?.toInt() ??
        (json['roundReached'] as num?)?.toInt() ??
        1;
    final rewardGold = (json['reward_gold'] as num?)?.toInt() ??
        (json['rewardGold'] as num?)?.toInt() ??
        0;
    final completedAtStr = (json['completed_at'] ?? json['completedAt'])?.toString();

    return TournamentHistoryItem(
      id: json['id']?.toString() ?? 'hist_0',
      tournamentTitle: title,
      mode: modeStr == 'quick' ? TournamentMode.quick : TournamentMode.classic,
      result: resultStr == 'champion'
          ? TournamentHistoryResult.champion
          : TournamentHistoryResult.eliminated,
      roundReached: roundReached,
      rewardGold: rewardGold,
      completedAt: completedAtStr != null
          ? DateTime.tryParse(completedAtStr) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
