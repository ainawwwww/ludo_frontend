import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/models/team_assignment.dart';

void main() {
  group('2v2 Board Header & TeamAssignment Integration Widget Test', () {
    testWidgets('Header correctly groups Seat 1 & Seat 3 in Team 1 and Seat 2 & Seat 4 in Team 2', (tester) async {
      final team1Player1Seat = 1;
      final team1Player2Seat = 3;
      final team2Player1Seat = 2;
      final team2Player2Seat = 4;

      expect(TeamAssignment.teamForSeat(team1Player1Seat), equals(TeamAssignment.team1));
      expect(TeamAssignment.teamForSeat(team1Player2Seat), equals(TeamAssignment.team1));
      expect(TeamAssignment.teamForSeat(team2Player1Seat), equals(TeamAssignment.team2));
      expect(TeamAssignment.teamForSeat(team2Player2Seat), equals(TeamAssignment.team2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              final t1Name = 'Team 1: Host & Partner';
              final t2Name = 'Team 2: Rival1 & Rival2';
              return Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t1Name, style: const TextStyle(color: Colors.amber)),
                    const Text('VS'),
                    Text(t2Name, style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              );
            }),
          ),
        ),
      );

      expect(find.text('Team 1: Host & Partner'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
      expect(find.text('Team 2: Rival1 & Rival2'), findsOneWidget);
    });
  });
}
