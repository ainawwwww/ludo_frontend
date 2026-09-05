import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/game/widgets/ludo_dice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LudoDice Reusable Widget Tests', () {
    testWidgets('LudoDice renders in idle state and triggers onRollComplete when rolled', (WidgetTester tester) async {
      int? rolledValue;
      bool rollStarted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LudoDice(
                  customSkinKey: 'classic',
                  size: 64,
                  onRollStart: () {
                    rollStarted = true;
                  },
                  onRollComplete: (val) {
                    rolledValue = val;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify dice is present in idle state
      expect(find.byType(LudoDice), findsOneWidget);
      expect(rollStarted, false);
      expect(rolledValue, null);

      // Tap the dice to roll
      await tester.tap(find.byType(LudoDice));
      await tester.pump();

      expect(rollStarted, true);

      // Fast forward animation & periodic timer cycles
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify roll completed and delivered value (1-6)
      expect(rolledValue, isNotNull);
      expect(rolledValue! >= 1 && rolledValue! <= 6, true);
    });

    testWidgets('LudoDice respects targetValue for deterministic rolls', (WidgetTester tester) async {
      int? rolledValue;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LudoDice(
                  customSkinKey: 'chick',
                  targetValue: 5,
                  size: 64,
                  onRollComplete: (val) {
                    rolledValue = val;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Tap dice
      await tester.tap(find.byType(LudoDice));
      await tester.pump();
      await tester.pumpAndSettle();

      // Delivered target value
      expect(rolledValue, equals(5));
    });

    testWidgets('LudoDice cannot be tapped when disabled', (WidgetTester tester) async {
      bool rollStarted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LudoDice(
                  customSkinKey: 'classic',
                  isEnabled: false,
                  onRollStart: () {
                    rollStarted = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LudoDice));
      await tester.pump();
      expect(rollStarted, false);
    });

    testWidgets('LudoDice guards against multi-tap during animation', (WidgetTester tester) async {
      int startCount = 0;
      int completeCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LudoDice(
                  customSkinKey: 'classic',
                  onRollStart: () {
                    startCount++;
                  },
                  onRollComplete: (val) {
                    completeCount++;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // First tap
      await tester.tap(find.byType(LudoDice));
      await tester.pump(const Duration(milliseconds: 50));
      expect(startCount, 1);

      // Second tap while still animating
      await tester.tap(find.byType(LudoDice));
      await tester.pump(const Duration(milliseconds: 50));
      // Start count should still be 1 (ignored)
      expect(startCount, 1);

      // Finish animation
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(completeCount, 1);
    });

    testWidgets('LudoDice resets to idle state via GlobalKey', (WidgetTester tester) async {
      final key = GlobalKey<LudoDiceState>();
      int? lastResult;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: LudoDice(
                  key: key,
                  targetValue: 4,
                  onRollComplete: (val) => lastResult = val,
                ),
              ),
            ),
          ),
        ),
      );

      key.currentState?.roll();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(lastResult, 4);
      expect(key.currentState?.isAnimating, false);

      key.currentState?.resetToIdle();
      await tester.pump();
      expect(key.currentState?.isAnimating, false);
    });
  });
}
