import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/subscription/models/subscription_models.dart';
import 'package:ludo_vibe/features/subscription/repositories/api_subscription_repository.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(apiSubscriptionRepositoryProvider));
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._repository) : super(SubscriptionState()) {
    fetchCurrentSubscription();
  }

  final ApiSubscriptionRepository _repository;

  Future<void> fetchCurrentSubscription() async {
    state = state.copyWith(status: SubscriptionStateStatus.loading, clearFailure: true);
    try {
      final plans = await _repository.fetchPlans();
      final current = await _repository.fetchCurrentSubscription();

      state = state.copyWith(
        status: SubscriptionStateStatus.success,
        plans: plans,
        currentSubscription: current,
        clearSubscription: current == null,
      );
    } catch (e) {
      final failure = e is SubscriptionFailure ? e : UnknownSubscriptionFailure(e.toString());
      state = state.copyWith(
        status: SubscriptionStateStatus.error,
        failure: failure,
      );
    }
  }

  Future<bool> checkout({
    required String tier,
    bool forceFailure = false,
  }) async {
    state = state.copyWith(
      isCheckoutLoading: true,
      clearFailure: true,
      clearSuccessMessage: true,
    );

    try {
      final updated = await _repository.checkout(tier: tier, forceFailure: forceFailure);
      state = state.copyWith(
        isCheckoutLoading: false,
        currentSubscription: updated,
        actionSuccessMessage: 'VIP Pass activated successfully!',
        status: SubscriptionStateStatus.success,
      );
      return true;
    } catch (e) {
      final failure = e is SubscriptionFailure ? e : UnknownSubscriptionFailure(e.toString());
      state = state.copyWith(
        isCheckoutLoading: false,
        failure: failure,
        status: SubscriptionStateStatus.error,
      );
      return false;
    }
  }

  Future<bool> cancel() async {
    state = state.copyWith(
      isCancelLoading: true,
      clearFailure: true,
      clearSuccessMessage: true,
    );

    try {
      final updated = await _repository.cancel();
      state = state.copyWith(
        isCancelLoading: false,
        currentSubscription: updated,
        actionSuccessMessage: 'Subscription cancelled. Pass remains active until current period end.',
        status: SubscriptionStateStatus.success,
      );
      return true;
    } catch (e) {
      final failure = e is SubscriptionFailure ? e : UnknownSubscriptionFailure(e.toString());
      state = state.copyWith(
        isCancelLoading: false,
        failure: failure,
        status: SubscriptionStateStatus.error,
      );
      return false;
    }
  }

  Future<bool> claimDailyReward() async {
    state = state.copyWith(
      isClaimLoading: true,
      clearFailure: true,
      clearSuccessMessage: true,
    );

    try {
      final reward = await _repository.claimDailyReward();
      final coins = reward['coins_claimed'] ?? 0;
      final diamonds = reward['diamonds_claimed'] ?? 0;

      // Update current subscription local state so canClaimDailyReward becomes false
      final current = state.currentSubscription;
      SubscriptionDto? updated;
      if (current != null) {
        updated = SubscriptionDto(
          tier: current.tier,
          status: current.status,
          startedAt: current.startedAt,
          currentPeriodEnd: current.currentPeriodEnd,
          cancelledAt: current.cancelledAt,
          autoRenew: current.autoRenew,
          canClaimDailyReward: false,
        );
      }

      state = state.copyWith(
        isClaimLoading: false,
        currentSubscription: updated,
        actionSuccessMessage: 'Claimed $coins Gold Coins & $diamonds Diamonds!',
        status: SubscriptionStateStatus.success,
      );
      return true;
    } catch (e) {
      final failure = e is SubscriptionFailure ? e : UnknownSubscriptionFailure(e.toString());
      state = state.copyWith(
        isClaimLoading: false,
        failure: failure,
        status: SubscriptionStateStatus.error,
      );
      return false;
    }
  }

  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }
}
