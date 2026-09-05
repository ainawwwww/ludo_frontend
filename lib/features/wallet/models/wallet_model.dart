class WalletBalanceModel {
  final int coins;
  final int diamonds;

  WalletBalanceModel({
    required this.coins,
    required this.diamonds,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    final data =
        json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    return WalletBalanceModel(
      coins: data['coins'] is int
          ? data['coins']
          : int.tryParse(data['coins'].toString()) ?? 0,
      diamonds: data['diamonds'] is int
          ? data['diamonds']
          : int.tryParse(data['diamonds'].toString()) ?? 0,
    );
  }
}

class TransactionModel {
  final String type; // win, loss, purchase, topup, gift, entry_fee
  final String currencyType; // coins, diamonds
  final int amount;
  final String? referenceId;
  final String createdAt;

  TransactionModel({
    required this.type,
    required this.currencyType,
    required this.amount,
    this.referenceId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      type: json['type']?.toString() ?? 'other',
      currencyType: json['currency_type']?.toString() ?? 'coins',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount'].toString()) ?? 0,
      referenceId: json['reference_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
