import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';

class ThemeRepository {
  static const String manifestAssetPath = 'assets/themes/themes_manifest.json';

  static const Map<String, int> themePrices = {
    'classic': 0,
    'dessert': 800,
    'cloudy': 1000,
    'paint': 1200,
    'warrior': 1500,
    'frostfire': 1600,
    'enchanted': 1800,
    'lightning': 2000,
    'lucky_chest': 2200,
    'storm_lightning': 2500,
    'indigo_wallpaper': 2800,
    'letter_from_spring': 3000,
  };

  List<LudoTheme>? _cachedThemes;

  Future<List<LudoTheme>> getThemes() async {
    if (_cachedThemes != null) return _cachedThemes!;

    final themes = <LudoTheme>[
      LudoTheme.classic,
    ];

    try {
      final jsonString = await rootBundle.loadString(manifestAssetPath);
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['themes'] is List) {
        final list = decoded['themes'] as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final id = item['id']?.toString() ?? '';
            final price = themePrices[id] ?? 1000;
            themes.add(LudoTheme.fromJson(item, price: price));
          }
        }
      }
    } catch (e) {
      // If error occurs, classic remains available
    }

    _cachedThemes = themes;
    return themes;
  }

  /// Synchronous fallback / direct lookup from cache if available
  LudoTheme getThemeById(String id) {
    if (_cachedThemes != null) {
      return _cachedThemes!.firstWhere(
        (t) => t.id == id,
        orElse: () => LudoTheme.classic,
      );
    }
    return id == 'classic' ? LudoTheme.classic : LudoTheme.classic;
  }
}
