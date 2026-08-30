import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/widgets/ludo_3d_dice_widget.dart';

void main() {
  testWidgets(
      '3D dice uses one canvas renderer and resolves exactly to target value',
      (tester) async {
    final diceKey = GlobalKey<Ludo3DDiceState>();
    var rollStarts = 0;
    final completedValues = <int>[];

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Ludo3DDiceWidget(
              key: diceKey,
              customSkinKey: 'classic',
              initialValue: 1,
              onRollStart: () => rollStarts++,
              onRollComplete: completedValues.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final diceFinder = find.byType(Ludo3DDiceWidget);
    expect(
      find.descendant(of: diceFinder, matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: diceFinder, matching: find.byType(Transform)),
      findsNothing,
    );

    diceKey.currentState!.roll(targetResult: 3);
    diceKey.currentState!.roll(targetResult: 5);
    expect(rollStarts, 1);
    expect(diceKey.currentState!.isAnimating, isTrue);

    // First frame establishes the animation's start timestamp.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(diceKey.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 800));
    expect(diceKey.currentState!.isAnimating, isFalse);
    expect(diceKey.currentState!.currentFace, 3);
    expect(completedValues, [3]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
