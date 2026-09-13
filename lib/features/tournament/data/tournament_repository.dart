import '../domain/tournament_card_model.dart';
import '../domain/tournament_history_item.dart';
import '../domain/tournament_mode.dart';
import '../domain/tournament_round_info.dart';
import '../domain/tournament_run_state.dart';

abstract class TournamentRepository {
  Future<List<TournamentCardModel>> getTournaments();
  Future<TournamentRunState?> getActiveRun();
  Future<void> saveActiveRun(TournamentRunState run);
  Future<void> clearActiveRun();
  Future<List<TournamentRoundInfo>> getLadderRounds({
    required TournamentMode mode,
    required int currentRound,
  });
  Future<List<TournamentHistoryItem>> getHistory();
  Future<void> addHistoryItem(TournamentHistoryItem item);
}
