import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/tournament_card_model.dart';
import '../domain/tournament_config.dart';
import '../domain/tournament_history_item.dart';
import '../domain/tournament_mode.dart';
import '../domain/tournament_round_info.dart';
import '../domain/tournament_run_state.dart';
import 'tournament_repository.dart';

class ApiTournamentRepository implements TournamentRepository {
  final ApiClient _apiClient;
  static const String _keyActiveRun = 'tournament_active_run';
  static const String _keyHistoryList = 'tournament_history_list';

  SharedPreferences? _prefs;

  ApiTournamentRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<List<TournamentCardModel>> getTournaments() async {
    final response = await _apiClient.get(ApiEndpoints.tournaments);
    if (response != null && response['status'] == 'success') {
      final List rawData = response['data'] as List;
      final activeRun = await getActiveRun();

      return rawData.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        final id = map['id'].toString();
        final name = map['name']?.toString() ?? 'Tournament';
        final modeStr = map['mode']?.toString() ?? 'classic';
        final mode = modeStr == 'quick'
            ? TournamentMode.quick
            : TournamentMode.classic;
        final entryFee = (map['entry_fee'] as num?)?.toInt() ?? 0;
        final prizePool = (map['prize_pool'] as num?)?.toInt() ?? 0;
        final unlockLevel = (map['unlock_level'] as num?)?.toInt() ?? 1;
        final participantCount = (map['participant_count'] as num?)?.toInt() ?? 32;
        final userPart = map['user_participation'] as Map<String, dynamic>?;

        List<TournamentRoundConfig>? parsedLevels;
        if (map['levels'] is List) {
          final lvlList = map['levels'] as List;
          parsedLevels = lvlList.map((lvl) {
            final lMap = lvl as Map<String, dynamic>;
            final rNum = (lMap['level'] as num?)?.toInt() ?? 1;
            final rCoins = (lMap['reward_coins'] as num?)?.toInt() ?? 0;
            final rDiamonds = (lMap['reward_diamonds'] as num?)?.toInt();
            const playersTable = [64, 32, 16, 8, 4, 2];
            final playersRem = playersTable[(rNum - 1).clamp(0, 5)];
            return TournamentRoundConfig(
              roundNumber: rNum,
              rewardGold: rCoins,
              bonusGold: (rDiamonds != null && rDiamonds > 0) ? rDiamonds : null,
              playersRemaining: playersRem,
              subtitle: rNum >= 6 ? '25% of prize pool for the winner!' : null,
            );
          }).toList();
        }

        TournamentCardStatus status = TournamentCardStatus.available;
        int? userCurrentLevel;

        if (userPart != null && userPart['is_active'] == true) {
          status = TournamentCardStatus.inProgress;
          userCurrentLevel = (userPart['current_level'] as num?)?.toInt();
        } else if (activeRun != null && activeRun.tournamentId == id) {
          status = TournamentCardStatus.inProgress;
          userCurrentLevel = activeRun.currentRound;
        }

        return TournamentCardModel(
          id: id,
          title: name,
          mode: mode,
          prizeGold: prizePool,
          currentRound: userCurrentLevel,
          status: status,
          entryFeeGold: entryFee,
          unlockLevel: unlockLevel,
          participantCount: participantCount,
          levels: parsedLevels,
        );
      }).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> joinTournamentApi(dynamic tournamentId) async {
    final res = await _apiClient.post(ApiEndpoints.tournamentJoin(tournamentId));
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> continueMatchApi(dynamic tournamentId) async {
    final res = await _apiClient.post(ApiEndpoints.tournamentContinue(tournamentId));
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> leaveQueueApi(dynamic tournamentId) async {
    final res = await _apiClient.post(ApiEndpoints.tournamentLeave(tournamentId));
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> claimPrizeApi(dynamic tournamentId) async {
    final res = await _apiClient.post(ApiEndpoints.tournamentClaim(tournamentId));
    return (res as Map<String, dynamic>?) ?? {'status': 'success'};
  }

  @override
  Future<Map<String, dynamic>?> getProgressApi(dynamic tournamentId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.tournamentProgress(tournamentId));
      return res as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
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
    dynamic tournamentId,
    List<TournamentRoundConfig>? customLevels,
  }) async {
    final roundConfigs = (customLevels != null && customLevels.isNotEmpty)
        ? customLevels
        : (mode == TournamentMode.classic
            ? TournamentConfig.defaultRounds
            : TournamentConfig.quickRounds);

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
    try {
      final response = await _apiClient.get(ApiEndpoints.tournamentHistory);
      if (response != null && response['status'] == 'success' && response['data'] is List) {
        final List raw = response['data'] as List;
        final items = raw
            .map((e) => TournamentHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();

        final prefs = await _getPrefs();
        await prefs.setString(
          _keyHistoryList,
          jsonEncode(items.map((e) => e.toJson()).toList()),
        );

        return items;
      }
    } catch (_) {}

    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyHistoryList);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
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
