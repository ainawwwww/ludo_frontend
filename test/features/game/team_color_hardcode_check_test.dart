import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/models/team_assignment.dart';

void main() {
  group('Structural Compliance Check: Single Source of Truth for Team Seats/Colors', () {
    test('TeamAssignment defines canonical team pairing logic', () {
      expect(TeamAssignment.teamForSeat(1), equals(1));
      expect(TeamAssignment.teamForSeat(3), equals(1));
      expect(TeamAssignment.teamForSeat(2), equals(2));
      expect(TeamAssignment.teamForSeat(4), equals(2));

      expect(TeamAssignment.teammateSeat(1), equals(3));
      expect(TeamAssignment.teammateSeat(3), equals(1));
      expect(TeamAssignment.teammateSeat(2), equals(4));
      expect(TeamAssignment.teammateSeat(4), equals(2));
    });

    test('UI files use TeamAssignment and do not re-hardcode seat pairing rules', () {
      final uiFiles = [
        File('lib/features/rooms/screens/team_vs_screen.dart'),
        File('lib/features/rooms/screens/room_lobby_screen.dart'),
        File('lib/features/game/screens/ludo_board_screen.dart'),
      ];

      for (final file in uiFiles) {
        if (!file.existsSync()) continue;
        final content = file.readAsStringSync();

        // Verify no ad-hoc hardcoded pairing logic like `seat == 1 || seat == 2` for team 1
        expect(
          content.contains('seat == 1 || seat == 2'),
          isFalse,
          reason: '${file.path} contains hardcoded invalid seat pairing!',
        );
      }
    });
  });
}
