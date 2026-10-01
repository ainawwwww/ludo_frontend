import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/rooms/providers/team_room_provider.dart';
import 'package:ludo_vibe/features/rooms/screens/team_vs_screen.dart';

void main() {
  Widget buildSubject({
    required bool isSingle,
    int? entryFee,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: TeamVsScreen(
          isSingle: isSingle,
          entryFee: entryFee,
        ),
      ),
    );
  }

  group('TeamVsScreen State & Pathway Tests', () {
    testWidgets('renders CREATE/JOIN path with teammate-known state', (tester) async {
      await tester.pumpWidget(buildSubject(isSingle: false, entryFee: 500));
      await tester.pump();

      // Top VS illustration badge and coins label rendered
      expect(find.textContaining('Entry Coins'), findsOneWidget);
      expect(find.textContaining('500'), findsOneWidget);

      // Searching status badge rendered
      expect(find.textContaining('Searching for rival team...'), findsOneWidget);
    });

    testWidgets('renders SINGLE path with teammate-searching state', (tester) async {
      await tester.pumpWidget(buildSubject(isSingle: true, entryFee: 1000));
      await tester.pump();

      expect(find.textContaining('Entry Coins'), findsOneWidget);
      expect(find.textContaining('1000'), findsOneWidget);

      // Searching status badge rendered for teammate
      expect(find.textContaining('Searching for teammate...'), findsOneWidget);
    });
  });
}
