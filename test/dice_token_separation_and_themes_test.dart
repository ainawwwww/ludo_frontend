import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/profile/models/profile_customization_model.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dice and Token Customization Separation Tests', () {
    test('ShopCatalog separates dice items and token items into distinct categories', () {
      final diceItems = ShopCatalog.allItems.where((i) => i.category == ShopCategory.dice).toList();
      final tokenItems = ShopCatalog.allItems.where((i) => i.category == ShopCategory.token).toList();

      expect(diceItems.isNotEmpty, isTrue);
      expect(tokenItems.isNotEmpty, isTrue);

      // Verify dice and token item IDs do not conflict
      for (final dice in diceItems) {
        expect(dice.id.startsWith('dice_'), isTrue);
      }
      for (final token in tokenItems) {
        expect(token.id.startsWith('token_'), isTrue);
      }
    });

    test('Equipping a dice does NOT change the equipped token', () {
      final container = ProviderContainer();
      final notifier = container.read(shopProvider.notifier);

      // Initial state: default dice and default token are equipped
      var state = container.read(shopProvider);
      final initialDice = state.diceItems.firstWhere((i) => i.isEquipped);
      final initialToken = state.tokenItems.firstWhere((i) => i.isEquipped);

      expect(initialDice.id, equals('dice_classic'));
      expect(initialToken.id, equals('token_classic'));

      // Equip Chick Dice
      final chickDice = state.diceItems.firstWhere((i) => i.id == 'dice_chick');
      notifier.equipItem(chickDice);

      state = container.read(shopProvider);
      final currentDice = state.diceItems.firstWhere((i) => i.isEquipped);
      final currentToken = state.tokenItems.firstWhere((i) => i.isEquipped);

      // Dice changed to Chick
      expect(currentDice.id, equals('dice_chick'));
      // Token remained Classic! (Not affected)
      expect(currentToken.id, equals('token_classic'));

      // Equip Campfire Token
      final campfireToken = state.tokenItems.firstWhere((i) => i.id == 'token_warm_campfire');
      notifier.equipItem(campfireToken);

      state = container.read(shopProvider);
      final updatedDice = state.diceItems.firstWhere((i) => i.isEquipped);
      final updatedToken = state.tokenItems.firstWhere((i) => i.isEquipped);

      // Dice remained Chick! (Not affected)
      expect(updatedDice.id, equals('dice_chick'));
      // Token changed to Campfire
      expect(updatedToken.id, equals('token_warm_campfire'));
    });
  });

  group('High-Resolution Profile Themes Tests', () {
    test('ProfileThemeItem.allThemes contains high-resolution assets from assets/graphics/themes', () {
      expect(ProfileThemeItem.allThemes.length, greaterThanOrEqualTo(15));

      final goldenMountain = ProfileThemeItem.allThemes.firstWhere((t) => t.id == 'theme_golden_mountain');
      expect(goldenMountain.assetPath, equals('assets/graphics/themes/basic themes/Golden Mountain.png'));

      final starryNight = ProfileThemeItem.allThemes.firstWhere((t) => t.id == 'theme_starry_night');
      expect(starryNight.assetPath, equals('assets/graphics/themes/basic themes/Starry night.png'));

      final royalCastle = ProfileThemeItem.allThemes.firstWhere((t) => t.id == 'theme_castle_royal');
      expect(royalCastle.assetPath, equals('assets/graphics/themes/Royal theme/castle.png'));
      expect(royalCastle.isRoyal, isTrue);

      final dreamGarden = ProfileThemeItem.allThemes.firstWhere((t) => t.id == 'theme_dream_garden');
      expect(dreamGarden.assetPath, equals('assets/graphics/themes/Royal theme/Dream Garden.png'));
      expect(dreamGarden.isRoyal, isTrue);

      final twilightKnight = ProfileThemeItem.allThemes.firstWhere((t) => t.id == 'theme_twilight_knight');
      expect(twilightKnight.assetPath, equals('assets/graphics/themes/Royal theme/Twilight knight.png'));
      expect(twilightKnight.isRoyal, isTrue);
    });
  });
}
