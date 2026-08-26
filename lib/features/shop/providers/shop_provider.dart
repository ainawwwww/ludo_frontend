import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/models/store_item_model.dart';

class ShopState {
  final List<ShopItem> items;
  final ShopCategory selectedCategory;
  final ThemeType selectedThemeType;
  final StickerType selectedStickerType;
  final String? lastPurchasedId;
  final String? lastEquippedId;
  final int userCoins;
  final int userDiamonds;

  const ShopState({
    required this.items,
    this.selectedCategory = ShopCategory.all,
    this.selectedThemeType = ThemeType.basic,
    this.selectedStickerType = StickerType.pack,
    this.lastPurchasedId,
    this.lastEquippedId,
    this.userCoins = 50000,
    this.userDiamonds = 1200,
  });

  ShopState copyWith({
    List<ShopItem>? items,
    ShopCategory? selectedCategory,
    ThemeType? selectedThemeType,
    StickerType? selectedStickerType,
    String? lastPurchasedId,
    String? lastEquippedId,
    int? userCoins,
    int? userDiamonds,
  }) {
    return ShopState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedThemeType: selectedThemeType ?? this.selectedThemeType,
      selectedStickerType: selectedStickerType ?? this.selectedStickerType,
      lastPurchasedId: lastPurchasedId ?? this.lastPurchasedId,
      lastEquippedId: lastEquippedId ?? this.lastEquippedId,
      userCoins: userCoins ?? this.userCoins,
      userDiamonds: userDiamonds ?? this.userDiamonds,
    );
  }

  List<ShopItem> get tokenItems =>
      items.where((i) => i.category == ShopCategory.token).toList();

  List<ShopItem> get basicThemes => items
      .where((i) =>
          i.category == ShopCategory.theme && i.themeType == ThemeType.basic)
      .toList();

  List<ShopItem> get royalThemes => items
      .where((i) =>
          i.category == ShopCategory.theme && i.themeType == ThemeType.royal)
      .toList();

  List<ShopItem> get tileItems =>
      items.where((i) => i.category == ShopCategory.tile).toList();

  List<ShopItem> get stickerPacks => items
      .where((i) =>
          i.category == ShopCategory.stickers &&
          i.stickerType == StickerType.pack)
      .toList();

  List<ShopItem> get singleStickers => items
      .where((i) =>
          i.category == ShopCategory.stickers &&
          i.stickerType == StickerType.single)
      .toList();

  List<ShopItem> get royalExclusives =>
      items.where((i) => i.category == ShopCategory.royal).toList();

  List<ShopItem> get featuredItems {
    final list = <ShopItem>[];
    // Pick popular highlights from each category
    final tokens = tokenItems.where((i) => !i.isEquipped).take(2);
    final themes = basicThemes.where((i) => !i.isEquipped).take(2);
    final royal = royalExclusives.take(2);
    final stickers = stickerPacks.take(2);
    list.addAll(tokens);
    list.addAll(themes);
    list.addAll(royal);
    list.addAll(stickers);
    return list;
  }
}

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref _ref;
  final ShopRepository _repository;

  ShopNotifier(this._ref, this._repository)
      : super(const ShopState(items: ShopCatalog.allItems)) {
    _syncWithAuth();
  }

  void _syncWithAuth() {
    try {
      final authUser = _ref.read(authProvider).user;
      if (authUser != null) {
        state = state.copyWith(
          userCoins: authUser.coins,
          userDiamonds: authUser.diamonds,
        );
      }
    } catch (_) {}
  }

  void selectCategory(ShopCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectThemeType(ThemeType type) {
    state = state.copyWith(selectedThemeType: type);
  }

  void selectStickerType(StickerType type) {
    state = state.copyWith(selectedStickerType: type);
  }

  /// Equips an item in its category slot while unequipping other items in the same category slot
  void equipItem(ShopItem item) {
    final updatedList = state.items.map((i) {
      if (i.category == item.category) {
        if (i.category == ShopCategory.theme) {
          // For theme, single equipped theme
          if (i.id == item.id) {
            return i.copyWith(isEquipped: true, isOwned: true);
          }
          return i.copyWith(isEquipped: false);
        } else if (i.category == ShopCategory.stickers) {
          // For stickers, toggle or equip
          if (i.id == item.id) {
            return i.copyWith(isEquipped: !i.isEquipped, isOwned: true);
          }
          return i;
        } else {
          // For tokens, tiles, royal vehicles
          if (i.id == item.id) {
            return i.copyWith(isEquipped: true, isOwned: true);
          }
          return i.copyWith(isEquipped: false);
        }
      }
      return i;
    }).toList();

    state = state.copyWith(
      items: updatedList,
      lastEquippedId: item.id,
    );
  }

  /// Buys an item: checks balance, deducts funds, marks as owned, and auto equips
  bool buyItem(ShopItem item) {
    // 1. Balance validation
    if (item.currencyType == CurrencyType.coins) {
      if (state.userCoins < item.price) return false;
      state = state.copyWith(userCoins: state.userCoins - item.price);
    } else if (item.currencyType == CurrencyType.diamonds) {
      if (state.userDiamonds < item.price) return false;
      state = state.copyWith(userDiamonds: state.userDiamonds - item.price);
    }

    // 2. Update item owned status
    final updatedList = state.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isOwned: true);
      }
      return i;
    }).toList();

    state = state.copyWith(
      items: updatedList,
      lastPurchasedId: item.id,
    );

    // 3. Auto equip purchased item
    equipItem(item);
    return true;
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return ShopNotifier(ref, repository);
});

// Backward compatibility providers
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShopRepository(apiClient: apiClient);
});

final storeItemsProvider =
    FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getStoreItems();
});

final userInventoryProvider =
    FutureProvider.autoDispose<List<StoreItemModel>>((ref) async {
  final shopRepository = ref.watch(shopRepositoryProvider);
  return await shopRepository.getInventory();
});

class ShopRepository {
  final ApiClient _apiClient;

  ShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StoreItemModel>> getStoreItems() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.storeItems);
      final data = response is Map<String, dynamic> &&
              response.containsKey('data')
          ? response['data']
          : response;

      if (data is List) {
        return data
            .map((item) =>
                StoreItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<StoreItemModel>> getInventory() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.storeInventory);
      final data = response is Map<String, dynamic> &&
              response.containsKey('data')
          ? response['data']
          : response;

      if (data is List) {
        return data
            .map((item) =>
                StoreItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> purchaseItem(int itemId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.storePurchase,
        data: {'item_id': itemId},
      );
      return response != null;
    } catch (_) {
      return false;
    }
  }
}
