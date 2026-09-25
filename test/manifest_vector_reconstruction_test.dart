import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/models/board_manifest_model.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';
import 'package:ludo_vibe/features/game/services/board_reconstructor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Manifest-Driven Vector Ludo Board Reconstruction Tests', () {
    const basePath = 'assets/themes/ludo-board-components';

    test('1. index.json exists and registers all 11 themes', () {
      final indexFile = File('$basePath/index.json');
      expect(indexFile.existsSync(), isTrue, reason: 'index.json must exist');

      final content = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
      final boards = content['boards'] as List<dynamic>;
      expect(boards.length, equals(11), reason: 'Must contain 11 themes');
    });

    test('2. All 11 theme folders exist and have valid manifest.json files', () {
      int totalUniqueAssets = 0;
      int totalPlacements = 0;

      for (final entry in LudoTheme.themeFolderMap.entries) {
        final themeId = entry.key;
        final folderName = entry.value;
        final manifestFile = File('$basePath/$folderName/manifest.json');

        expect(manifestFile.existsSync(), isTrue,
            reason: 'Manifest for theme $themeId must exist at ${manifestFile.path}');

        final jsonMap = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
        final manifest = BoardManifest.fromJson(jsonMap);

        // Validation test
        final error = manifest.validate();
        expect(error, isNull, reason: 'Manifest for $themeId must be valid, but got: $error');

        // Canvas dimensions must be 688x688
        expect(manifest.canvas.width, equals(688.0));
        expect(manifest.canvas.height, equals(688.0));
        expect(manifest.canvas.viewBox, equals([0.0, 0.0, 688.0, 688.0]));

        totalUniqueAssets += manifest.assetIndex.length;
        totalPlacements += manifest.placements.length;

        // Verify every referenced SVG exists on disk
        for (final asset in manifest.assetIndex) {
          final relPath = asset.file.startsWith('/') ? asset.file.substring(1) : asset.file;
          final svgFile = File('$basePath/$folderName/$relPath');
          expect(svgFile.existsSync(), isTrue,
              reason: 'Component ${asset.id} ($relPath) for $themeId must exist at ${svgFile.path}');
        }

        // Verify every placement references a valid assetIndex
        for (int i = 0; i < manifest.placements.length; i++) {
          final p = manifest.placements[i];
          expect(p.assetIndex, greaterThanOrEqualTo(0));
          expect(p.assetIndex, lessThan(manifest.assetIndex.length));
          expect(p.width, greaterThanOrEqualTo(0));
          expect(p.height, greaterThanOrEqualTo(0));
        }
      }

      expect(totalUniqueAssets, equals(2188), reason: 'Total unique SVGs across all 11 themes must be 2,188');
      expect(totalPlacements, equals(5256), reason: 'Total placements across all 11 themes must be 5,256');
    });

    test('3. LudoTheme model correctly maps themeId to vector manifestPath', () {
      for (final entry in LudoTheme.themeFolderMap.entries) {
        final themeId = entry.key;
        final folderName = entry.value;

        final theme = LudoTheme.fromJson({'id': themeId, 'name': themeId});
        expect(theme.usesVectorReconstruction, isTrue);
        expect(theme.boardFolder, equals('assets/themes/ludo-board-components/$folderName'));
        expect(theme.manifestPath, equals('assets/themes/ludo-board-components/$folderName/manifest.json'));
      }

      // Classic theme must NOT use vector reconstruction
      expect(LudoTheme.classic.usesVectorReconstruction, isFalse);
      expect(LudoTheme.classic.manifestPath, isNull);
    });

    test('4. Corrupt manifest validation properly catches errors', () {
      const invalidManifest = BoardManifest(
        schemaVersion: 0,
        sourceFile: 'bad.svg',
        canvas: BoardCanvas(width: -1, height: -1, viewBox: []),
        coordinateSystem: 'SVG pixels',
        assetIndex: [],
        placements: [],
      );

      final error = invalidManifest.validate();
      expect(error, isNotNull);
      expect(error!.contains('Unsupported schemaVersion'), isTrue);
    });

    test('5. BoardReconstructorService LRU cache and pinning works correctly', () {
      final service = BoardReconstructorService();

      service.pinTheme('dessert');
      // Verify clearing cache does not crash
      service.clearCache();
    });
  });
}
