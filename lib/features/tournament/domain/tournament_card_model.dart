import 'tournament_mode.dart';

enum TournamentCardStatus {
  available,
  inProgress,
  locked,
  viewOnly;
}

class TournamentCardModel {
  final String id;
  final String title;
  final TournamentMode mode;
  final int prizeGold;
  final int? currentRound;
  final TournamentCardStatus status;
  final int entryFeeGold;
  final int unlockLevel;
  final int participantCount;

  const TournamentCardModel({
    required this.id,
    required this.title,
    required this.mode,
    required this.prizeGold,
    this.currentRound,
    this.status = TournamentCardStatus.available,
    this.entryFeeGold = 500,
    this.unlockLevel = 1,
    this.participantCount = 64,
  });

  bool get isLocked => status == TournamentCardStatus.locked;
  bool get isInProgress => status == TournamentCardStatus.inProgress;

  TournamentCardModel copyWith({
    String? id,
    String? title,
    TournamentMode? mode,
    int? prizeGold,
    int? currentRound,
    TournamentCardStatus? status,
    int? entryFeeGold,
    int? unlockLevel,
    int? participantCount,
  }) {
    return TournamentCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mode: mode ?? this.mode,
      prizeGold: prizeGold ?? this.prizeGold,
      currentRound: currentRound ?? this.currentRound,
      status: status ?? this.status,
      entryFeeGold: entryFeeGold ?? this.entryFeeGold,
      unlockLevel: unlockLevel ?? this.unlockLevel,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}
