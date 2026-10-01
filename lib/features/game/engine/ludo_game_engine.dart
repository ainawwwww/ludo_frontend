/// Ludo Game Engine
///
/// A pure Dart class that handles all Ludo game logic independently of UI.
/// Includes dice rolling, piece movement, capturing, turn management, and win conditions.
library;

import 'dart:math';

import '../models/team_assignment.dart';

// ==================== ENUMS ====================

/// Player colors in Ludo
enum PlayerColor {
  red,
  green,
  yellow,
  blue,
}

/// States a piece can be in
enum PieceState {
  /// Piece is in the yard/base, not on board yet
  home,

  /// Piece is moving on the main shared track
  active,

  /// Piece is on the colored home stretch path
  homeStretch,

  /// Piece has reached the center (finished)
  finished,
}

// ==================== DATA STRUCTURES ====================

/// Represents a single piece (goti)
class LudoPiece {
  final String id;
  final PlayerColor color;
  PieceState state;
  int currentPosition; // Path index (0-51 for active, 0-5 for homeStretch)
  int stepsMoved; // Total steps from start

  LudoPiece({
    required this.id,
    required this.color,
    this.state = PieceState.home,
    this.currentPosition = 0,
    this.stepsMoved = 0,
  });

  /// Create a copy of this piece with updated values
  LudoPiece copyWith({
    PieceState? state,
    int? currentPosition,
    int? stepsMoved,
  }) {
    return LudoPiece(
      id: id,
      color: color,
      state: state ?? this.state,
      currentPosition: currentPosition ?? this.currentPosition,
      stepsMoved: stepsMoved ?? this.stepsMoved,
    );
  }
}

/// Represents a player in the game
class LudoPlayer {
  final String id;
  final PlayerColor color;
  final List<LudoPiece> pieces;
  bool isHuman; // true for human player, false for AI

  LudoPlayer({
    required this.id,
    required this.color,
    this.isHuman = true,
  }) : pieces = List.generate(
            4,
            (index) => LudoPiece(
                  id: '${color.name}_piece_$index',
                  color: color,
                ));

  /// Get pieces in a specific state
  List<LudoPiece> getPiecesInState(PieceState state) {
    return pieces.where((piece) => piece.state == state).toList();
  }

  /// Get count of finished pieces
  int get finishedCount =>
      pieces.where((p) => p.state == PieceState.finished).length;

  /// Check if player has won (all 4 pieces finished)
  bool get hasWon => finishedCount == 4;
}

/// Result of a dice roll
class DiceRollResult {
  final int value;
  final bool isSix;
  final bool wasThirdSix; // If this is the 3rd consecutive 6

  DiceRollResult({
    required this.value,
    required this.isSix,
    this.wasThirdSix = false,
  });
}

/// Result of a piece move
class MoveResult {
  final bool success;
  final String? pieceId;
  final int fromPosition;
  final int toPosition;
  final bool captured; // Whether this move captured an opponent
  final String? capturedPieceId; // ID of captured piece
  final bool reachedFinish; // Whether this move finished the piece
  final bool wasInvalid; // If the move was invalid (overshoot, etc.)
  final String? invalidReason;

  MoveResult({
    required this.success,
    this.pieceId,
    this.fromPosition = 0,
    this.toPosition = 0,
    this.captured = false,
    this.capturedPieceId,
    this.reachedFinish = false,
    this.wasInvalid = false,
    this.invalidReason,
  });

  factory MoveResult.invalid(String reason) {
    return MoveResult(
      success: false,
      wasInvalid: true,
      invalidReason: reason,
    );
  }
}

// ==================== GAME ENGINE ====================

class LudoGameEngine {
  // Game state
  final List<LudoPlayer> players;
  int currentPlayerIndex;
  int consecutiveSixes;
  int lastDiceRoll;
  DiceRollResult? lastRollResult;

  // Board configuration
  static const int sharedPathLength = 52; // Main outer track tiles
  static const int maxMainTrackSteps = 50; // Steps 0..50 on shared track
  static const int stepsToHomeStretch = 50; // Last step on shared track before turning into home column
  static const int homeStretchLength = 5; // 5 colored column tiles (steps 51..55)
  static const int totalStepsToFinish = 56; // Step 56 is Home/center finish

  // Start positions on shared path (0-51) for each color
  static const Map<PlayerColor, int> startPositions = {
    PlayerColor.red: 0, // Bottom-left, starts at index 0
    PlayerColor.green: 13, // Top-left, starts at index 13
    PlayerColor.yellow: 26, // Top-right, starts at index 26
    PlayerColor.blue: 39, // Bottom-right, starts at index 39
  };

  // Safe tiles (no capture allowed) - indices on shared path
  static const Set<int> safeTiles = {
    0, // Red start
    8, // Safe tile after red start
    13, // Green start
    21, // Safe tile after green start
    26, // Yellow start
    34, // Safe tile after yellow start
    39, // Blue start
    47, // Safe tile after blue start
  };

  final bool isTeamMode;

  LudoGameEngine({
    required this.players,
    this.currentPlayerIndex = 0,
    this.consecutiveSixes = 0,
    this.lastDiceRoll = 0,
    this.isTeamMode = false,
  });

  /// Get current player
  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  /// Roll the dice (optionally passing a pre-rolled/settled value)
  DiceRollResult rollDice({int? forcedValue}) {
    final value = (forcedValue != null && forcedValue >= 1 && forcedValue <= 6)
        ? forcedValue
        : (Random().nextInt(6) + 1);
    final isSix = value == 6;

    consecutiveSixes = isSix ? consecutiveSixes + 1 : 0;
    final wasThirdSix = consecutiveSixes >= 3;

    lastDiceRoll = value;
    lastRollResult = DiceRollResult(
      value: value,
      isSix: isSix,
      wasThirdSix: wasThirdSix,
    );

    return lastRollResult!;
  }

  /// Get all valid moves for current player with given dice value
  List<String> getValidMoves(int diceValue) {
    final validPieceIds = <String>[];
    final player = currentPlayer;

    // Check if rolled 6 three times - no valid moves
    if (consecutiveSixes >= 3) {
      return validPieceIds;
    }

    for (final piece in player.pieces) {
      if (_canMovePiece(piece, diceValue)) {
        validPieceIds.add(piece.id);
      }
    }

    return validPieceIds;
  }

  /// Check if a specific piece can move with given dice value
  bool _canMovePiece(LudoPiece piece, int diceValue) {
    // Piece in HOME can only move on 6
    if (piece.state == PieceState.home) {
      return diceValue == 6;
    }

    // Finished pieces cannot move
    if (piece.state == PieceState.finished) {
      return false;
    }

    // Active piece - check if move is valid
    if (piece.state == PieceState.active) {
      // Calculate new position
      final newStepsMoved = piece.stepsMoved + diceValue;

      // If entering home stretch or finish
      if (newStepsMoved > stepsToHomeStretch) {
        return newStepsMoved <= totalStepsToFinish;
      }

      // Otherwise, always valid on shared path
      return true;
    }

    // Home stretch piece - check exact fit to finish (currentPosition is 0..4, finish is 5)
    if (piece.state == PieceState.homeStretch) {
      final newHomeStretchPos = piece.currentPosition + diceValue;
      return newHomeStretchPos <= homeStretchLength;
    }

    return false;
  }

  /// Move a piece by given dice value
  MoveResult movePiece(String pieceId, int diceValue) {
    final player = currentPlayer;
    final pieceIndex = player.pieces.indexWhere((p) => p.id == pieceId);

    if (pieceIndex == -1) {
      return MoveResult.invalid('Piece not found');
    }

    final piece = player.pieces[pieceIndex];

    // Check if move is valid
    if (!_canMovePiece(piece, diceValue)) {
      return MoveResult.invalid('Invalid move for this piece');
    }

    // Handle HOME state (unlocking)
    if (piece.state == PieceState.home) {
      return _unlockPiece(piece, pieceIndex);
    }

    // Handle ACTIVE state
    if (piece.state == PieceState.active) {
      return _moveActivePiece(piece, pieceIndex, diceValue);
    }

    // Handle HOME_STRETCH state
    if (piece.state == PieceState.homeStretch) {
      return _moveHomeStretchPiece(piece, pieceIndex, diceValue);
    }

    return MoveResult.invalid('Piece in finished state');
  }

  /// Unlock a piece from HOME to ACTIVE
  MoveResult _unlockPiece(LudoPiece piece, int pieceIndex) {
    final startPosition = startPositions[piece.color]!;

    // Update piece state
    final updatedPiece = piece.copyWith(
      state: PieceState.active,
      currentPosition: startPosition,
      stepsMoved: 0,
    );

    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;

    return MoveResult(
      success: true,
      pieceId: piece.id,
      fromPosition: -1, // HOME position
      toPosition: startPosition,
    );
  }

  /// Move an ACTIVE piece on the shared path
  MoveResult _moveActivePiece(LudoPiece piece, int pieceIndex, int diceValue) {
    final fromPosition = piece.currentPosition;
    final newStepsMoved = piece.stepsMoved + diceValue;

    // Check if entering home stretch or finish
    if (newStepsMoved > stepsToHomeStretch) {
      if (newStepsMoved > totalStepsToFinish) {
        return MoveResult.invalid('Overshoots home destination');
      }

      if (newStepsMoved == totalStepsToFinish) {
        final updatedPiece = piece.copyWith(
          stepsMoved: totalStepsToFinish,
        );
        players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;
        return _finishPiece(piece, pieceIndex);
      }

      // 1-indexed steps into home stretch: 1..5 for steps 51..55 -> 0-indexed 0..4
      final homeStretchSteps = newStepsMoved - stepsToHomeStretch;
      final updatedPiece = piece.copyWith(
        state: PieceState.homeStretch,
        currentPosition: homeStretchSteps - 1, // 0..4
        stepsMoved: newStepsMoved,
      );

      players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;

      return MoveResult(
        success: true,
        pieceId: piece.id,
        fromPosition: fromPosition,
        toPosition: -1, // Home stretch position
      );
    }

    // Move on shared path
    final toPosition = (fromPosition + diceValue) % sharedPathLength;
    final updatedPiece = piece.copyWith(
      currentPosition: toPosition,
      stepsMoved: newStepsMoved,
    );

    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;

    // Check for capture
    final captureResult = _checkCapture(piece.color, toPosition);

    return MoveResult(
      success: true,
      pieceId: piece.id,
      fromPosition: fromPosition,
      toPosition: toPosition,
      captured: captureResult != null,
      capturedPieceId: captureResult,
    );
  }

  /// Move a HOME_STRETCH piece
  MoveResult _moveHomeStretchPiece(
      LudoPiece piece, int pieceIndex, int diceValue) {
    final fromPosition = piece.currentPosition;
    final toPosition = fromPosition + diceValue;

    if (toPosition > homeStretchLength) {
      return MoveResult.invalid('Overshoots finish');
    }

    final newStepsMoved = piece.stepsMoved + diceValue;

    if (toPosition == homeStretchLength) {
      final updatedPiece = piece.copyWith(
        stepsMoved: totalStepsToFinish,
      );
      players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;
      return _finishPiece(piece, pieceIndex);
    }

    final updatedPiece = piece.copyWith(
      currentPosition: toPosition,
      stepsMoved: newStepsMoved,
    );

    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;

    return MoveResult(
      success: true,
      pieceId: piece.id,
      fromPosition: fromPosition,
      toPosition: toPosition,
    );
  }

  /// Finish a piece (reached center)
  MoveResult _finishPiece(LudoPiece piece, int pieceIndex) {
    final updatedPiece = piece.copyWith(
      state: PieceState.finished,
      currentPosition: homeStretchLength,
      stepsMoved: totalStepsToFinish,
    );

    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;

    return MoveResult(
      success: true,
      pieceId: piece.id,
      fromPosition: piece.currentPosition,
      toPosition: homeStretchLength,
      reachedFinish: true,
    );
  }

  /// Check if a move captures an opponent piece
  String? _checkCapture(PlayerColor attackerColor, int position) {
    // Cannot capture on safe tiles
    if (safeTiles.contains(position)) {
      return null;
    }

    // Check all other players' pieces
    for (final player in players) {
      if (player.color == attackerColor) continue;

      // 2v2 Team Mode: friendly-fire protection (cannot capture teammate)
      if (isTeamMode && TeamAssignment.areColorsTeammates(attackerColor, player.color)) {
        continue;
      }

      for (final piece in player.pieces) {
        if (piece.state == PieceState.active &&
            piece.currentPosition == position) {
          // Capture! Send piece back to HOME
          final pieceIndex = player.pieces.indexOf(piece);
          player.pieces[pieceIndex] = piece.copyWith(
            state: PieceState.home,
            currentPosition: 0,
            stepsMoved: 0,
          );
          return piece.id;
        }
      }
    }

    return null;
  }

  /// Check if current player should get another turn
  bool shouldGetAnotherTurn(MoveResult moveResult) {
    // Extra turn on rolling 6 (unless it was 3rd six)
    if (lastRollResult?.isSix == true && lastRollResult?.wasThirdSix != true) {
      return true;
    }

    // Extra turn on capture
    if (moveResult.captured) {
      return true;
    }

    // Extra turn on reaching finish
    if (moveResult.reachedFinish) {
      return true;
    }

    return false;
  }

  /// Pass turn to next player (skipping finished players in team mode)
  void nextTurn() {
    consecutiveSixes = 0;
    if (players.isEmpty) return;

    int attempts = 0;
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      attempts++;
    } while (isTeamMode && currentPlayer.hasWon && attempts < players.length);
  }

  /// Check if any player or team has won
  LudoPlayer? checkWinner() {
    if (isTeamMode) {
      final team1Finished = players
          .where((p) => TeamAssignment.teamForColor(p.color) == TeamAssignment.team1)
          .fold<int>(0, (sum, p) => sum + p.finishedCount);
      if (team1Finished == 8) {
        return players.firstWhere((p) => TeamAssignment.teamForColor(p.color) == TeamAssignment.team1);
      }

      final team2Finished = players
          .where((p) => TeamAssignment.teamForColor(p.color) == TeamAssignment.team2)
          .fold<int>(0, (sum, p) => sum + p.finishedCount);
      if (team2Finished == 8) {
        return players.firstWhere((p) => TeamAssignment.teamForColor(p.color) == TeamAssignment.team2);
      }

      return null;
    }

    for (final player in players) {
      if (player.hasWon) {
        return player;
      }
    }
    return null;
  }

  // ==================== SHARED VECTOR VALIDATION HELPERS ====================

  /// Evaluate relative-step move vectors for backend/frontend engine parity testing
  static Map<String, dynamic> validateStepMove({
    required Map<String, List<int>> allPlayerTokens,
    required String movingColorStr,
    required int tokenIndex,
    required int diceValue,
    String roomType = 'public',
  }) {
    final movingColor = movingColorStr.toLowerCase();
    final isTeam = roomType.toLowerCase() == 'team';

    final playerTokens = allPlayerTokens[movingColor];
    if (playerTokens == null || tokenIndex < 0 || tokenIndex >= playerTokens.length) {
      return {'is_valid': false, 'reason': 'Invalid token index or player color.'};
    }

    final currentSteps = playerTokens[tokenIndex];

    if (currentSteps == -1) {
      if (diceValue != 6) {
        return {'is_valid': false, 'reason': 'Requires a 6 to exit base.'};
      }
      return _buildStepResult(allPlayerTokens, movingColor, tokenIndex, currentSteps, 0, isTeam);
    } else if (currentSteps == 56) {
      return {'is_valid': false, 'reason': 'Token has already reached home.'};
    } else {
      final newSteps = currentSteps + diceValue;
      if (newSteps > 56) {
        return {'is_valid': false, 'reason': 'Move overshoots home destination.'};
      }
      return _buildStepResult(allPlayerTokens, movingColor, tokenIndex, currentSteps, newSteps, isTeam);
    }
  }

  static Map<String, dynamic> _buildStepResult(
    Map<String, List<int>> allTokens,
    String movingColor,
    int tokenIndex,
    int oldSteps,
    int newSteps,
    bool isTeam,
  ) {
    final startOffsets = {'red': 0, 'green': 13, 'yellow': 26, 'blue': 39};
    final safeSpots = {0, 8, 13, 21, 26, 34, 39, 47};

    final killedTokens = <Map<String, dynamic>>[];

    if (newSteps >= 0 && newSteps <= 50) {
      final movingOffset = startOffsets[movingColor] ?? 0;
      final targetGlobalPos = (movingOffset + newSteps) % 52;
      final isSafe = safeSpots.contains(targetGlobalPos);

      if (!isSafe) {
        final movingColorEnum = PlayerColor.values.byName(movingColor);
        for (final entry in allTokens.entries) {
          final color = entry.key;
          if (color == movingColor) continue;

          final colorEnum = PlayerColor.values.byName(color);
          if (isTeam && TeamAssignment.areColorsTeammates(movingColorEnum, colorEnum)) {
            continue;
          }

          final offset = startOffsets[color] ?? 0;
          final tokens = entry.value;
          for (int i = 0; i < tokens.length; i++) {
            final steps = tokens[i];
            if (steps >= 0 && steps <= 50) {
              final oppGlobalPos = (offset + steps) % 52;
              if (oppGlobalPos == targetGlobalPos) {
                killedTokens.add({
                  'color': color,
                  'token_index': i,
                  'old_steps': steps,
                  'new_steps': -1,
                });
              }
            }
          }
        }
      }
    }

    final simulated = <String, List<int>>{};
    for (final e in allTokens.entries) {
      simulated[e.key] = List<int>.from(e.value);
    }
    simulated[movingColor]![tokenIndex] = newSteps;

    bool hasWon = true;
    if (isTeam) {
      final movingColorEnum = PlayerColor.values.byName(movingColor);
      final teamId = TeamAssignment.teamForColor(movingColorEnum);
      for (final e in simulated.entries) {
        final colorEnum = PlayerColor.values.byName(e.key);
        if (TeamAssignment.teamForColor(colorEnum) == teamId) {
          for (final st in e.value) {
            if (st != 56) {
              hasWon = false;
              break;
            }
          }
        }
      }
    } else {
      for (final st in simulated[movingColor]!) {
        if (st != 56) {
          hasWon = false;
          break;
        }
      }
    }

    return {
      'is_valid': true,
      'color': movingColor,
      'token_index': tokenIndex,
      'old_steps': oldSteps,
      'new_steps': newSteps,
      'is_kill': killedTokens.isNotEmpty,
      'killed_tokens': killedTokens,
      'reached_home': newSteps == 56,
      'has_won': hasWon,
    };
  }

  static bool isPlayerFinished(List<int> tokens) {
    if (tokens.length < 4) return false;
    return tokens.every((st) => st == 56);
  }

  static bool shouldSkipTurn(List<int> tokens) {
    return isPlayerFinished(tokens);
  }

  static List<int> getMovableTokens(List<int> tokens, int diceValue) {
    if (shouldSkipTurn(tokens)) return [];
    final movable = <int>[];
    for (int i = 0; i < tokens.length; i++) {
      final st = tokens[i];
      if (st == -1) {
        if (diceValue == 6) movable.add(i);
      } else if (st < 56) {
        if (st + diceValue <= 56) movable.add(i);
      }
    }
    return movable;
  }

  /// Get game state summary (for UI display)
  Map<String, dynamic> getGameState() {
    return {
      'currentPlayerIndex': currentPlayerIndex,
      'currentPlayerColor': currentPlayer.color.name,
      'lastDiceRoll': lastDiceRoll,
      'consecutiveSixes': consecutiveSixes,
      'players': players
          .map((p) => {
                'id': p.id,
                'color': p.color.name,
                'isHuman': p.isHuman,
                'finishedCount': p.finishedCount,
                'pieces': p.pieces
                    .map((piece) => {
                          'id': piece.id,
                          'state': piece.state.name,
                          'currentPosition': piece.currentPosition,
                          'stepsMoved': piece.stepsMoved,
                        })
                    .toList(),
              })
          .toList(),
    };
  }
}
