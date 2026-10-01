import '../engine/ludo_game_engine.dart';

/// Single Source of Truth for 2v2 Team Seat & Color Assignments in Dart Frontend.
/// Mirrors App\Support\TeamAssignment in Laravel PHP.
abstract class TeamAssignment {
  static const int team1 = 1;
  static const int team2 = 2;

  /// Get Team ID (1 or 2) for a given 1-indexed seat position.
  static int teamForSeat(int seatPosition) {
    return (seatPosition == 1 || seatPosition == 3) ? team1 : team2;
  }

  /// Get partner's seat position for a given 1-indexed seat position.
  static int teammateSeat(int seatPosition) {
    switch (seatPosition) {
      case 1:
        return 3;
      case 3:
        return 1;
      case 2:
        return 4;
      case 4:
        return 2;
      default:
        return seatPosition;
    }
  }

  /// Get Team ID for a PlayerColor enum.
  static int teamForColor(PlayerColor color) {
    return (color == PlayerColor.red || color == PlayerColor.yellow)
        ? team1
        : team2;
  }

  /// Check if two seats are on the same team.
  static bool areTeammates(int seat1, int seat2) {
    if (seat1 == seat2) return false;
    return teamForSeat(seat1) == teamForSeat(seat2);
  }

  /// Check if two colors are on the same team.
  static bool areColorsTeammates(PlayerColor color1, PlayerColor color2) {
    if (color1 == color2) return false;
    return teamForColor(color1) == teamForColor(color2);
  }
}
