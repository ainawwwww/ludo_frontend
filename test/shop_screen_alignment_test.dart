import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/ornament_screen.dart';
import 'package:ludo_vibe/features/shop/screens/royal_vehicle_shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/shop_hub_screen.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/sticker_shop_screen.dart';
import 'package:ludo_vibe/features/shop/screens/table_tile_screen.dart';
import 'package:ludo_vibe/features/shop/screens/wallpaper_shop_screen.dart';

void main() {
  testWidgets('All Shop screens and sub-tabs render seamlessly across multiple screen sizes', (WidgetTester tester) async {
    final testSizes = [
      const Size(393, 852), // iPhone 16
      const Size(411, 915), // Pixel 6
      const Size(360, 740), // Small Android
    ];

    for (final size in testSizes) {
      tester.view.physicalSize = size * tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = 1.0;

      // 1. Test ShopHubScreen (Screen 1 - 4 Tiers of 3D Shelves Hub)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ludo Skin'), findsOneWidget);
      expect(find.text('Domino Skin'), findsOneWidget);
      expect(find.text('Jackaro Skin'), findsOneWidget);
      expect(find.text('Sticker'), findsOneWidget);
      expect(find.text('Royal Vehicle'), findsOneWidget);

      // 2. Test ShopScreen (Screen 2 - Dice Tab)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopScreen(initialTabIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dice'), findsOneWidget);
      expect(find.text('Token'), findsOneWidget);
      expect(find.text('Bubble'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Classic'), findsWidgets);

      // 3. Test ShopScreen (Screen 2 - Token Tab with 4-piece sets)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopScreen(key: ValueKey('token_tab'), initialTabIndex: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Arrow'), findsOneWidget);

      // 4. Test ShopScreen (Screen 2 - Bubble Tab with Speech frames)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopScreen(key: ValueKey('bubble_tab'), initialTabIndex: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chick Bubble'), findsOneWidget);

      // 5. Test ShopScreen (Screen 2 - Theme Board Skins Tab)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShopScreen(key: ValueKey('theme_tab'), initialTabIndex: 3),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Warrior helmet'), findsOneWidget);

      // 6. Test OrnamentScreen (Screen 3 - 2-Column Wide Ribbons)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OrnamentScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ornament'), findsOneWidget);

      // 7. Test RoyalVehicleShopScreen (Screen 4 - 3D Stage & Vehicle Shelves)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoyalVehicleShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No vehicle is equipped'), findsOneWidget);

      // 8. Test WallpaperShopScreen (Basic Theme & Royal Theme Wallpapers)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WallpaperShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Basic Theme'), findsOneWidget);
      expect(find.text('Royal Theme'), findsOneWidget);
      expect(find.text('Golden Mountain'), findsOneWidget);

      // 9. Test TableTileScreen (Screen 5 - Table & Tile tabs)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TableTileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Table'), findsOneWidget);
      expect(find.text('Tile'), findsOneWidget);

      // 10. Test StickerShopScreen (Screen 6 - Sticker Pack & Single Sticker)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StickerShopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sticker Pack'), findsOneWidget);
      expect(find.text('Single Sticker'), findsOneWidget);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
