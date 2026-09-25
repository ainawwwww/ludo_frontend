import 'dart:ui';

/// Canvas configuration for the reconstructed board.
class BoardCanvas {
  final double width;
  final double height;
  final List<double> viewBox;

  const BoardCanvas({
    required this.width,
    required this.height,
    required this.viewBox,
  });

  Rect get viewBoxRect => Rect.fromLTWH(
        viewBox.isNotEmpty ? viewBox[0] : 0.0,
        viewBox.length > 1 ? viewBox[1] : 0.0,
        viewBox.length > 2 ? viewBox[2] : width,
        viewBox.length > 3 ? viewBox[3] : height,
      );

  factory BoardCanvas.fromJson(Map<String, dynamic> json) {
    final rawVb = json['viewBox'] as List<dynamic>? ?? [0.0, 0.0, 688.0, 688.0];
    return BoardCanvas(
      width: (json['width'] as num?)?.toDouble() ?? 688.0,
      height: (json['height'] as num?)?.toDouble() ?? 688.0,
      viewBox: rawVb.map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'viewBox': viewBox,
      };
}

/// Metadata for a unique SVG component asset within a board theme.
class BoardAssetMeta {
  final String id;
  final String file;
  final String role;
  final String color;
  final String signature;
  final double intrinsicWidth;
  final double intrinsicHeight;

  const BoardAssetMeta({
    required this.id,
    required this.file,
    required this.role,
    required this.color,
    required this.signature,
    required this.intrinsicWidth,
    required this.intrinsicHeight,
  });

  factory BoardAssetMeta.fromJson(Map<String, dynamic> json) {
    return BoardAssetMeta(
      id: json['id']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      signature: json['signature']?.toString() ?? '',
      intrinsicWidth: (json['intrinsicWidth'] as num?)?.toDouble() ?? 0.0,
      intrinsicHeight: (json['intrinsicHeight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'file': file,
        'role': role,
        'color': color,
        'signature': signature,
        'intrinsicWidth': intrinsicWidth,
        'intrinsicHeight': intrinsicHeight,
      };
}

/// Individual placement record positioning an SVG component on the board canvas.
class BoardPlacement {
  final int assetIndex;
  final double x;
  final double y;
  final double width;
  final double height;
  final int z;

  const BoardPlacement({
    required this.assetIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.z,
  });

  factory BoardPlacement.fromJson(Map<String, dynamic> json) {
    return BoardPlacement(
      assetIndex: (json['asset'] as num?)?.toInt() ?? 0,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      z: (json['z'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'asset': assetIndex,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'z': z,
      };
}

/// Typed model for a Ludo board theme manifest.json file.
class BoardManifest {
  final int schemaVersion;
  final String sourceFile;
  final BoardCanvas canvas;
  final String coordinateSystem;
  final List<BoardAssetMeta> assetIndex;
  final List<BoardPlacement> placements;

  const BoardManifest({
    required this.schemaVersion,
    required this.sourceFile,
    required this.canvas,
    required this.coordinateSystem,
    required this.assetIndex,
    required this.placements,
  });

  factory BoardManifest.fromJson(Map<String, dynamic> json) {
    final version = (json['schemaVersion'] as num?)?.toInt() ?? 1;
    final canvas = BoardCanvas.fromJson(json['canvas'] as Map<String, dynamic>? ?? {});
    final rawAssets = json['assetIndex'] as List<dynamic>? ?? [];
    final assetIndex = rawAssets
        .map((e) => BoardAssetMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    final rawPlacements = json['placements'] as List<dynamic>? ?? [];
    final placements = rawPlacements
        .map((e) => BoardPlacement.fromJson(e as Map<String, dynamic>))
        .toList();

    return BoardManifest(
      schemaVersion: version,
      sourceFile: json['sourceFile']?.toString() ?? '',
      canvas: canvas,
      coordinateSystem: json['coordinateSystem']?.toString() ?? 'SVG pixels, origin at board top-left',
      assetIndex: assetIndex,
      placements: placements,
    );
  }

  /// Validates the manifest data. Returns null if valid, or an error description string if invalid.
  String? validate() {
    if (schemaVersion < 1) {
      return 'Unsupported schemaVersion: $schemaVersion';
    }
    if (canvas.width <= 0 || canvas.height <= 0) {
      return 'Invalid canvas dimensions: ${canvas.width}x${canvas.height}';
    }
    if (assetIndex.isEmpty) {
      return 'Asset index is empty';
    }
    final assetIds = <String>{};
    for (int i = 0; i < assetIndex.length; i++) {
      final a = assetIndex[i];
      if (a.id.isEmpty) {
        return 'Asset at index $i has empty id';
      }
      if (!assetIds.add(a.id)) {
        return 'Duplicate asset id: ${a.id} at index $i';
      }
      if (a.file.isEmpty) {
        return 'Asset ${a.id} has empty file path';
      }
      if (a.intrinsicWidth < 0 || a.intrinsicHeight < 0) {
        return 'Asset ${a.id} has negative intrinsic dimensions';
      }
    }
    if (placements.isEmpty) {
      return 'Placements list is empty';
    }
    for (int i = 0; i < placements.length; i++) {
      final p = placements[i];
      if (p.assetIndex < 0 || p.assetIndex >= assetIndex.length) {
        return 'Placement $i references out-of-bounds asset index: ${p.assetIndex} (max: ${assetIndex.length - 1})';
      }
      if (p.width < 0 || p.height < 0) {
        return 'Placement $i has negative dimensions: ${p.width}x${p.height}';
      }
      if (p.x.isNaN || p.x.isInfinite || p.y.isNaN || p.y.isInfinite) {
        return 'Placement $i has invalid coordinates: (${p.x}, ${p.y})';
      }
    }
    return null;
  }
}
