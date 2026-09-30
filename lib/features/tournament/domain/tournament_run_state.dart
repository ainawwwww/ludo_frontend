import 'tournament_mode.dart';

enum TournamentRunStatus {
  matchmaking,
  playing,
  advanced,
  eliminated,
  champion;

  static TournamentRunStatus fromString(String val) {
    return TournamentRunStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TournamentRunStatus.matchmaking,
    );
  }
}

class TournamentRunState {
  final String runId;
  final String tournamentId;
  final String title;
  final TournamentMode mode;
  final int currentRound;
  final TournamentRunStatus status;
  final int wins;
  final int losses;
  final bool isRewardClaimed;
  final int totalRewardEarned;
  final DateTime startedAt;

  const TournamentRunState({
    required this.runId,
    required this.tournamentId,
    required this.title,
    required this.mode,
    required this.currentRound,
    required this.status,
    this.wins = 0,
    this.losses = 0,
    this.isRewardClaimed = false,
    this.totalRewardEarned = 0,
    required this.startedAt,
  });

  bool get isMatchmaking => status == TournamentRunStatus.matchmaking;
  bool get isPlaying => status == TournamentRunStatus.playing;
  bool get isAdvanced => status == TournamentRunStatus.advanced;
  bool get isEliminated => status == TournamentRunStatus.eliminated;
  bool get isChampion => status == TournamentRunStatus.champion;

  TournamentRunState copyWith({
    String? runId,
    String? tournamentId,
    String? title,
    TournamentMode? mode,
    int? currentRound,
    TournamentRunStatus? status,
    int? wins,
    int? losses,
    bool? isRewardClaimed,
    int? totalRewardEarned,
    DateTime? startedAt,
  }) {
    return TournamentRunState(
      runId: runId ?? this.runId,
      tournamentId: tournamentId ?? this.tournamentId,
      title: title ?? this.title,
      mode: mode ?? this.mode,
      currentRound: currentRound ?? this.currentRound,
      status: status ?? this.status,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      totalRewardEarned: totalRewardEarned ?? this.totalRewardEarned,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runId': runId,
      'tournamentId': tournamentId,
      'title': title,
      'mode': mode.name,
      'currentRound': currentRound,
      'status': status.name,
      'wins': wins,
      'losses': losses,
      'isRewardClaimed': isRewardClaimed,
      'totalRewardEarned': totalRewardEarned,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory TournamentRunState.fromJson(Map<String, dynamic> json) {
    return TournamentRunState(
      runId: json['runId'] as String,
      tournamentId: json['tournamentId'] as String? ?? 'classic_20k',
      title: json['title'] as String? ?? 'Classic Tournament',
      mode: json['mode'] == 'quick' ? TournamentMode.quick : TournamentMode.classic,
      currentRound: json['currentRound'] as int? ?? 1,
      status: TournamentRunStatus.fromString(json['status'] as String? ?? 'matchmaking'),
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      isRewardClaimed: json['isRewardClaimed'] as bool? ?? false,
      totalRewardEarned: json['totalRewardEarned'] as int? ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
