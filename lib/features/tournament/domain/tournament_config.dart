import 'tournament_mode.dart';

class TournamentRoundConfig {
  final int roundNumber;
  final int rewardGold;
  final int? bonusGold;
  final int playersRemaining;
  final String? subtitle;

  const TournamentRoundConfig({
    required this.roundNumber,
    required this.rewardGold,
    this.bonusGold,
    required this.playersRemaining,
    this.subtitle,
  });
}

class TournamentConfig {
  final String id;
  final String title;
  final TournamentMode mode;
  final int totalPrizeGold;
  final int entryFeeGold;
  final int unlockLevel;
  final List<TournamentRoundConfig> rounds;

  const TournamentConfig({
    required this.id,
    required this.title,
    required this.mode,
    required this.totalPrizeGold,
    required this.entryFeeGold,
    required this.unlockLevel,
    required this.rounds,
  });

  /// Reference tournament configuration with exact values from specification
  static const List<TournamentRoundConfig> defaultRounds = [
    TournamentRoundConfig(
      roundNumber: 1,
      rewardGold: 209254,
      playersRemaining: 64,
    ),
    TournamentRoundConfig(
      roundNumber: 2,
      rewardGold: 1244398,
      playersRemaining: 32,
    ),
    TournamentRoundConfig(
      roundNumber: 3,
      rewardGold: 344147,
      playersRemaining: 16,
    ),
    TournamentRoundConfig(
      roundNumber: 4,
      rewardGold: 101264,
      playersRemaining: 8,
    ),
    TournamentRoundConfig(
      roundNumber: 5,
      rewardGold: 31706,
      playersRemaining: 4,
    ),
    TournamentRoundConfig(
      roundNumber: 6,
      rewardGold: 88358,
      bonusGold: 19570,
      playersRemaining: 2,
      subtitle: '25% of prize pool for the winner!',
    ),
  ];

  static const List<TournamentRoundConfig> quickRounds = [
    TournamentRoundConfig(
      roundNumber: 1,
      rewardGold: 104627,
      playersRemaining: 32,
    ),
    TournamentRoundConfig(
      roundNumber: 2,
      rewardGold: 622199,
      playersRemaining: 16,
    ),
    TournamentRoundConfig(
      roundNumber: 3,
      rewardGold: 172073,
      playersRemaining: 8,
    ),
    TournamentRoundConfig(
      roundNumber: 4,
      rewardGold: 50632,
      playersRemaining: 4,
    ),
    TournamentRoundConfig(
      roundNumber: 5,
      rewardGold: 15853,
      playersRemaining: 2,
    ),
    TournamentRoundConfig(
      roundNumber: 6,
      rewardGold: 44179,
      bonusGold: 9785,
      playersRemaining: 2,
      subtitle: '25% of prize pool for the winner!',
    ),
  ];
}
