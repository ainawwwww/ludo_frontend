import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/tournament_card_model.dart';
import '../domain/tournament_config.dart';
import '../domain/tournament_history_item.dart';
import '../domain/tournament_mode.dart';
import '../domain/tournament_round_info.dart';
import '../domain/tournament_run_state.dart';
import 'tournament_repository.dart';

class MockTournamentRepository implements TournamentRepository {
  static const String _keyActiveRun = 'tournament_active_run';
  static const String _keyHistoryList = 'tournament_history_list';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<List<TournamentCardModel>> getTournaments() async {
    // Return sample tournaments matching the reference specs
    final active = await getActiveRun();

    return [
      TournamentCardModel(
        id: 'classic_20k',
        title: 'Classic-20.0K',
        mode: TournamentMode.classic,
        prizeGold: 3729007,
        currentRound: active?.tournamentId == 'classic_20k' ? active?.currentRound : null,
        status: active?.tournamentId == 'classic_20k'
            ? TournamentCardStatus.inProgress
            : TournamentCardStatus.available,
        entryFeeGold: 20000,
        unlockLevel: 1,
        participantCount: 64,
      ),
      TournamentCardModel(
        id: 'quick_20k',
        title: 'Quick-20.0K',
        mode: TournamentMode.quick,
        prizeGold: 1814357,
        currentRound: active?.tournamentId == 'quick_20k' ? active?.currentRound : null,
        status: active?.tournamentId == 'quick_20k'
            ? TournamentCardStatus.inProgress
            : TournamentCardStatus.available,
        entryFeeGold: 20000,
        unlockLevel: 1,
        participantCount: 32,
      ),
      const TournamentCardModel(
        id: 'classic_5k',
        title: 'Classic-5.0K',
        mode: TournamentMode.classic,
        prizeGold: 925000,
        entryFeeGold: 5000,
        unlockLevel: 3,
        participantCount: 64,
      ),
      const TournamentCardModel(
        id: 'quick_5k',
        title: 'Quick-5.0K',
        mode: TournamentMode.quick,
        prizeGold: 450000,
        entryFeeGold: 5000,
        unlockLevel: 5,
        participantCount: 32,
      ),
    ];
  }

  @override
  Future<TournamentRunState?> getActiveRun() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyActiveRun);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return TournamentRunState.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveActiveRun(TournamentRunState run) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyActiveRun, jsonEncode(run.toJson()));
  }

  @override
  Future<void> clearActiveRun() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyActiveRun);
  }

  @override
  Future<List<TournamentRoundInfo>> getLadderRounds({
    required TournamentMode mode,
    required int currentRound,
  }) async {
    final roundConfigs = mode == TournamentMode.classic
        ? TournamentConfig.defaultRounds
        : TournamentConfig.quickRounds;

    return roundConfigs.map((cfg) {
      final roundNum = cfg.roundNumber;
      TournamentRoundState state;
      if (roundNum < currentRound) {
        state = TournamentRoundState.completed;
      } else if (roundNum == currentRound) {
        state = TournamentRoundState.active;
      } else {
        state = TournamentRoundState.locked;
      }

      return TournamentRoundInfo(
        roundNumber: roundNum,
        rewardGold: cfg.rewardGold,
        bonusGold: cfg.bonusGold,
        playersRemaining: cfg.playersRemaining,
        state: state,
        subtitle: cfg.subtitle,
      );
    }).toList();
  }

  @override
  Future<List<TournamentHistoryItem>> getHistory() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyHistoryList);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Return default sample history so the user sees populated data on first view
      return [
        TournamentHistoryItem(
          id: 'hist_1',
          tournamentTitle: 'Classic-20.0K',
          mode: TournamentMode.classic,
          result: TournamentHistoryResult.champion,
          roundReached: 6,
          rewardGold: 3729007,
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TournamentHistoryItem(
          id: 'hist_2',
          tournamentTitle: 'Quick-20.0K',
          mode: TournamentMode.quick,
          result: TournamentHistoryResult.eliminated,
          roundReached: 4,
          rewardGold: 101264,
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => TournamentHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addHistoryItem(TournamentHistoryItem item) async {
    final current = await getHistory();
    final updated = [item, ...current];
    final prefs = await _getPrefs();
    await prefs.setString(
      _keyHistoryList,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}
