import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_tournament_repository.dart';
import '../data/tournament_repository.dart';
import '../domain/tournament_card_model.dart';
import '../domain/tournament_config.dart';
import '../domain/tournament_history_item.dart';
import '../domain/tournament_run_state.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return MockTournamentRepository();
});

final tournamentLobbyProvider =
    FutureProvider.autoDispose<List<TournamentCardModel>>((ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getTournaments();
});

final tournamentHistoryProvider = StateNotifierProvider<
    TournamentHistoryController, List<TournamentHistoryItem>>((ref) {
  final repo = ref.watch(tournamentRepositoryProvider);
  return TournamentHistoryController(repo: repo)..loadHistory();
});

class TournamentHistoryController
    extends StateNotifier<List<TournamentHistoryItem>> {
  final TournamentRepository _repo;

  TournamentHistoryController({required TournamentRepository repo})
      : _repo = repo,
        super([]);

  Future<void> loadHistory() async {
    final history = await _repo.getHistory();
    state = history;
  }

  Future<void> addHistory(TournamentHistoryItem item) async {
    await _repo.addHistoryItem(item);
    state = [item, ...state];
  }
}

final tournamentRunControllerProvider =
    StateNotifierProvider<TournamentRunController, TournamentRunState?>((ref) {
  final repo = ref.watch(tournamentRepositoryProvider);
  final historyController = ref.watch(tournamentHistoryProvider.notifier);
  return TournamentRunController(
    repo: repo,
    historyController: historyController,
  )..resumeActiveRun();
});

class TournamentRunController extends StateNotifier<TournamentRunState?> {
  final TournamentRepository _repo;
  final TournamentHistoryController _historyController;

  TournamentRunController({
    required TournamentRepository repo,
    required TournamentHistoryController historyController,
  })  : _repo = repo,
        _historyController = historyController,
        super(null);

  Future<void> resumeActiveRun() async {
    final active = await _repo.getActiveRun();
    if (active != null) {
      state = active;
    }
  }

  Future<TournamentRunState> joinTournament(TournamentCardModel tournament) async {
    final run = TournamentRunState(
      runId: 'run_${DateTime.now().millisecondsSinceEpoch}',
      tournamentId: tournament.id,
      title: tournament.title,
      mode: tournament.mode,
      currentRound: 1,
      status: TournamentRunStatus.matchmaking,
      wins: 0,
      losses: 0,
      isRewardClaimed: false,
      totalRewardEarned: 0,
      startedAt: DateTime.now(),
    );
    state = run;
    await _repo.saveActiveRun(run);
    return run;
  }

  Future<void> cancelMatchmaking() async {
    if (state != null && state!.isMatchmaking) {
      // If round 1, we can clear the run
      if (state!.currentRound == 1 && state!.wins == 0) {
        await _repo.clearActiveRun();
        state = null;
      } else {
        // Return to advanced status at current round
        final updated = state!.copyWith(status: TournamentRunStatus.advanced);
        state = updated;
        await _repo.saveActiveRun(updated);
      }
    }
  }

  Future<void> startMatch() async {
    if (state == null) return;
    final updated = state!.copyWith(status: TournamentRunStatus.playing);
    state = updated;
    await _repo.saveActiveRun(updated);
  }

  Future<void> completeRound({required bool won}) async {
    if (state == null) return;
    final current = state!;
    final currentRoundConfig = TournamentConfig.defaultRounds.firstWhere(
      (r) => r.roundNumber == current.currentRound,
      orElse: () => TournamentConfig.defaultRounds.last,
    );

    if (won) {
      final reward = currentRoundConfig.rewardGold;
      final newTotalReward = current.totalRewardEarned + reward;

      if (current.currentRound >= 6) {
        // Champion achieved!
        final updated = current.copyWith(
          status: TournamentRunStatus.champion,
          wins: current.wins + 1,
          totalRewardEarned: newTotalReward,
        );
        state = updated;
        await _repo.saveActiveRun(updated);
      } else {
        // Advanced to next round
        final updated = current.copyWith(
          currentRound: current.currentRound + 1,
          status: TournamentRunStatus.advanced,
          wins: current.wins + 1,
          totalRewardEarned: newTotalReward,
        );
        state = updated;
        await _repo.saveActiveRun(updated);
      }
    } else {
      // Eliminated
      final updated = current.copyWith(
        status: TournamentRunStatus.eliminated,
        losses: current.losses + 1,
      );
      state = updated;

      // Record to history list
      final historyItem = TournamentHistoryItem(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        tournamentTitle: current.title,
        mode: current.mode,
        result: TournamentHistoryResult.eliminated,
        roundReached: current.currentRound,
        rewardGold: current.totalRewardEarned,
        completedAt: DateTime.now(),
      );
      await _historyController.addHistory(historyItem);
      // Clear active run since tournament ended
      await _repo.clearActiveRun();
    }
  }

  Future<void> claimChampionReward() async {
    if (state == null) return;
    final current = state!;
    if (current.isRewardClaimed) return;

    final updated = current.copyWith(isRewardClaimed: true);
    state = updated;

    // Record champion history item
    final historyItem = TournamentHistoryItem(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      tournamentTitle: current.title,
      mode: current.mode,
      result: TournamentHistoryResult.champion,
      roundReached: 6,
      rewardGold: current.totalRewardEarned,
      completedAt: DateTime.now(),
    );
    await _historyController.addHistory(historyItem);
    await _repo.clearActiveRun();
  }

  Future<void> resetRun() async {
    await _repo.clearActiveRun();
    state = null;
  }
}
