import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/repositories/theme_repository.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/game/services/board_reconstructor_service.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

final themeCatalogProvider = FutureProvider<List<LudoTheme>>((ref) async {
  final repo = ref.watch(themeRepositoryProvider);
  return repo.getThemes();
});

class OwnedThemesNotifier extends StateNotifier<Set<String>> {
  static const String _keyOwnedThemes = 'owned_theme_ids';
  final Ref _ref;

  OwnedThemesNotifier(this._ref) : super({'classic'}) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyOwnedThemes);
      if (list != null && list.isNotEmpty) {
        state = {...list, 'classic'};
      }
    } catch (_) {}
  }

  Future<void> _saveToPreferences(Set<String> themes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyOwnedThemes, themes.toList());
    } catch (_) {}
  }

  /// Attempts to buy a theme with coins. Deducts coins, adds to owned, persists, and equips.
  bool buyTheme(LudoTheme theme) {
    if (state.contains(theme.id)) return true;

    final shopState = _ref.read(shopProvider);
    if (shopState.userCoins < theme.price) {
      return false;
    }

    // Deduct coins from shopProvider
    final shopNotifier = _ref.read(shopProvider.notifier);
    shopNotifier.state = shopNotifier.state.copyWith(
      userCoins: shopNotifier.state.userCoins - theme.price,
    );

    // Update owned themes
    final updated = {...state, theme.id};
    state = updated;
    _saveToPreferences(updated);

    // Auto equip upon purchase
    _ref.read(selectedThemeIdProvider.notifier).selectTheme(theme.id);
    return true;
  }
}

final ownedThemesProvider =
    StateNotifierProvider<OwnedThemesNotifier, Set<String>>((ref) {
  return OwnedThemesNotifier(ref);
});

class SelectedThemeIdNotifier extends StateNotifier<String> {
  static const String _keySelectedTheme = 'selected_theme_id';

  SelectedThemeIdNotifier() : super('classic') {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keySelectedTheme);
      if (saved != null && saved.isNotEmpty) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> selectTheme(String themeId) async {
    state = themeId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedTheme, themeId);
    } catch (_) {}
  }
}

final selectedThemeIdProvider =
    StateNotifierProvider<SelectedThemeIdNotifier, String>((ref) {
  return SelectedThemeIdNotifier();
});

/// Resolves active LudoTheme based on selectedThemeIdProvider and catalog
final activeThemeProvider = Provider<LudoTheme>((ref) {
  final selectedId = ref.watch(selectedThemeIdProvider);
  final catalogAsync = ref.watch(themeCatalogProvider);

  return catalogAsync.maybeWhen(
    data: (themes) => themes.firstWhere(
      (t) => t.id == selectedId,
      orElse: () => LudoTheme.classic,
    ),
    orElse: () => LudoTheme.classic,
  );
});

/// Singleton provider for the vector board reconstructor service
final boardReconstructorServiceProvider = Provider<BoardReconstructorService>((ref) {
  return BoardReconstructorService();
});

/// FutureProvider that builds/caches the in-memory reconstructed SVG string for a given theme ID
final reconstructedBoardSvgProvider = FutureProvider.family<String, String>((ref, themeId) async {
  final repo = ref.watch(themeRepositoryProvider);
  final theme = repo.getThemeById(themeId);
  if (!theme.usesVectorReconstruction || theme.manifestPath == null) {
    return '';
  }
  final service = ref.watch(boardReconstructorServiceProvider);
  service.pinTheme(themeId);
  return service.reconstructSvgString(theme);
});
