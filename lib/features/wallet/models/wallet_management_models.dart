enum CurrencyMode { pkr, usd }

enum PaymentMethodType { jazzcash, easypaisa, bank }

enum TransactionType {
  deposit,
  withdraw,
  moneyToCoins,
  coinsToMoney,
  matchWin,
  entryFee,
}

enum TransactionStatus {
  completed,
  pending,
  failed,
}

class UserPaymentAccount {
  final String id;
  final PaymentMethodType type;
  final String accountTitle;
  final String accountNumber;
  final String? bankName;
  final String? iban;
  final bool isDefault;

  UserPaymentAccount({
    required this.id,
    required this.type,
    required this.accountTitle,
    required this.accountNumber,
    this.bankName,
    this.iban,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'accountTitle': accountTitle,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'iban': iban,
        'isDefault': isDefault,
      };

  factory UserPaymentAccount.fromJson(Map<String, dynamic> json) =>
      UserPaymentAccount(
        id: json['id'] ?? '',
        type: PaymentMethodType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PaymentMethodType.jazzcash,
        ),
        accountTitle: json['accountTitle'] ?? '',
        accountNumber: json['accountNumber'] ?? '',
        bankName: json['bankName'],
        iban: json['iban'],
        isDefault: json['isDefault'] ?? false,
      );

  UserPaymentAccount copyWith({
    String? id,
    PaymentMethodType? type,
    String? accountTitle,
    String? accountNumber,
    String? bankName,
    String? iban,
    bool? isDefault,
  }) {
    return UserPaymentAccount(
      id: id ?? this.id,
      type: type ?? this.type,
      accountTitle: accountTitle ?? this.accountTitle,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      iban: iban ?? this.iban,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class WalletRecord {
  final String id;
  final TransactionType type;
  final double amountMoney; // in PKR or USD
  final CurrencyMode currency;
  final int coinsDelta;
  final int diamondsDelta;
  final PaymentMethodType? method;
  final String? referenceId;
  final DateTime timestamp;
  final TransactionStatus status;
  final String description;

  WalletRecord({
    required this.id,
    required this.type,
    required this.amountMoney,
    required this.currency,
    required this.coinsDelta,
    this.diamondsDelta = 0,
    this.method,
    this.referenceId,
    required this.timestamp,
    required this.status,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amountMoney': amountMoney,
        'currency': currency.name,
        'coinsDelta': coinsDelta,
        'diamondsDelta': diamondsDelta,
        'method': method?.name,
        'referenceId': referenceId,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'description': description,
      };

  factory WalletRecord.fromJson(Map<String, dynamic> json) => WalletRecord(
        id: json['id'] ?? '',
        type: TransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TransactionType.deposit,
        ),
        amountMoney: (json['amountMoney'] as num?)?.toDouble() ?? 0.0,
        currency: CurrencyMode.values.firstWhere(
          (e) => e.name == json['currency'],
          orElse: () => CurrencyMode.pkr,
        ),
        coinsDelta: json['coinsDelta'] ?? 0,
        diamondsDelta: json['diamondsDelta'] ?? 0,
        method: json['method'] != null
            ? PaymentMethodType.values.firstWhere(
                (e) => e.name == json['method'],
                orElse: () => PaymentMethodType.jazzcash,
              )
            : null,
        referenceId: json['referenceId'],
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.completed,
        ),
        description: json['description'] ?? '',
      );
}
