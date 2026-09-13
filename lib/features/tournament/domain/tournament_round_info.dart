enum TournamentRoundState {
  locked,
  completed,
  active,
  finalRound;
}

class TournamentRoundInfo {
  final int roundNumber;
  final int rewardGold;
  final int? bonusGold;
  final int playersRemaining;
  final TournamentRoundState state;
  final String? subtitle;

  const TournamentRoundInfo({
    required this.roundNumber,
    required this.rewardGold,
    this.bonusGold,
    required this.playersRemaining,
    required this.state,
    this.subtitle,
  });

  bool get isCompleted => state == TournamentRoundState.completed;
  bool get isActive => state == TournamentRoundState.active;
  bool get isLocked => state == TournamentRoundState.locked;
  bool get isFinal => roundNumber == 6;

  String get badgeAsset => 'assets/images/tournament/round_badge_$roundNumber.png';

  TournamentRoundInfo copyWith({
    int? roundNumber,
    int? rewardGold,
    int? bonusGold,
    int? playersRemaining,
    TournamentRoundState? state,
    String? subtitle,
  }) {
    return TournamentRoundInfo(
      roundNumber: roundNumber ?? this.roundNumber,
      rewardGold: rewardGold ?? this.rewardGold,
      bonusGold: bonusGold ?? this.bonusGold,
      playersRemaining: playersRemaining ?? this.playersRemaining,
      state: state ?? this.state,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
