import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';

void main() {
  final file = File('test/fixtures/team_mode_engine_vectors.json');
  final content = file.readAsStringSync();
  final fixture = jsonDecode(content) as Map<String, dynamic>;
  final testCases = fixture['test_cases'] as List<dynamic>;

  group('Dart Engine 2v2 Team Mode Shared Vectors Parity', () {
    for (final rawCase in testCases) {
      final caseMap = rawCase as Map<String, dynamic>;
      final caseId = caseMap['id'] as String;

      test('vector: $caseId', () {
        final roomType = (caseMap['room_type'] as String?) ?? 'team';
        final movingColor = caseMap['moving_color'] as String;
        final rawTokens = caseMap['tokens'] as Map<String, dynamic>;
        final expected = caseMap['expected'] as Map<String, dynamic>;

        final tokens = <String, List<int>>{};
        for (final entry in rawTokens.entries) {
          tokens[entry.key] = (entry.value as List<dynamic>).map((e) => (e as num).toInt()).toList();
        }

        if (expected.containsKey('should_skip_turn')) {
          final playerTokens = tokens[movingColor]!;
          final isFinished = LudoGameEngine.isPlayerFinished(playerTokens);
          final shouldSkip = LudoGameEngine.shouldSkipTurn(playerTokens);
          final movable = LudoGameEngine.getMovableTokens(playerTokens, (caseMap['dice_value'] as num?)?.toInt() ?? 6);

          expect(isFinished, expected['is_finished'], reason: '[$caseId] is_finished mismatch');
          expect(shouldSkip, expected['should_skip_turn'], reason: '[$caseId] should_skip_turn mismatch');
          expect(movable, expected['movable_tokens'], reason: '[$caseId] movable_tokens mismatch');
          return;
        }

        final tokenIndex = (caseMap['token_index'] as num).toInt();
        final diceValue = (caseMap['dice_value'] as num).toInt();

        final result = LudoGameEngine.validateStepMove(
          allPlayerTokens: tokens,
          movingColorStr: movingColor,
          tokenIndex: tokenIndex,
          diceValue: diceValue,
          roomType: roomType,
        );

        expect(result['is_valid'], expected['is_valid'], reason: '[$caseId] is_valid mismatch');
        expect(result['new_steps'], expected['new_steps'], reason: '[$caseId] new_steps mismatch');

        if (expected.containsKey('is_kill')) {
          expect(result['is_kill'], expected['is_kill'], reason: '[$caseId] is_kill mismatch');
        }

        if (expected.containsKey('killed_tokens')) {
          final expKilled = expected['killed_tokens'] as List<dynamic>;
          final actKilled = result['killed_tokens'] as List<dynamic>;
          expect(actKilled.length, expKilled.length, reason: '[$caseId] killed_tokens count mismatch');

          for (int i = 0; i < expKilled.length; i++) {
            final expItem = expKilled[i] as Map<String, dynamic>;
            final actItem = actKilled[i] as Map<String, dynamic>;
            expect(actItem['color'], expItem['color']);
            expect(actItem['token_index'], expItem['token_index']);
            expect(actItem['new_steps'], expItem['new_steps']);
          }
        }

        if (expected.containsKey('has_won')) {
          expect(result['has_won'], expected['has_won'], reason: '[$caseId] has_won mismatch');
        }
      });
    }
  });
}
