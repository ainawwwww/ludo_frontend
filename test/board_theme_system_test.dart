import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/providers/board_theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Board Theme System Tests', () {
    test('PlayerColor correctly maps to Seat (Requirement 1)', () {
      expect(PlayerColor.green.seat, equals(Seat.tl));
      expect(PlayerColor.yellow.seat, equals(Seat.tr));
      expect(PlayerColor.red.seat, equals(Seat.bl));
      expect(PlayerColor.blue.seat, equals(Seat.br));

      // Seat origins in 6x6 quadrants
      expect(Seat.tl.quadrantOrigin, equals(const Offset(0, 0)));
      expect(Seat.tr.quadrantOrigin, equals(const Offset(9, 0)));
      expect(Seat.bl.quadrantOrigin, equals(const Offset(0, 9)));
      expect(Seat.br.quadrantOrigin, equals(const Offset(9, 9)));
    });

    test('Manifest file exists and parses all 11 themes with grid sanity', () {
      final file = File('assets/themes/themes_manifest.json');
      expect(file.existsSync(), isTrue, reason: 'themes_manifest.json must exist in assets/themes/');

      final jsonStr = file.readAsStringSync();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final rawThemes = decoded['themes'] as List<dynamic>;

      expect(rawThemes.length, equals(11), reason: 'Must contain all 11 theme definitions');

      final expectedThemeIds = [
        'dessert',
        'enchanted',
        'cloudy',
        'warrior',
        'lightning',
        'lucky_chest',
        'frostfire',
        'paint',
        'storm_lightning',
        'indigo_wallpaper',
        'letter_from_spring',
      ];

      for (final raw in rawThemes) {
        final map = raw as Map<String, dynamic>;
        final theme = LudoTheme.fromJson(map);

        expect(expectedThemeIds.contains(theme.id), isTrue, reason: 'Unexpected theme id: ${theme.id}');
        expect(theme.name.isNotEmpty, isTrue);
        expect(theme.boardAsset.isNotEmpty, isTrue);
        expect(theme.previewAsset.isNotEmpty, isTrue);

        // Sanity check: grid fractions must stay within board bounds [0..1]
        expect(
          theme.grid.left + theme.grid.size,
          lessThanOrEqualTo(1.0001),
          reason: 'Grid bounds overflow on theme: ${theme.id}',
        );
        expect(
          theme.grid.top + theme.grid.size,
          lessThanOrEqualTo(1.0001),
          reason: 'Grid bounds overflow on theme: ${theme.id}',
        );

        // 4 seat colors
        expect(theme.seatColors.containsKey(Seat.tl), isTrue);
        expect(theme.seatColors.containsKey(Seat.tr), isTrue);
        expect(theme.seatColors.containsKey(Seat.bl), isTrue);
        expect(theme.seatColors.containsKey(Seat.br), isTrue);

        // 4 home slots
        expect(theme.homeSlots.length, equals(4));
        for (final slot in theme.homeSlots) {
          expect(slot.dx, greaterThanOrEqualTo(0.0));
          expect(slot.dx, lessThanOrEqualTo(6.0));
          expect(slot.dy, greaterThanOrEqualTo(0.0));
          expect(slot.dy, lessThanOrEqualTo(6.0));
        }

        // Verify board.png and preview.png exist on disk
        final boardFile = File(theme.boardAsset);
        expect(boardFile.existsSync(), isTrue, reason: 'Missing board file: ${theme.boardAsset}');
        final previewFile = File(theme.previewAsset);
        expect(previewFile.existsSync(), isTrue, reason: 'Missing preview file: ${theme.previewAsset}');
      }
    });

    test('cellCenter math places cells accurately and stays inside grid', () {
      const double boardSide = 360.0;
      const theme = LudoTheme(
        id: 'test_theme',
        name: 'Test',
        boardAsset: '',
        previewAsset: '',
        grid: ThemeGrid(left: 0.06, top: 0.06, size: 0.88, cells: 15),
        seatColors: {
          Seat.tl: Color(0xFF0F9D58),
          Seat.tr: Color(0xFFF4B400),
          Seat.bl: Color(0xFFDB4437),
          Seat.br: Color(0xFF4285F4),
        },
        homeSlots: [
          Offset(1.5, 1.5),
          Offset(4.5, 1.5),
          Offset(1.5, 4.5),
          Offset(4.5, 4.5),
        ],
      );

      final origin = Offset(theme.grid.left * boardSide, theme.grid.top * boardSide);
      final cell = (theme.grid.size * boardSide) / 15.0;

      Offset cellCenter(int col, int row) =>
          origin + Offset((col + 0.5) * cell, (row + 0.5) * cell);

      // Top-left cell (0, 0)
      final tl = cellCenter(0, 0);
      expect(tl.dx, greaterThan(origin.dx));
      expect(tl.dy, greaterThan(origin.dy));
      expect(tl.dx, lessThan(origin.dx + cell));
      expect(tl.dy, lessThan(origin.dy + cell));

      // Center cell (7, 7)
      final center = cellCenter(7, 7);
      final boardCenter = boardSide / 2.0;
      expect((center.dx - boardCenter).abs(), lessThan(5.0));
      expect((center.dy - boardCenter).abs(), lessThan(5.0));

      // Bottom-right cell (14, 14)
      final br = cellCenter(14, 14);
      expect(br.dx, lessThan(origin.dx + theme.grid.size * boardSide));
      expect(br.dy, lessThan(origin.dy + theme.grid.size * boardSide));
    });

    test('LudoTheme.classic is default and free', () {
      expect(LudoTheme.classic.isClassic, isTrue);
      expect(LudoTheme.classic.price, equals(0));
      expect(LudoTheme.classic.id, equals('classic'));
      expect(LudoTheme.classic.seatColors[Seat.tl], equals(const Color(0xFF0F9D58)));
      expect(LudoTheme.classic.seatColors[Seat.tr], equals(const Color(0xFFF4B400)));
      expect(LudoTheme.classic.seatColors[Seat.bl], equals(const Color(0xFFDB4437)));
      expect(LudoTheme.classic.seatColors[Seat.br], equals(const Color(0xFF4285F4)));
    });

    test('Riverpod providers state defaults to classic and equips correctly', () {
      final container = ProviderContainer();
      final initialTheme = container.read(activeThemeProvider);
      expect(initialTheme.isClassic, isTrue);

      // Select another theme
      container.read(selectedThemeIdProvider.notifier).selectTheme('dessert');
      expect(container.read(selectedThemeIdProvider), equals('dessert'));

      // Owned themes initial set contains classic
      final owned = container.read(ownedThemesProvider);
      expect(owned.contains('classic'), isTrue);
    });
  });
}
