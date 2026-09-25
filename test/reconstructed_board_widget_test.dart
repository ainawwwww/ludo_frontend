import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/widgets/reconstructed_board_widget.dart';
import 'package:ludo_vibe/features/game/widgets/classic_procedural_board.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReconstructedBoardWidget Widget Tests', () {
    testWidgets('Renders ClassicProceduralBoardWidget when theme is classic', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ReconstructedBoardWidget(
                theme: LudoTheme.classic,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ClassicProceduralBoardWidget), findsOneWidget);
    });

    testWidgets('Renders ClassicProceduralBoardWidget fallback when vector reconstruction fails', (tester) async {
      // Create a theme with an invalid manifestPath to simulate error
      const brokenTheme = LudoTheme(
        id: 'broken_theme',
        name: 'Broken Theme',
        boardAsset: '',
        previewAsset: '',
        grid: ThemeGrid(left: 0, top: 0, size: 1),
        seatColors: {},
        homeSlots: [],
        boardFolder: 'assets/themes/non_existent_folder',
        manifestPath: 'assets/themes/non_existent_folder/manifest.json',
        usesVectorReconstruction: true,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ReconstructedBoardWidget(
                theme: brokenTheme,
                size: 300,
              ),
            ),
          ),
        ),
      );

      // Pump to process future
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Must render ClassicProceduralBoardWidget as fallback (Correction 2)
      expect(find.byType(ClassicProceduralBoardWidget), findsOneWidget);
    });
  });
}
