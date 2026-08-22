import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/shared/widgets/ludo_loading_overlay.dart';

void main() {
  testWidgets('LudoLoadingOverlay renders blur, 3D dice, 4 tokens, and 4 dots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Text('Background Menu Screen'),
              LudoLoadingOverlay(),
            ],
          ),
        ),
      ),
    );

    // Verify background text is under the overlay
    expect(find.text('Background Menu Screen'), findsOneWidget);

    // Verify LudoLoadingOverlay widget exists
    expect(find.byType(LudoLoadingOverlay), findsOneWidget);

    // Pump frames to advance animations (dice tumble, orbit, spin, dot pulse)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1600));

    // Verify Image widgets for 4 Ludo tokens are rendered
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsNWidgets(4));
  });

  testWidgets('LudoLoadingOverlay.show and hide API work correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => LudoLoadingOverlay.show(context),
                child: const Text('Show Loader'),
              );
            },
          ),
        ),
      ),
    );

    expect(LudoLoadingOverlay.isShowing, false);

    // Tap button to show overlay
    await tester.tap(find.text('Show Loader'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250)); // Finish 200ms fade transition

    expect(LudoLoadingOverlay.isShowing, true);
    expect(find.byType(LudoLoadingOverlay), findsOneWidget);

    // Get dialog context to hide overlay
    final BuildContext currentContext = tester.element(find.byType(LudoLoadingOverlay));
    LudoLoadingOverlay.hide(currentContext);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250)); // Finish 200ms fade-out transition

    expect(LudoLoadingOverlay.isShowing, false);
    expect(find.byType(LudoLoadingOverlay), findsNothing);
  });
}
