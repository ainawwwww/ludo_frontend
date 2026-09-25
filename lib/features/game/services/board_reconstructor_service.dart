import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ludo_vibe/features/game/models/board_manifest_model.dart';
import 'package:ludo_vibe/features/game/models/ludo_theme_model.dart';

/// Processed SVG asset with namespaced defs and drawable body.
class _ProcessedAsset {
  final String defsContent;
  final String bodyContent;

  const _ProcessedAsset({
    required this.defsContent,
    required this.bodyContent,
  });
}

/// Core service that reconstructs vector Ludo boards from manifest.json and component SVGs.
/// Implements 3-tier caching with LRU eviction and defs namespacing to prevent ID collisions.
class BoardReconstructorService {
  static const int _maxComposedCacheSize = 4;

  // Tier 1: Raw component SVG string cache (asset path -> raw SVG text)
  final Map<String, String> _rawSvgCache = {};

  // Tier 2: Parsed manifest cache (manifest path -> BoardManifest)
  final Map<String, BoardManifest> _manifestCache = {};

  // Tier 3: Composed 688x688 SVG document cache (themeId -> combined SVG XML)
  // Uses LinkedHashMap for O(1) LRU tracking.
  final LinkedHashMap<String, String> _composedSvgCache = LinkedHashMap();

  // Currently equipped / pinned theme ID that should never be evicted from LRU
  String? _pinnedThemeId;

  /// Pins the active theme to guarantee it remains in memory during gameplay.
  void pinTheme(String themeId) {
    _pinnedThemeId = themeId;
  }

  /// Clears in-memory caches (useful for testing or memory pressure warnings).
  void clearCache() {
    _rawSvgCache.clear();
    _manifestCache.clear();
    _composedSvgCache.clear();
  }

  /// Asynchronously pre-warms the vector representation for a theme.
  Future<void> prewarmTheme(LudoTheme theme) async {
    try {
      await reconstructSvgString(theme);
    } catch (e) {
      debugPrint('[BoardReconstructorService] Pre-warm failed for theme ${theme.id}: $e');
    }
  }

  /// Reconstructs the 688x688 vector board SVG document for the given theme.
  /// Throws [Exception] if manifest or any component fails to load, triggering
  /// fallback to the existing procedural Classic board.
  Future<String> reconstructSvgString(LudoTheme theme) async {
    if (!theme.usesVectorReconstruction || theme.manifestPath == null) {
      throw ArgumentError('Theme ${theme.id} does not use vector reconstruction');
    }

    // Check Tier 3 LRU cache
    if (_composedSvgCache.containsKey(theme.id)) {
      final cached = _composedSvgCache.remove(theme.id)!;
      _composedSvgCache[theme.id] = cached; // Move to most recently used
      return cached;
    }

    final manifestPath = theme.manifestPath!;
    final boardFolder = theme.boardFolder ?? manifestPath.substring(0, manifestPath.lastIndexOf('/'));

    // 1. Load and validate manifest
    final manifest = await _loadManifest(manifestPath);
    final validationError = manifest.validate();
    if (validationError != null) {
      throw FormatException('Manifest validation failed for ${theme.id}: $validationError');
    }

    // 2. Identify unique asset indexes required by placements
    final uniqueAssetIndices = <int>{};
    for (final p in manifest.placements) {
      uniqueAssetIndices.add(p.assetIndex);
    }

    // 3. Load all unique component SVGs concurrently
    final assetPathMap = <int, String>{};
    for (final idx in uniqueAssetIndices) {
      final assetMeta = manifest.assetIndex[idx];
      // Normalize asset path relative to board folder
      final relFile = assetMeta.file.startsWith('/')
          ? assetMeta.file.substring(1)
          : assetMeta.file;
      assetPathMap[idx] = '$boardFolder/$relFile';
    }

    final loadFutures = uniqueAssetIndices.map((idx) async {
      final path = assetPathMap[idx]!;
      final svgStr = await _loadRawSvg(path);
      return MapEntry(idx, svgStr);
    });

    final loadedEntries = await Future.wait(loadFutures);
    final rawSvgMap = Map.fromEntries(loadedEntries);

    // 4. Process assets: namespace defs IDs and extract body content
    final processedAssets = <int, _ProcessedAsset>{};
    final globalDefsList = <String>[];
    bool hasSharedCanvasClip = false;

    for (final idx in uniqueAssetIndices) {
      final rawSvg = rawSvgMap[idx]!;
      final prefix = 't_${theme.id}_a${idx}_';
      final processed = _processSvgComponent(
        rawSvg: rawSvg,
        prefix: prefix,
        onCommonClipFound: () {
          hasSharedCanvasClip = true;
        },
      );
      processedAssets[idx] = processed;
      if (processed.defsContent.isNotEmpty) {
        globalDefsList.add(processed.defsContent);
      }
    }

    // Include the canonical outer canvas clipPath if referenced
    if (hasSharedCanvasClip) {
      globalDefsList.insert(
        0,
        '<clipPath id="board_canvas_clip"><rect width="688" height="688" fill="white"/></clipPath>',
      );
    }

    // 5. Sort placements by ascending z-order
    final sortedPlacements = List<BoardPlacement>.from(manifest.placements)
      ..sort((a, b) => a.z.compareTo(b.z));

    // 6. Assemble placement XML elements
    final placementsBuffer = StringBuffer();
    for (final p in sortedPlacements) {
      final processed = processedAssets[p.assetIndex];
      if (processed == null || processed.bodyContent.isEmpty) continue;

      final assetMeta = manifest.assetIndex[p.assetIndex];
      final scaleX = assetMeta.intrinsicWidth > 0
          ? p.width / assetMeta.intrinsicWidth
          : 1.0;
      final scaleY = assetMeta.intrinsicHeight > 0
          ? p.height / assetMeta.intrinsicHeight
          : 1.0;

      final needsScale = (scaleX - 1.0).abs() > 0.001 || (scaleY - 1.0).abs() > 0.001;

      if (needsScale) {
        placementsBuffer.write(
          '<g transform="translate(${p.x} ${p.y}) scale(${scaleX.toStringAsFixed(4)} ${scaleY.toStringAsFixed(4)})">\n'
          '${processed.bodyContent}\n'
          '</g>\n',
        );
      } else {
        placementsBuffer.write(
          '<g transform="translate(${p.x} ${p.y})">\n'
          '${processed.bodyContent}\n'
          '</g>\n',
        );
      }
    }

    // 7. Assemble final 688x688 SVG document
    final composedSvg = StringBuffer()
      ..write('<svg width="688" height="688" viewBox="0 0 688 688" fill="none" ')
      ..write('xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n')
      ..write('<defs>\n')
      ..write(globalDefsList.join('\n'))
      ..write('\n</defs>\n')
      ..write(placementsBuffer.toString())
      ..write('</svg>');

    final result = composedSvg.toString();

    // 8. Cache in Tier 3 with LRU eviction
    _storeInComposedCache(theme.id, result);

    return result;
  }

  /// Loads and caches a BoardManifest from rootBundle.
  Future<BoardManifest> _loadManifest(String manifestPath) async {
    if (_manifestCache.containsKey(manifestPath)) {
      return _manifestCache[manifestPath]!;
    }
    final jsonString = await rootBundle.loadString(manifestPath);
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Root manifest is not a valid JSON object: $manifestPath');
    }
    final manifest = BoardManifest.fromJson(decoded);
    _manifestCache[manifestPath] = manifest;
    return manifest;
  }

  /// Loads and caches raw SVG content from rootBundle.
  Future<String> _loadRawSvg(String assetPath) async {
    if (_rawSvgCache.containsKey(assetPath)) {
      return _rawSvgCache[assetPath]!;
    }
    final content = await rootBundle.loadString(assetPath);
    _rawSvgCache[assetPath] = content;
    return content;
  }

  /// Processes an individual SVG component by extracting defs and body content,
  /// namespacing all IDs to avoid collisions, and rewriting references.
  _ProcessedAsset _processSvgComponent({
    required String rawSvg,
    required String prefix,
    required VoidCallback onCommonClipFound,
  }) {
    // Extract <defs>...</defs>
    final defsRegex = RegExp(r'<defs>(.*?)</defs>', dotAll: true);
    final defsMatch = defsRegex.firstMatch(rawSvg);
    String defsContent = defsMatch != null ? defsMatch.group(1)! : '';

    // Extract drawable body content (remove outer <svg...> and </svg>, and remove <defs>)
    String bodyContent = rawSvg.replaceAll(defsRegex, '')
        .replaceFirst(RegExp(r'^\s*<svg[^>]*>'), '')
        .replaceFirst(RegExp(r'</svg>\s*$'), '')
        .trim();

    // Find all definition IDs defined in defs
    final idRegex = RegExp(r'id=["'']([^"'']+)["'']');
    final matches = idRegex.allMatches(defsContent);
    final idMap = <String, String>{};

    for (final m in matches) {
      final oldId = m.group(1)!;
      // Check if this is the shared 688x688 outer canvas clipPath
      if (oldId.startsWith('clip0_')) {
        idMap[oldId] = 'board_canvas_clip';
        onCommonClipFound();
      } else {
        idMap[oldId] = '$prefix$oldId';
      }
    }

    // Rename IDs inside defs and rewrite references
    for (final entry in idMap.entries) {
      final oldId = entry.key;
      final newId = entry.value;

      // If it's the common canvas clip, strip it from individual defs since it's declared globally
      if (newId == 'board_canvas_clip') {
        final escapedOldId = RegExp.escape(oldId);
        defsContent = defsContent.replaceAll(
          RegExp('<clipPath id=["\']$escapedOldId["\']>\\s*<rect width="688" height="688" fill="white"/>\\s*</clipPath>', dotAll: true),
          '',
        );
      } else {
        defsContent = defsContent.replaceAll('id="$oldId"', 'id="$newId"')
            .replaceAll("id='$oldId'", "id='$newId'");
      }

      // Rewrite url(#oldId)
      final urlOld = 'url(#$oldId)';
      final urlNew = 'url(#$newId)';
      defsContent = defsContent.replaceAll(urlOld, urlNew);
      bodyContent = bodyContent.replaceAll(urlOld, urlNew);

      // Rewrite href="#oldId" and xlink:href="#oldId"
      defsContent = defsContent.replaceAll('href="#$oldId"', 'href="#$newId"')
          .replaceAll('xlink:href="#$oldId"', 'xlink:href="#$newId"');
      bodyContent = bodyContent.replaceAll('href="#$oldId"', 'href="#$newId"')
          .replaceAll('xlink:href="#$oldId"', 'xlink:href="#$newId"');
    }

    return _ProcessedAsset(
      defsContent: defsContent.trim(),
      bodyContent: bodyContent,
    );
  }

  /// Stores a composed SVG in the LRU cache, evicting the oldest unpinned theme if full.
  void _storeInComposedCache(String themeId, String svgString) {
    if (_composedSvgCache.length >= _maxComposedCacheSize) {
      // Find least recently used key that is not pinned
      String? evictKey;
      for (final key in _composedSvgCache.keys) {
        if (key != _pinnedThemeId) {
          evictKey = key;
          break;
        }
      }
      if (evictKey != null) {
        _composedSvgCache.remove(evictKey);
      }
    }
    _composedSvgCache[themeId] = svgString;
  }
}
