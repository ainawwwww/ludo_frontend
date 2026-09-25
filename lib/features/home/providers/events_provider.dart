import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/home/models/event_model.dart';
import 'package:ludo_vibe/features/profile/providers/profile_provider.dart';
import 'package:ludo_vibe/features/wallet/providers/wallet_provider.dart';

class EventsState {
  final List<DailyTaskModel> dailyTasks;
  final ArrivalChestModel? arrivalChest;
  final bool isLoading;
  final int? claimingTaskId;
  final bool isClaimingChest;
  final String? error;
  final String? successMessage;

  const EventsState({
    this.dailyTasks = const [],
    this.arrivalChest,
    this.isLoading = false,
    this.claimingTaskId,
    this.isClaimingChest = false,
    this.error,
    this.successMessage,
  });

  EventsState copyWith({
    List<DailyTaskModel>? dailyTasks,
    ArrivalChestModel? arrivalChest,
    bool? isLoading,
    int? claimingTaskId,
    bool? isClaimingChest,
    String? error,
    String? successMessage,
  }) {
    return EventsState(
      dailyTasks: dailyTasks ?? this.dailyTasks,
      arrivalChest: arrivalChest ?? this.arrivalChest,
      isLoading: isLoading ?? this.isLoading,
      claimingTaskId: claimingTaskId,
      isClaimingChest: isClaimingChest ?? this.isClaimingChest,
      error: error,
      successMessage: successMessage,
    );
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsRepository(apiClient: apiClient);
});

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(repository, ref);
});

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository _repository;
  final Ref _ref;

  EventsNotifier(this._repository, this._ref) : super(const EventsState()) {
    fetchEventsData();
  }

  Future<void> fetchEventsData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getDailyTasks();
      final chest = await _repository.getArrivalChest();
      state = state.copyWith(
        dailyTasks: tasks,
        arrivalChest: chest,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> claimDailyTask(int taskId) async {
    state = state.copyWith(claimingTaskId: taskId, error: null, successMessage: null);
    try {
      final requestId = 'task_${taskId}_${DateTime.now().millisecondsSinceEpoch}';
      final response = await _repository.claimDailyTask(taskId, requestId);

      if (response != null && response['status'] == 'success') {
        // Update task state locally
        final updatedTasks = state.dailyTasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(isClaimed: true);
          }
          return t;
        }).toList();

        // Refresh wallet balance provider, profile provider and auth user state (for XP & Level)
        _ref.invalidate(walletBalanceProvider);
        _ref.read(profileProvider.notifier).fetchProfile();
        _ref.read(authProvider.notifier).checkAuthStatus();

        final rewardAmount = response['data']?['reward_amount'] ?? 0;
        final rewardType = response['data']?['reward_type'] ?? 'coins';

        state = state.copyWith(
          dailyTasks: updatedTasks,
          claimingTaskId: null,
          successMessage: 'Claimed +$rewardAmount $rewardType!',
        );
        return true;
      } else {
        state = state.copyWith(
          claimingTaskId: null,
          error: response?['message'] ?? 'Could not claim task reward.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(claimingTaskId: null, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(claimingTaskId: null, error: 'Claim failed.');
      return false;
    }
  }

  Future<bool> claimArrivalChest() async {
    state = state.copyWith(isClaimingChest: true, error: null, successMessage: null);
    try {
      final requestId = 'chest_${DateTime.now().millisecondsSinceEpoch}';
      final response = await _repository.claimArrivalChest(requestId);

      if (response != null && response['status'] == 'success') {
        // Refresh chest status & wallet
        final chest = await _repository.getArrivalChest();
        _ref.invalidate(walletBalanceProvider);

        final coins = response['data']?['reward_coins'] ?? 1000;
        final diamonds = response['data']?['reward_diamonds'] ?? 5;

        state = state.copyWith(
          arrivalChest: chest,
          isClaimingChest: false,
          successMessage: 'Chest Opened! Received +$coins Coins & +$diamonds Diamonds!',
        );
        return true;
      } else {
        state = state.copyWith(
          isClaimingChest: false,
          error: response?['message'] ?? 'Could not claim arrival chest.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(isClaimingChest: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isClaimingChest: false, error: 'Chest claim failed.');
      return false;
    }
  }
}

class EventsRepository {
  final ApiClient _apiClient;

  EventsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<DailyTaskModel>> getDailyTasks() async {
    final response = await _apiClient.get(ApiEndpoints.dailyTasks);
    if (response is Map<String, dynamic> && response['data']?['tasks'] is List) {
      final list = response['data']['tasks'] as List;
      return list.map((json) => DailyTaskModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<dynamic> claimDailyTask(int taskId, String requestId) async {
    return await _apiClient.post(
      ApiEndpoints.claimDailyTask(taskId),
      data: {'request_id': requestId},
    );
  }

  Future<ArrivalChestModel?> getArrivalChest() async {
    final response = await _apiClient.get(ApiEndpoints.arrivalChest);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return ArrivalChestModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<dynamic> claimArrivalChest(String requestId) async {
    return await _apiClient.post(
      ApiEndpoints.claimArrivalChest,
      data: {'request_id': requestId},
    );
  }
}
