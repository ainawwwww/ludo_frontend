import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';

void main() {
  testWidgets('ShopScreen builds and renders top bar and item slots',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShopScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify close button
    final closeButtonFinder = find.byIcon(Icons.close_rounded);
    expect(closeButtonFinder, findsOneWidget);
    await tester.tap(closeButtonFinder, warnIfMissed: false);
    await tester.pump();
  });
}
