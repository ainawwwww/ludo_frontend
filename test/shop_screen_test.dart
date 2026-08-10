import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/shop/screens/shop_screen.dart';

void main() {
  testWidgets('ShopScreen builds and renders top bar, contest banner, and item slots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShopScreen(),
      ),
    );

    // Verify diamond balance text '33' is present
    expect(find.text('33'), findsOneWidget);

    // Verify contest banner texts are present
    expect(find.text('Skin Design Contest'), findsOneWidget);
    expect(find.text('Co-Created Skins'), findsOneWidget);
    expect(find.text('29/06/2026 05:00 - 07/07/2026 05:00 (GMT+3)'), findsOneWidget);

    // Tap close button
    final closeButtonFinder = find.byIcon(Icons.close_rounded);
    expect(closeButtonFinder, findsOneWidget);
    await tester.tap(closeButtonFinder, warnIfMissed: false);
    await tester.pump();
  });
}
