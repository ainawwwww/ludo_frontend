import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';
import 'package:ludo_vibe/features/game/screens/ludo_board_screen.dart';

void main() {
  late Map<String, dynamic> fixtures;

  setUpAll(() {
    final file = File('test/fixtures/ludo_engine_test_vectors.json');
    expect(file.existsSync(), isTrue, reason: 'Fixture file must exist');
    fixtures = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  });

  test('LudoGameEngine constants match backend rules', () {
    final rules = fixtures['rules'] as Map<String, dynamic>;
    expect(LudoGameEngine.totalStepsToFinish, rules['total_steps_to_finish']);
    expect(LudoGameEngine.stepsToHomeStretch, rules['last_main_track_step']);
    expect(LudoGameEngine.homeStretchLength, rules['home_stretch_length']);
    expect(LudoGameEngine.sharedPathLength, 52);
  });

  test('Shared test vectors evaluate identically in LudoGameEngine', () {
    final testCases = fixtures['test_cases'] as List<dynamic>;

    for (final caseData in testCases) {
      final description = caseData['description'] as String;
      final colorStr = caseData['color'] as String;
      final currentStep = caseData['current_step'] as int;
      final dice = caseData['dice'] as int;
      final expectedValid = caseData['is_valid'] as bool;
      final expectedNewStep = caseData['new_step'] as int;
      final expectedFinished = caseData['is_finished'] as bool;

      final color = PlayerColor.values.byName(colorStr);
      final player = LudoPlayer(
        id: 'player_0',
        color: color,
        isHuman: true,
      );

      // Configure piece state based on currentStep
      final piece = player.pieces[0];
      if (currentStep == -1) {
        // Base
        piece.state = PieceState.home;
        piece.currentPosition = 0;
        piece.stepsMoved = 0;
      } else if (currentStep <= LudoGameEngine.stepsToHomeStretch) {
        // Active on shared track
        piece.state = PieceState.active;
        piece.currentPosition = (LudoGameEngine.startPositions[color]! + currentStep) % 52;
        piece.stepsMoved = currentStep;
      } else {
        // Home stretch
        piece.state = PieceState.homeStretch;
        piece.currentPosition = currentStep - 51; // 0..4
        piece.stepsMoved = currentStep;
      }

      final engine = LudoGameEngine(
        players: [player],
        currentPlayerIndex: 0,
      );

      final validMoves = engine.getValidMoves(dice);
      final canMove = validMoves.contains(piece.id);

      expect(canMove, expectedValid, reason: 'Valid check failed for $description');

      if (expectedValid) {
        final result = engine.movePiece(piece.id, dice);
        expect(result.success, isTrue, reason: 'Move failed for $description');
        expect(result.reachedFinish, expectedFinished, reason: 'Reached finish failed for $description');

        final updatedPiece = engine.currentPlayer.pieces[0];
        expect(updatedPiece.stepsMoved, expectedNewStep, reason: 'Steps moved mismatch for $description');

        if (expectedFinished) {
          expect(updatedPiece.state, PieceState.finished);
        }
      }
    }
  });

  test('LudoBoardScreen.getCoordinatesForStep matches shared fixture coordinates for all colors', () {
    final coordinates = fixtures['coordinates'] as Map<String, dynamic>;
    for (final color in PlayerColor.values) {
      final expectedCoords = (coordinates[color.name] as List<dynamic>).cast<List<dynamic>>();
      expect(expectedCoords.length, 57, reason: 'Expected 57 coordinates (steps 0..56) for ${color.name}');

      for (int step = 0; step <= 56; step++) {
        final expected = expectedCoords[step];
        final actual = LudoBoardScreen.getCoordinatesForStep(color, step);
        expect(
          [actual.$1, actual.$2],
          [expected[0], expected[1]],
          reason: 'Coordinate mismatch for ${color.name} at step $step',
        );
      }
    }
  });

  test('Full bot-vs-bot game simulation plays to completion under 56-step rule', () {
    final player1 = LudoPlayer(id: 'bot_red', color: PlayerColor.red, isHuman: false);
    final player2 = LudoPlayer(id: 'bot_yellow', color: PlayerColor.yellow, isHuman: false);
    final engine = LudoGameEngine(
      players: [player1, player2],
    );

    final random = Random(42);
    int turnCount = 0;
    const maxTurns = 10000;

    while (engine.checkWinner() == null && turnCount < maxTurns) {
      final roll = engine.rollDice();
      if (roll.wasThirdSix) {
        engine.nextTurn();
        turnCount++;
        continue;
      }

      final validMoves = engine.getValidMoves(roll.value);
      if (validMoves.isEmpty) {
        engine.nextTurn();
        turnCount++;
        continue;
      }

      final chosenPiece = validMoves[random.nextInt(validMoves.length)];
      final result = engine.movePiece(chosenPiece, roll.value);

      if (!engine.shouldGetAnotherTurn(result)) {
        engine.nextTurn();
      }
      turnCount++;
    }

    final winner = engine.checkWinner();
    expect(winner, isNotNull, reason: 'Game should reach a win condition within $maxTurns turns');
    expect(winner!.hasWon, isTrue, reason: 'Winning player must have hasWon == true');
    expect(winner.finishedCount, 4, reason: 'Winning player must have all 4 pieces finished');
    for (final piece in winner.pieces) {
      expect(piece.state, PieceState.finished);
      expect(piece.stepsMoved, LudoGameEngine.totalStepsToFinish);
    }
  });
}

