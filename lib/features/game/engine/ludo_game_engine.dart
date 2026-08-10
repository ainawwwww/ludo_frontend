/// Ludo Game Engine
/// 
/// A pure Dart class that handles all Ludo game logic independently of UI.
/// Includes dice rolling, piece movement, capturing, turn management, and win conditions.
library;

import 'dart:math';

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
  }) : pieces = List.generate(4, (index) => LudoPiece(
    id: '${color.name}_piece_$index',
    color: color,
  ));
  
  /// Get pieces in a specific state
  List<LudoPiece> getPiecesInState(PieceState state) {
    return pieces.where((piece) => piece.state == state).toList();
  }
  
  /// Get count of finished pieces
  int get finishedCount => pieces.where((p) => p.state == PieceState.finished).length;
  
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
  static const int homeStretchLength = 6; // Colored path to center
  
  // Start positions on shared path (0-51) for each color
  static const Map<PlayerColor, int> startPositions = {
    PlayerColor.red: 0,      // Bottom-left, starts at index 0
    PlayerColor.green: 13,   // Top-left, starts at index 13
    PlayerColor.yellow: 26,  // Top-right, starts at index 26
    PlayerColor.blue: 39,    // Bottom-right, starts at index 39
  };
  
  // Entry point into home stretch (after 51 steps from start)
  static const int stepsToHomeStretch = 51;
  
  // Safe tiles (no capture allowed) - indices on shared path
  static const Set<int> safeTiles = {
    0,   // Red start
    8,   // Safe tile after red start
    13,  // Green start
    21,  // Safe tile after green start
    26,  // Yellow start
    34,  // Safe tile after yellow start
    39,  // Blue start
    47,  // Safe tile after blue start
  };
  
  LudoGameEngine({
    required this.players,
    this.currentPlayerIndex = 0,
    this.consecutiveSixes = 0,
    this.lastDiceRoll = 0,
  });
  
  /// Get current player
  LudoPlayer get currentPlayer => players[currentPlayerIndex];
  
  /// Roll the dice
  DiceRollResult rollDice() {
    final random = Random();
    final value = random.nextInt(6) + 1; // 1-6
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
      
      // If entering home stretch
      if (newStepsMoved > stepsToHomeStretch) {
        // Check if exact fit into home stretch
        final homeStretchSteps = newStepsMoved - stepsToHomeStretch;
        return homeStretchSteps <= homeStretchLength;
      }
      
      // Otherwise, always valid on shared path
      return true;
    }
    
    // Home stretch piece - check exact fit to finish
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
    
    // Check if entering home stretch
    if (newStepsMoved > stepsToHomeStretch) {
      // Move to home stretch
      final homeStretchSteps = newStepsMoved - stepsToHomeStretch;
      
      if (homeStretchSteps > homeStretchLength) {
        return MoveResult.invalid('Overshoots home stretch');
      }
      
      final updatedPiece = piece.copyWith(
        state: PieceState.homeStretch,
        currentPosition: homeStretchSteps - 1, // 0-indexed in home stretch
        stepsMoved: newStepsMoved,
      );
      
      players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;
      
      // Check if reached finish
      if (homeStretchSteps == homeStretchLength) {
        return _finishPiece(piece, pieceIndex);
      }
      
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
  MoveResult _moveHomeStretchPiece(LudoPiece piece, int pieceIndex, int diceValue) {
    final fromPosition = piece.currentPosition;
    final toPosition = fromPosition + diceValue;
    
    if (toPosition > homeStretchLength) {
      return MoveResult.invalid('Overshoots finish');
    }
    
    final updatedPiece = piece.copyWith(
      currentPosition: toPosition,
      stepsMoved: piece.stepsMoved + diceValue,
    );
    
    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;
    
    // Check if reached finish
    if (toPosition == homeStretchLength) {
      return _finishPiece(piece, pieceIndex);
    }
    
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
      stepsMoved: piece.stepsMoved,
    );
    
    players[currentPlayerIndex].pieces[pieceIndex] = updatedPiece;
    
    return MoveResult(
      success: true,
      pieceId: piece.id,
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
    if (lastRollResult?.isSix == true && 
        lastRollResult?.wasThirdSix != true) {
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
  
  /// Pass turn to next player
  void nextTurn() {
    consecutiveSixes = 0;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }
  
  /// Check if any player has won
  LudoPlayer? checkWinner() {
    for (final player in players) {
      if (player.hasWon) {
        return player;
      }
    }
    return null;
  }
  
  /// Get game state summary (for UI display)
  Map<String, dynamic> getGameState() {
    return {
      'currentPlayerIndex': currentPlayerIndex,
      'currentPlayerColor': currentPlayer.color.name,
      'lastDiceRoll': lastDiceRoll,
      'consecutiveSixes': consecutiveSixes,
      'players': players.map((p) => {
        'id': p.id,
        'color': p.color.name,
        'isHuman': p.isHuman,
        'finishedCount': p.finishedCount,
        'pieces': p.pieces.map((piece) => {
          'id': piece.id,
          'state': piece.state.name,
          'currentPosition': piece.currentPosition,
          'stepsMoved': piece.stepsMoved,
        }).toList(),
      }).toList(),
    };
  }
}
