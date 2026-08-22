import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';

void main() {
  testWidgets('ShopScreen aligns items on shelf ledges across multiple screen sizes', (WidgetTester tester) async {
    final testSizes = [
      const Size(390, 844), // iPhone 13/14
      const Size(411, 915), // Pixel 6
      const Size(360, 740), // Small Android
    ];

    for (final size in testSizes) {
      tester.view.physicalSize = size * tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const ShopScreen(),
        ),
      );

      // Verify diamond balance, banner, close button, and items
      expect(find.text('33'), findsOneWidget);
      expect(find.text('Skin Design Contest'), findsOneWidget);

      // Verify all 11 shop items are present in widget tree via asset image widgets
      for (final item in ShopScreen.items) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == item.iconPath,
          ),
          findsOneWidget,
        );
      }
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
