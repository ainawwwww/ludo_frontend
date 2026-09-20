import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';

/// The 4 Home Quadrant Seats in a Ludo Board
enum Seat {
  tl, // Top-Left (Green)
  tr, // Top-Right (Yellow)
  bl, // Bottom-Left (Red)
  br, // Bottom-Right (Blue)
}

/// Helper mapping to connect PlayerColor directly to board quadrant Seat
extension PlayerColorSeatExtension on PlayerColor {
  Seat get seat {
    switch (this) {
      case PlayerColor.green:
        return Seat.tl;
      case PlayerColor.yellow:
        return Seat.tr;
      case PlayerColor.red:
        return Seat.bl;
      case PlayerColor.blue:
        return Seat.br;
    }
  }
}

/// Helper mapping from Seat to default player color & quadrant origin
extension SeatPlayerColorExtension on Seat {
  PlayerColor get defaultColor {
    switch (this) {
      case Seat.tl:
        return PlayerColor.green;
      case Seat.tr:
        return PlayerColor.yellow;
      case Seat.bl:
        return PlayerColor.red;
      case Seat.br:
        return PlayerColor.blue;
    }
  }

  /// 6x6 block origin in 15x15 grid cell units
  Offset get quadrantOrigin {
    switch (this) {
      case Seat.tl:
        return const Offset(0, 0);
      case Seat.tr:
        return const Offset(9, 0);
      case Seat.bl:
        return const Offset(0, 9);
      case Seat.br:
        return const Offset(9, 9);
    }
  }
}

/// Board Grid fractional bounds relative to total board width/height S
class ThemeGrid {
  final double left;
  final double top;
  final double size;
  final int cells;

  const ThemeGrid({
    required this.left,
    required this.top,
    required this.size,
    this.cells = 15,
  });

  factory ThemeGrid.fromJson(Map<String, dynamic> json) {
    return ThemeGrid(
      left: (json['left'] as num?)?.toDouble() ?? 0.0,
      top: (json['top'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 1.0,
      cells: (json['cells'] as num?)?.toInt() ?? 15,
    );
  }

  Rect toRect() => Rect.fromLTWH(left, top, size, size);
}

/// Represents a loaded board theme
class LudoTheme {
  final String id;
  final String name;
  final String boardAsset;
  final String previewAsset;
  final ThemeGrid grid;
  final Map<Seat, Color> seatColors;
  final List<Offset> homeSlots;
  final int price;

  const LudoTheme({
    required this.id,
    required this.name,
    required this.boardAsset,
    required this.previewAsset,
    required this.grid,
    required this.seatColors,
    required this.homeSlots,
    this.price = 0,
  });

  bool get isClassic => id == 'classic';

  static Color _parseHexColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hex.startsWith('#')) {
      if (hex.length == 7) buffer.write('ff');
      buffer.write(hex.substring(1));
    } else {
      buffer.write(hex);
    }
    final val = int.tryParse(buffer.toString(), radix: 16);
    return val != null ? Color(val) : fallback;
  }

  factory LudoTheme.fromJson(Map<String, dynamic> json, {int price = 0}) {
    final seatJson = json['seatColors'] as Map<String, dynamic>? ?? {};
    final seatColors = <Seat, Color>{
      Seat.tl: _parseHexColor(seatJson['tl'] as String?, const Color(0xFF0F9D58)),
      Seat.tr: _parseHexColor(seatJson['tr'] as String?, const Color(0xFFF4B400)),
      Seat.bl: _parseHexColor(seatJson['bl'] as String?, const Color(0xFFDB4437)),
      Seat.br: _parseHexColor(seatJson['br'] as String?, const Color(0xFF4285F4)),
    };

    final homeSlotsData = json['homeSlots'] as Map<String, dynamic>?;
    final rawSlots = homeSlotsData?['slots'] as List<dynamic>?;
    final homeSlots = <Offset>[];
    if (rawSlots != null) {
      for (final s in rawSlots) {
        if (s is List && s.length >= 2) {
          homeSlots.add(Offset(
            (s[0] as num).toDouble(),
            (s[1] as num).toDouble(),
          ));
        }
      }
    }
    if (homeSlots.isEmpty) {
      homeSlots.addAll(const [
        Offset(1.5, 1.5),
        Offset(4.5, 1.5),
        Offset(1.5, 4.5),
        Offset(4.5, 4.5),
      ]);
    }

    return LudoTheme(
      id: json['id'] as String? ?? 'theme',
      name: json['name'] as String? ?? 'Theme',
      boardAsset: json['board'] as String? ?? '',
      previewAsset: json['preview'] as String? ?? '',
      grid: ThemeGrid.fromJson(json['grid'] as Map<String, dynamic>? ?? {}),
      seatColors: seatColors,
      homeSlots: homeSlots,
      price: price,
    );
  }

  /// Default Free Classic Theme
  static const LudoTheme classic = LudoTheme(
    id: 'classic',
    name: 'Classic',
    boardAsset: '',
    previewAsset: 'assets/graphics/shop/04a_table_board_skins_named/Classic-2.png',
    grid: ThemeGrid(left: 0.0, top: 0.0, size: 1.0, cells: 15),
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
    price: 0,
  );
}
