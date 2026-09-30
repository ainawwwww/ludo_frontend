class DailyTaskModel {
  final int id;
  final String taskKey;
  final String title;
  final String rewardType;
  final int rewardAmount;
  final int currentProgress;
  final int totalProgress;
  final bool isClaimed;

  DailyTaskModel({
    required this.id,
    required this.taskKey,
    required this.title,
    required this.rewardType,
    required this.rewardAmount,
    required this.currentProgress,
    required this.totalProgress,
    required this.isClaimed,
  });

  bool get isCompleted => currentProgress >= totalProgress;

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      taskKey: json['task_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      rewardType: json['reward_type']?.toString() ?? 'coins',
      rewardAmount: json['reward_amount'] is int
          ? json['reward_amount'] as int
          : int.tryParse(json['reward_amount']?.toString() ?? '0') ?? 0,
      currentProgress: json['current_progress'] is int
          ? json['current_progress'] as int
          : int.tryParse(json['current_progress']?.toString() ?? '0') ?? 0,
      totalProgress: json['total_progress'] is int
          ? json['total_progress'] as int
          : int.tryParse(json['total_progress']?.toString() ?? '1') ?? 1,
      isClaimed: json['is_claimed'] == true || json['is_claimed'] == 1 || json['is_claimed'] == '1',
    );
  }

  DailyTaskModel copyWith({
    int? currentProgress,
    bool? isClaimed,
  }) {
    return DailyTaskModel(
      id: id,
      taskKey: taskKey,
      title: title,
      rewardType: rewardType,
      rewardAmount: rewardAmount,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class ArrivalChestModel {
  final bool isReady;
  final String? lastClaimedAt;
  final String? nextAvailableAt;
  final int secondsRemaining;
  final int baseCoins;
  final int baseDiamonds;
  final bool isVip;

  ArrivalChestModel({
    required this.isReady,
    this.lastClaimedAt,
    this.nextAvailableAt,
    required this.secondsRemaining,
    required this.baseCoins,
    required this.baseDiamonds,
    required this.isVip,
  });

  factory ArrivalChestModel.fromJson(Map<String, dynamic> json) {
    return ArrivalChestModel(
      isReady: json['is_ready'] == true,
      lastClaimedAt: json['last_claimed_at']?.toString(),
      nextAvailableAt: json['next_available_at']?.toString(),
      secondsRemaining: json['seconds_remaining'] is int
          ? json['seconds_remaining'] as int
          : int.tryParse(json['seconds_remaining']?.toString() ?? '0') ?? 0,
      baseCoins: json['base_coins'] is int
          ? json['base_coins'] as int
          : int.tryParse(json['base_coins']?.toString() ?? '1000') ?? 1000,
      baseDiamonds: json['base_diamonds'] is int
          ? json['base_diamonds'] as int
          : int.tryParse(json['base_diamonds']?.toString() ?? '5') ?? 5,
      isVip: json['is_vip'] == true,
    );
  }
}
