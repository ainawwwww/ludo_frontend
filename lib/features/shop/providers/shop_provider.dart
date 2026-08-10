import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/shop/models/store_item_model.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShopRepository(apiClient: apiClient);
});

final storeItemsProvider = FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getStoreItems();
});

final userInventoryProvider = FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getInventory();
});

class ShopRepository {
  final ApiClient _apiClient;

  ShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StoreItemModel>> getStoreItems() async {
    final response = await _apiClient.get(ApiEndpoints.storeItems);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((item) => StoreItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<StoreItemModel>> getInventory() async {
    final response = await _apiClient.get(ApiEndpoints.storeInventory);
    final data = response is Map<String, dynamic> && response.containsKey('data') ? response['data'] : response;
    
    if (data is List) {
      return data.map((item) => StoreItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> purchaseItem(int itemId) async {
    final response = await _apiClient.post(
      ApiEndpoints.storePurchase,
      data: {'item_id': itemId},
    );
    return response != null;
  }
}
