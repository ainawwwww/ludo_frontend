import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient: apiClient);
});

final walletBalanceProvider = FutureProvider.autoDispose<WalletBalanceModel>((ref) async {
  final walletRepository = ref.watch(walletRepositoryProvider);
  return await walletRepository.getBalance();
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final walletRepository = ref.watch(walletRepositoryProvider);
  return await walletRepository.getTransactions();
});

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<WalletBalanceModel> getBalance() async {
    final response = await _apiClient.get(ApiEndpoints.walletBalance);
    return WalletBalanceModel.fromJson(response);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiClient.get(ApiEndpoints.walletTransactions);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((t) => TransactionModel.fromJson(t as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<WalletBalanceModel> topup({
    required int amount,
    String currencyType = 'coins',
    String paymentMethod = 'test',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.walletTopup,
      data: {
        'amount': amount,
        'currency_type': currencyType,
        'payment_method': paymentMethod,
      },
    );
    return WalletBalanceModel.fromJson(response);
  }
}
