import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../data/api_tournament_repository.dart';
import '../data/tournament_repository.dart';
import '../domain/tournament_card_model.dart';
import '../domain/tournament_config.dart';
import '../domain/tournament_history_item.dart';
import '../domain/tournament_run_state.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiTournamentRepository(apiClient: apiClient);
});

final tournamentLobbyProvider =
    FutureProvider.autoDispose<List<TournamentCardModel>>((ref) async {
  final repo = ref.watch(tournamentRepositoryProvider);
  return await repo.getTournaments();
});

final tournamentHistoryProvider = StateNotifierProvider<
    TournamentHistoryController, List<TournamentHistoryItem>>((ref) {
  final repo = ref.watch(tournamentRepositoryProvider);
  return TournamentHistoryController(repo: repo);
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
    final updated = [item, ...state];
    state = updated;
    await _repo.addHistoryItem(item);
  }
}

final tournamentRunControllerProvider =
    StateNotifierProvider<TournamentRunController, TournamentRunState?>((ref) {
  final repo = ref.watch(tournamentRepositoryProvider);
  final historyController = ref.watch(tournamentHistoryProvider.notifier);
  return TournamentRunController(
    repo: repo,
    historyController: historyController,
    onClaimSuccess: () {
      ref.invalidate(walletBalanceProvider);
    },
  )..resumeActiveRun();
});

class TournamentRunController extends StateNotifier<TournamentRunState?> {
  final TournamentRepository _repo;
  final TournamentHistoryController _historyController;
  final VoidCallback? onClaimSuccess;

  TournamentRunController({
    required TournamentRepository repo,
    required TournamentHistoryController historyController,
    this.onClaimSuccess,
  })  : _repo = repo,
        _historyController = historyController,
        super(null);

  Future<void> resumeActiveRun([dynamic tournamentId]) async {
    final active = await _repo.getActiveRun();
    if (active != null) {
      state = active;
      if (tournamentId != null || active.tournamentId.isNotEmpty) {
        await syncWithServer(tournamentId ?? active.tournamentId);
      }
    }
  }

  Future<void> syncWithServer(dynamic tournamentId) async {
    try {
      final res = await _repo.getProgressApi(tournamentId);
      if (res != null && res['status'] == 'success' && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final currentLevel = (data['current_level'] as num?)?.toInt() ?? 1;
        if (state != null) {
          final updated = state!.copyWith(currentRound: currentLevel);
          state = updated;
          await _repo.saveActiveRun(updated);
        }
      }
    } catch (_) {}
  }

  Future<TournamentRunState> joinTournament(TournamentCardModel tournament) async {
    final joinRes = await _repo.joinTournamentApi(tournament.id);

    if (joinRes['status'] == 'error') {
      throw ApiException(
        message: joinRes['message']?.toString() ?? 'Failed to join tournament',
      );
    }

    final run = TournamentRunState(
      runId: 'run_${DateTime.now().millisecondsSinceEpoch}',
      tournamentId: tournament.id,
      title: tournament.title,
      mode: tournament.mode,
      currentRound: 1,
      status: TournamentRunStatus.advanced,
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

  Future<void> startMatchmaking() async {
    if (state != null) {
      final updated = state!.copyWith(status: TournamentRunStatus.matchmaking);
      state = updated;
      await _repo.saveActiveRun(updated);
    }
  }

  Future<void> cancelMatchmaking() async {
    if (state != null) {
      final updated = state!.copyWith(status: TournamentRunStatus.advanced);
      state = updated;
      await _repo.saveActiveRun(updated);
    }
  }

  Future<void> startMatch() async {
    if (state == null) return;
    final updated = state!.copyWith(status: TournamentRunStatus.playing);
    state = updated;
    await _repo.saveActiveRun(updated);
  }

  Future<void> completeRound({required bool won, int? roundReward}) async {
    if (state == null) return;
    final current = state!;
    final currentRoundConfig = TournamentConfig.defaultRounds.firstWhere(
      (r) => r.roundNumber == current.currentRound,
      orElse: () => TournamentConfig.defaultRounds.last,
    );

    if (won) {
      final reward = roundReward ?? currentRoundConfig.rewardGold;
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

    int claimedPrize = current.totalRewardEarned;
    try {
      final res = await _repo.claimPrizeApi(current.tournamentId);
      if (res['data'] is Map && res['data']['prize_gold'] != null) {
        claimedPrize = (res['data']['prize_gold'] as num).toInt();
      }
      onClaimSuccess?.call();
    } catch (_) {}

    final updated = current.copyWith(
      isRewardClaimed: true,
      totalRewardEarned: claimedPrize > 0 ? claimedPrize : current.totalRewardEarned,
    );
    state = updated;

    // Record champion history item
    final historyItem = TournamentHistoryItem(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      tournamentTitle: current.title,
      mode: current.mode,
      result: TournamentHistoryResult.champion,
      roundReached: 6,
      rewardGold: updated.totalRewardEarned,
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
