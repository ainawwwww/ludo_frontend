import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_management_models.dart';

class WalletManagementState {
  final CurrencyMode currencyMode;
  final int coins;
  final int diamonds;
  final List<UserPaymentAccount> paymentAccounts;
  final List<WalletRecord> transactions;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const WalletManagementState({
    this.currencyMode = CurrencyMode.pkr,
    this.coins = 35000,
    this.diamonds = 120,
    this.paymentAccounts = const [],
    this.transactions = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  // Rates: 100 Coins = 1 PKR, 28,000 Coins = 1 USD (1 USD = 280 PKR)
  static const double coinsPerPkr = 100.0;
  static const double pkrPerUsd = 280.0;
  static const double coinsPerUsd = 28000.0;

  double get estimatedMoneyValue {
    if (currencyMode == CurrencyMode.pkr) {
      return coins / coinsPerPkr;
    } else {
      return coins / coinsPerUsd;
    }
  }

  String get currencySymbol => currencyMode == CurrencyMode.pkr ? 'Rs' : '\$';
  String get currencyCode => currencyMode == CurrencyMode.pkr ? 'PKR' : 'USD';

  WalletManagementState copyWith({
    CurrencyMode? currencyMode,
    int? coins,
    int? diamonds,
    List<UserPaymentAccount>? paymentAccounts,
    List<WalletRecord>? transactions,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return WalletManagementState(
      currencyMode: currencyMode ?? this.currencyMode,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      paymentAccounts: paymentAccounts ?? this.paymentAccounts,
      transactions: transactions ?? this.transactions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

final walletManagementProvider = StateNotifierProvider<
    WalletManagementNotifier, WalletManagementState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return WalletManagementNotifier(ref, storageService);
});

class WalletManagementNotifier extends StateNotifier<WalletManagementState> {
  final Ref _ref;
  final StorageService _storageService;

  static const String _accountsStorageKey = 'wallet_user_accounts_v1';
  static const String _transactionsStorageKey = 'wallet_user_transactions_v1';

  WalletManagementNotifier(this._ref, this._storageService)
      : super(const WalletManagementState()) {
    _init();
  }

  Future<void> _init() async {
    final authUser = _ref.read(authProvider).user;
    final initialCoins = authUser?.coins ?? 35000;
    final initialDiamonds = authUser?.diamonds ?? 120;

    List<UserPaymentAccount> loadedAccounts = _getDefaultAccounts();
    List<WalletRecord> loadedTransactions = _getDefaultTransactions();

    try {
      await _storageService.init();
      final savedAccountsRaw =
          await _storageService.getString(_accountsStorageKey);
      if (savedAccountsRaw != null && savedAccountsRaw.isNotEmpty) {
        final decoded = jsonDecode(savedAccountsRaw) as List;
        loadedAccounts = decoded
            .map((item) =>
                UserPaymentAccount.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      final savedTxRaw =
          await _storageService.getString(_transactionsStorageKey);
      if (savedTxRaw != null && savedTxRaw.isNotEmpty) {
        final decoded = jsonDecode(savedTxRaw) as List;
        loadedTransactions = decoded
            .map(
                (item) => WalletRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    state = state.copyWith(
      coins: initialCoins,
      diamonds: initialDiamonds,
      paymentAccounts: loadedAccounts,
      transactions: loadedTransactions,
    );
  }

  void switchCurrency(CurrencyMode mode) {
    state = state.copyWith(currencyMode: mode, clearMessages: true);
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }

  // --- Payment Accounts ---
  Future<void> savePaymentAccount(UserPaymentAccount account) async {
    final existingIndex =
        state.paymentAccounts.indexWhere((a) => a.id == account.id);
    List<UserPaymentAccount> updated;

    if (existingIndex >= 0) {
      updated = List.from(state.paymentAccounts);
      updated[existingIndex] = account;
    } else {
      updated = [...state.paymentAccounts, account];
    }

    state = state.copyWith(
      paymentAccounts: updated,
      successMessage: '${_getMethodName(account.type)} details saved!',
    );
    _persistAccounts(updated);
  }

  Future<void> deletePaymentAccount(String id) async {
    final updated = state.paymentAccounts.where((a) => a.id != id).toList();
    state = state.copyWith(
      paymentAccounts: updated,
      successMessage: 'Account removed successfully',
    );
    _persistAccounts(updated);
  }

  // --- Deposit Flow ---
  Future<bool> submitDeposit({
    required double moneyAmount,
    required CurrencyMode currency,
    required PaymentMethodType method,
    required String senderAccount,
    required String transactionId,
  }) async {
    if (moneyAmount <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid amount');
      return false;
    }
    if (transactionId.trim().isEmpty) {
      state = state.copyWith(
          errorMessage: 'Transaction ID / Reference is required');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessages: true);

    // Simulate network verification
    await Future.delayed(const Duration(milliseconds: 900));

    // Calculate coins added
    final coinsToAdd = currency == CurrencyMode.pkr
        ? (moneyAmount * WalletManagementState.coinsPerPkr).round()
        : (moneyAmount * WalletManagementState.coinsPerUsd).round();

    final newRecord = WalletRecord(
      id: 'DEP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      type: TransactionType.deposit,
      amountMoney: moneyAmount,
      currency: currency,
      coinsDelta: coinsToAdd,
      method: method,
      referenceId: transactionId.trim().toUpperCase(),
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      description: 'Deposit via ${_getMethodName(method)}',
    );

    final updatedCoins = state.coins + coinsToAdd;
    final updatedTxs = [newRecord, ...state.transactions];

    state = state.copyWith(
      coins: updatedCoins,
      transactions: updatedTxs,
      isSubmitting: false,
      successMessage:
          'Deposit of ${currency == CurrencyMode.pkr ? "Rs" : "\$"}${moneyAmount.toStringAsFixed(0)} verified! +${coinsToAdd.toString()} Coins credited.',
    );

    _persistTransactions(updatedTxs);
    return true;
  }

  // --- Withdrawal Flow ---
  Future<bool> submitWithdrawal({
    required int coinsToWithdraw,
    required UserPaymentAccount destinationAccount,
  }) async {
    if (coinsToWithdraw < 10000) {
      state = state.copyWith(
          errorMessage: 'Minimum withdrawal is 10,000 Coins (Rs 100)');
      return false;
    }
    if (coinsToWithdraw > state.coins) {
      state = state.copyWith(
          errorMessage: 'Insufficient coins balance in wallet');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessages: true);
    await Future.delayed(const Duration(milliseconds: 900));

    final moneyPkr = coinsToWithdraw / WalletManagementState.coinsPerPkr;
    final moneyValue = state.currencyMode == CurrencyMode.pkr
        ? moneyPkr
        : moneyPkr / WalletManagementState.pkrPerUsd;

    final newRecord = WalletRecord(
      id: 'WTH-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      type: TransactionType.withdraw,
      amountMoney: moneyValue,
      currency: state.currencyMode,
      coinsDelta: -coinsToWithdraw,
      method: destinationAccount.type,
      referenceId: destinationAccount.accountNumber,
      timestamp: DateTime.now(),
      status: TransactionStatus.pending,
      description:
          'Payout to ${_getMethodName(destinationAccount.type)} (${destinationAccount.accountNumber})',
    );

    final updatedCoins = state.coins - coinsToWithdraw;
    final updatedTxs = [newRecord, ...state.transactions];

    state = state.copyWith(
      coins: updatedCoins,
      transactions: updatedTxs,
      isSubmitting: false,
      successMessage:
          'Withdrawal request for ${state.currencySymbol}${moneyValue.toStringAsFixed(1)} submitted! Status: Pending review.',
    );

    _persistTransactions(updatedTxs);
    return true;
  }

  // --- Converters ---
  Future<bool> convertMoneyToCoins({
    required double moneyAmount,
    required CurrencyMode currency,
  }) async {
    if (moneyAmount <= 0) return false;
    state = state.copyWith(isSubmitting: true, clearMessages: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final coinsToAdd = currency == CurrencyMode.pkr
        ? (moneyAmount * WalletManagementState.coinsPerPkr).round()
        : (moneyAmount * WalletManagementState.coinsPerUsd).round();

    final newRecord = WalletRecord(
      id: 'CNV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      type: TransactionType.moneyToCoins,
      amountMoney: moneyAmount,
      currency: currency,
      coinsDelta: coinsToAdd,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      description:
          'Exchanged ${currency == CurrencyMode.pkr ? "Rs" : "\$"}${moneyAmount.toStringAsFixed(0)} to Coins',
    );

    final updatedCoins = state.coins + coinsToAdd;
    final updatedTxs = [newRecord, ...state.transactions];

    state = state.copyWith(
      coins: updatedCoins,
      transactions: updatedTxs,
      isSubmitting: false,
      successMessage: 'Successfully converted to +$coinsToAdd Coins!',
    );

    _persistTransactions(updatedTxs);
    return true;
  }

  Future<bool> convertCoinsToMoney({
    required int coinsAmount,
    required CurrencyMode currency,
  }) async {
    if (coinsAmount <= 0) return false;
    if (coinsAmount > state.coins) {
      state = state.copyWith(errorMessage: 'Not enough coins to convert');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearMessages: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final moneyEarned = currency == CurrencyMode.pkr
        ? coinsAmount / WalletManagementState.coinsPerPkr
        : coinsAmount / WalletManagementState.coinsPerUsd;

    final newRecord = WalletRecord(
      id: 'CNV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      type: TransactionType.coinsToMoney,
      amountMoney: moneyEarned,
      currency: currency,
      coinsDelta: -coinsAmount,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      description:
          'Converted $coinsAmount Coins to ${currency == CurrencyMode.pkr ? "Rs" : "\$"}${moneyEarned.toStringAsFixed(1)} Cash Credit',
    );

    final updatedCoins = state.coins - coinsAmount;
    final updatedTxs = [newRecord, ...state.transactions];

    state = state.copyWith(
      coins: updatedCoins,
      transactions: updatedTxs,
      isSubmitting: false,
      successMessage:
          'Successfully converted $coinsAmount Coins into ${currency == CurrencyMode.pkr ? "Rs" : "\$"}${moneyEarned.toStringAsFixed(1)} cash credit!',
    );

    _persistTransactions(updatedTxs);
    return true;
  }

  String _getMethodName(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.jazzcash:
        return 'JazzCash';
      case PaymentMethodType.easypaisa:
        return 'EasyPaisa';
      case PaymentMethodType.bank:
        return 'Bank Transfer';
    }
  }

  void _persistAccounts(List<UserPaymentAccount> list) {
    try {
      final jsonStr = jsonEncode(list.map((a) => a.toJson()).toList());
      _storageService.setString(_accountsStorageKey, jsonStr);
    } catch (_) {}
  }

  void _persistTransactions(List<WalletRecord> list) {
    try {
      final jsonStr = jsonEncode(list.map((t) => t.toJson()).toList());
      _storageService.setString(_transactionsStorageKey, jsonStr);
    } catch (_) {}
  }

  List<UserPaymentAccount> _getDefaultAccounts() {
    return [
      UserPaymentAccount(
        id: 'acc_jc_1',
        type: PaymentMethodType.jazzcash,
        accountTitle: 'Muhammad Ali',
        accountNumber: '0302-9876543',
        isDefault: true,
      ),
      UserPaymentAccount(
        id: 'acc_ep_1',
        type: PaymentMethodType.easypaisa,
        accountTitle: 'Muhammad Ali',
        accountNumber: '0345-1239876',
        isDefault: false,
      ),
      UserPaymentAccount(
        id: 'acc_bnk_1',
        type: PaymentMethodType.bank,
        accountTitle: 'Muhammad Ali',
        bankName: 'Meezan Bank Ltd',
        accountNumber: '010203040506',
        iban: 'PK12MEZN0001020304050601',
        isDefault: false,
      ),
    ];
  }

  List<WalletRecord> _getDefaultTransactions() {
    final now = DateTime.now();
    return [
      WalletRecord(
        id: 'TXN-98214',
        type: TransactionType.deposit,
        amountMoney: 1000.0,
        currency: CurrencyMode.pkr,
        coinsDelta: 100000,
        method: PaymentMethodType.jazzcash,
        referenceId: 'JC-88392019',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: TransactionStatus.completed,
        description: 'Deposit via JazzCash verified',
      ),
      WalletRecord(
        id: 'TXN-76123',
        type: TransactionType.matchWin,
        amountMoney: 150.0,
        currency: CurrencyMode.pkr,
        coinsDelta: 15000,
        timestamp: now.subtract(const Duration(hours: 18)),
        status: TransactionStatus.completed,
        description: 'Tournament Semi-Final Victory Prize',
      ),
      WalletRecord(
        id: 'TXN-54901',
        type: TransactionType.withdraw,
        amountMoney: 500.0,
        currency: CurrencyMode.pkr,
        coinsDelta: -50000,
        method: PaymentMethodType.easypaisa,
        referenceId: '0345-1239876',
        timestamp: now.subtract(const Duration(days: 2)),
        status: TransactionStatus.completed,
        description: 'Withdrawal payout to EasyPaisa',
      ),
      WalletRecord(
        id: 'TXN-32104',
        type: TransactionType.moneyToCoins,
        amountMoney: 300.0,
        currency: CurrencyMode.pkr,
        coinsDelta: 30000,
        timestamp: now.subtract(const Duration(days: 3)),
        status: TransactionStatus.completed,
        description: 'Money to Coin Converter',
      ),
    ];
  }
}
