class SubscriptionPlanDto {
  final String tier;
  final String title;
  final double price;
  final String currency;
  final int dailyCoins;
  final int dailyDiamonds;

  SubscriptionPlanDto({
    required this.tier,
    required this.title,
    required this.price,
    required this.currency,
    required this.dailyCoins,
    required this.dailyDiamonds,
  });

  factory SubscriptionPlanDto.fromJson(Map<String, dynamic> json) {
    final rewards = json['daily_rewards'] as Map<String, dynamic>? ?? {};
    return SubscriptionPlanDto(
      tier: json['tier'] as String? ?? 'knight',
      title: json['title'] as String? ?? 'PASS',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      dailyCoins: (rewards['coins'] as num?)?.toInt() ?? 0,
      dailyDiamonds: (rewards['diamonds'] as num?)?.toInt() ?? 0,
    );
  }
}

enum SubscriptionTier {
  knight('knight', 'KNIGHT PASS', 4.99, 200, 5),
  baron('baron', 'BARON PASS', 14.99, 500, 15);

  final String value;
  final String title;
  final double price;
  final int dailyCoins;
  final int dailyDiamonds;

  const SubscriptionTier(
    this.value,
    this.title,
    this.price,
    this.dailyCoins,
    this.dailyDiamonds,
  );

  static SubscriptionTier fromString(String val) {
    return SubscriptionTier.values.firstWhere(
      (t) => t.value.toLowerCase() == val.toLowerCase(),
      orElse: () => SubscriptionTier.knight,
    );
  }
}

class SubscriptionDto {
  final String tier;
  final String status;
  final DateTime? startedAt;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelledAt;
  final bool autoRenew;
  final bool canClaimDailyReward;

  SubscriptionDto({
    required this.tier,
    required this.status,
    this.startedAt,
    this.currentPeriodEnd,
    this.cancelledAt,
    required this.autoRenew,
    required this.canClaimDailyReward,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionDto(
      tier: json['tier'] as String? ?? 'knight',
      status: json['status'] as String? ?? 'active',
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
      currentPeriodEnd: json['current_period_end'] != null ? DateTime.tryParse(json['current_period_end'].toString()) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.tryParse(json['cancelled_at'].toString()) : null,
      autoRenew: json['auto_renew'] as bool? ?? true,
      canClaimDailyReward: json['can_claim_daily_reward'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'active' || status == 'cancelled';
  SubscriptionTier get tierEnum => SubscriptionTier.fromString(tier);
}

sealed class SubscriptionFailure {
  final String message;
  const SubscriptionFailure(this.message);
}

class AlreadySubscribedFailure extends SubscriptionFailure {
  const AlreadySubscribedFailure([super.message = 'You already have an active VIP subscription.']);
}

class PaymentFailedFailure extends SubscriptionFailure {
  const PaymentFailedFailure([super.message = 'Payment was declined. Please try again.']);
}

class NoActiveSubscriptionFailure extends SubscriptionFailure {
  const NoActiveSubscriptionFailure([super.message = 'No active VIP subscription found.']);
}

class RewardAlreadyClaimedFailure extends SubscriptionFailure {
  const RewardAlreadyClaimedFailure([super.message = 'Daily reward already claimed today.']);
}

class NetworkSubscriptionFailure extends SubscriptionFailure {
  const NetworkSubscriptionFailure([super.message = 'Network error. Please check your connection.']);
}

class UnknownSubscriptionFailure extends SubscriptionFailure {
  const UnknownSubscriptionFailure([super.message = 'An unexpected error occurred.']);
}

enum SubscriptionStateStatus { initial, loading, success, error }

class SubscriptionState {
  final SubscriptionStateStatus status;
  final SubscriptionDto? currentSubscription;
  final List<SubscriptionPlanDto> plans;
  final SubscriptionFailure? failure;
  final bool isCheckoutLoading;
  final bool isClaimLoading;
  final bool isCancelLoading;
  final String? actionSuccessMessage;

  SubscriptionState({
    this.status = SubscriptionStateStatus.initial,
    this.currentSubscription,
    this.plans = const [],
    this.failure,
    this.isCheckoutLoading = false,
    this.isClaimLoading = false,
    this.isCancelLoading = false,
    this.actionSuccessMessage,
  });

  SubscriptionState copyWith({
    SubscriptionStateStatus? status,
    SubscriptionDto? currentSubscription,
    bool clearSubscription = false,
    List<SubscriptionPlanDto>? plans,
    SubscriptionFailure? failure,
    bool clearFailure = false,
    bool? isCheckoutLoading,
    bool? isClaimLoading,
    bool? isCancelLoading,
    String? actionSuccessMessage,
    bool clearSuccessMessage = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      currentSubscription: clearSubscription
          ? null
          : (currentSubscription ?? this.currentSubscription),
      plans: plans ?? this.plans,
      failure: clearFailure ? null : (failure ?? this.failure),
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      isClaimLoading: isClaimLoading ?? this.isClaimLoading,
      isCancelLoading: isCancelLoading ?? this.isCancelLoading,
      actionSuccessMessage: clearSuccessMessage
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }
}
