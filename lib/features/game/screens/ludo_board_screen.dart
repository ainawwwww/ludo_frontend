import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/game/engine/ludo_game_engine.dart';
import 'package:ludo_vibe/features/game/widgets/ludo_3d_dice_widget.dart';
import 'package:ludo_vibe/features/profile/providers/profile_customization_provider.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

class LudoBoardScreen extends ConsumerStatefulWidget {
  const LudoBoardScreen({
    super.key,
    this.playerCount = 4,
    this.betAmount = 500,
  });

  final int playerCount;
  final int betAmount;

  @override
  ConsumerState<LudoBoardScreen> createState() => _LudoBoardScreenState();
}

class _LudoBoardScreenState extends ConsumerState<LudoBoardScreen> with TickerProviderStateMixin {
  // Game Engine
  late LudoGameEngine _gameEngine;
  
  // UI State
  final GlobalKey<Ludo3DDiceState> _diceKey = GlobalKey<Ludo3DDiceState>();
  String? _lastPrecachedDiceSkin;
  bool _isRolling = false;
  bool _isMuted = true;
  List<String> _validMovePieceIds = []; // Pieces that can move for current dice roll
  String? _selectedPieceId; // Currently selected piece for movement

  // Emojis lists and animated elements
  final List<String> _emojis = ['😂', '👍', '🔥', '😮', '👑', '😎', '👏', '💔'];
  final List<Widget> _floatingEmojis = [];
  String? _speechBubbleText;
  Timer? _speechBubbleTimer;
  Timer? _aiTurnTimer;
  
  // Arrow bounce animation
  late final AnimationController _arrowController;
  late final Animation<double> _arrowAnimation;

  // Board path coordinate mappings
  late final List<(int row, int col)> _sharedPath;
  late final Map<PlayerColor, List<(int row, int col)>> _homeStretchPaths;

  @override
  void initState() {
    super.initState();
    _initializeBoardPaths();
    _initializeGameEngine();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _arrowAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheDiceAssets();
  }

  void _precacheDiceAssets() {
    final skinKey = resolveEquippedDiceSkinKey(ref);
    if (_lastPrecachedDiceSkin == skinKey) return;
    _lastPrecachedDiceSkin = skinKey;

    for (int i = 1; i <= 6; i++) {
      precacheImage(
        AssetImage('assets/graphics/dice_skins/$skinKey/face_$i.png'),
        context,
      );
    }
    precacheImage(
      AssetImage('assets/graphics/dice_skins/$skinKey/idle.png'),
      context,
    );
  }

  void _initializeBoardPaths() {
    // Shared path - 52 tiles going clockwise around the board
    // The path forms a cross shape on the 15x15 grid
    // Starting from Red's start position (6,1) and going clockwise
    // Each color starts at: Red=0, Green=13, Yellow=26, Blue=39
    
    _sharedPath = [
      // Red's section (0-12): Starting at (6,1), going up left arm
      (6, 1), (5, 1), (4, 1), (3, 1), (2, 1), (1, 1), (0, 1),  // 0-6: up left arm
      // Top row going right (green section)
      (0, 2), (0, 3), (0, 4), (0, 5), (0, 6),                 // 7-11: to green stretch entry at (0,7)
      (0, 8),                                                   // 12: after green stretch entry
      
      // Green's section (13-25): Continuing from (0,8)
      (0, 9), (0, 10), (0, 11), (0, 12), (0, 13),             // 13-17: top row to corner
      // Down right arm (yellow section)
      (1, 13), (2, 13), (3, 13), (4, 13), (5, 13), (6, 13),  // 18-23: down right arm
      (7, 13),                                                  // 24: center of right arm
      (8, 13),                                                  // 25: after blue stretch entry at (8,13)
      
      // Yellow's section (26-38): Continuing from (8,13)
      (9, 13), (10, 13), (11, 13), (12, 13), (13, 13),        // 26-30: bottom row to corner
      // Left along bottom (blue section)
      (13, 12), (13, 11), (13, 10), (13, 9), (13, 8),        // 31-35: to red stretch entry at (13,7)
      (13, 6),                                                  // 36: after red stretch entry
      (13, 5),                                                  // 37: continuing left
      
      // Blue's section (39-51): Continuing from (13,5)
      (13, 4), (13, 3), (13, 2), (13, 1),                       // 39-42: bottom row to corner
      // Up left arm (red section)
      (13, 0), (12, 0), (11, 0), (10, 0), (9, 0), (8, 0),    // 43-48: up left arm
      (7, 0),                                                   // 49: center of left arm
      (6, 0),                                                   // 50: after yellow stretch entry at (6,0)
      (5, 0),                                                   // 51: completing the loop back toward red start
    ];

    // Home stretch paths (6 tiles each, leading to center at (7,7))
    // Index 0 is entry from shared path, index 5 is the center tile
    _homeStretchPaths = {
      PlayerColor.red: [
        (7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6),  // From left arm (col 0), going right to center
      ],
      PlayerColor.green: [
        (1, 7), (2, 7), (3, 7), (4, 7), (5, 7), (6, 7),  // From top arm (row 0), going down to center
      ],
      PlayerColor.yellow: [
        (7, 12), (7, 11), (7, 10), (7, 9), (7, 8), (7, 7),  // From right arm (col 13), going left to center
      ],
      PlayerColor.blue: [
        (12, 7), (11, 7), (10, 7), (9, 7), (8, 7), (7, 7),  // From bottom arm (row 13), going up to center
      ],
    };
  }

  void _initializeGameEngine() {
    // Create players based on playerCount
    final players = <LudoPlayer>[];
    
    // Always add Red player (human)
    players.add(LudoPlayer(
      id: 'player_0',
      color: PlayerColor.red,
      isHuman: true,
    ));
    
    // Add Yellow player (opponent)
    players.add(LudoPlayer(
      id: 'player_1',
      color: PlayerColor.yellow,
      isHuman: false,
    ));
    
    // Add Green and Blue for 4-player mode
    if (widget.playerCount == 4) {
      players.add(LudoPlayer(
        id: 'player_2',
        color: PlayerColor.green,
        isHuman: false,
      ));
      players.add(LudoPlayer(
        id: 'player_3',
        color: PlayerColor.blue,
        isHuman: false,
      ));
    }
    
    _gameEngine = LudoGameEngine(players: players);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _speechBubbleTimer?.cancel();
    _aiTurnTimer?.cancel();
    super.dispose();
  }

  // Reset/Restart Game
  void _resetGame() {
    _diceKey.currentState?.resetToIdle();
    setState(() {
      _initializeGameEngine();
      _validMovePieceIds = [];
      _selectedPieceId = null;
      _isRolling = false;
    });
    _speechBubbleTimer?.cancel();
    _aiTurnTimer?.cancel();
  }

  // Custom Leave Game Confirmation Dialog matching HTML palette
  Future<bool> _showLeaveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF241147), Color(0xFF1A0D38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4A2F8A), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.exit_to_app_rounded, color: Color(0xFFE6393F), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Leave Game?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to quit the current match? Your entry fee will be forfeited.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text(
                          'Stay',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE6393F), Color(0xFFAD2226)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(
                            'Leave',
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // Switch to next player turn
  void _nextTurn() {
    if (!mounted) return;
    _diceKey.currentState?.resetToIdle();
    setState(() {
      _gameEngine.nextTurn();
      _validMovePieceIds = [];
      _selectedPieceId = null;
    });

    // If next turn is an AI opponent
    if (!_gameEngine.currentPlayer.isHuman) {
      _aiTurnTimer = Timer(const Duration(milliseconds: 1500), () {
        _rollDiceAI();
      });
    }
  }

  // Handle settled dice roll result from LudoDice callback
  void _handleDiceRollResult(int diceValue) {
    if (!mounted) return;
    
    // Roll the dice in game engine with the settled value
    final rollResult = _gameEngine.rollDice(forcedValue: diceValue);
    
    setState(() {
      _isRolling = false;
    });
    
    // Check for third six - forfeit turn
    if (rollResult.wasThirdSix) {
      _showQuickChat('Three 6s! Turn forfeited');
      _nextTurn();
      return;
    }
    
    // Get valid moves
    final validMoves = _gameEngine.getValidMoves(rollResult.value);
    
    if (validMoves.isEmpty) {
      // No valid moves - skip turn
      _showQuickChat('No moves available');
      _nextTurn();
    } else if (validMoves.length == 1) {
      // Auto-move if only one valid piece
      _movePiece(validMoves.first);
    } else {
      if (_gameEngine.currentPlayer.isHuman) {
        // Multiple valid moves - let player choose
        setState(() {
          _validMovePieceIds = validMoves;
        });
      } else {
        // AI randomly chooses a valid piece
        final random = Random();
        final chosenPiece = validMoves[random.nextInt(validMoves.length)];
        _movePiece(chosenPiece);
      }
    }
  }

  // Trigger Dice Roll sequence for AI Opponents
  void _rollDiceAI() {
    if (!mounted || _gameEngine.currentPlayer.isHuman) return;
    final aiRollVal = Random().nextInt(6) + 1;
    setState(() {
      _isRolling = true;
      _gameEngine.lastDiceRoll = aiRollVal;
    });
  }

  // Move a piece (called after dice roll)
  void _movePiece(String pieceId) {
    final moveResult = _gameEngine.movePiece(pieceId, _gameEngine.lastDiceRoll);
    
    if (!moveResult.success) {
      _showQuickChat(moveResult.invalidReason ?? 'Invalid move');
      return;
    }
    
    _diceKey.currentState?.resetToIdle();

    setState(() {
      _selectedPieceId = null;
      _validMovePieceIds = [];
    });
    
    // Show feedback for special moves & play sound effects
    if (moveResult.captured) {
      SoundService().playPieceCapture();
      _showQuickChat('Captured!');
      _spawnFloatingEmoji('💥');
    } else {
      SoundService().playPieceMove();
    }
    
    if (moveResult.reachedFinish) {
      _showQuickChat('Finished!');
      _spawnFloatingEmoji('🎉');
    }
    
    // Check for winner
    final winner = _gameEngine.checkWinner();
    if (winner != null) {
      SoundService().playWinFanfare();
      _showQuickChat('${winner.color.name.toUpperCase()} wins!');
      _spawnFloatingEmoji('🏆');
      // Could end game here or continue for other players
    }
    
    // Determine if player gets another turn
    if (_gameEngine.shouldGetAnotherTurn(moveResult)) {
      // Same player rolls again
      if (!_gameEngine.currentPlayer.isHuman) {
        _aiTurnTimer = Timer(const Duration(milliseconds: 1000), () {
          _rollDiceAI();
        });
      }
    } else {
      // Pass turn to next player
      _nextTurn();
    }
  }

  void _toggleMic() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _spawnFloatingEmoji(String emoji) {
    final random = Random();
    final leftOffset = random.nextDouble() * 150 + 80;
    
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final positionAnim = Tween<double>(begin: 0.0, end: 300.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    final opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(controller);

    final scaleAnim = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );

    final widget = AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          bottom: 120 + positionAnim.value,
          left: leftOffset,
          child: Opacity(
            opacity: opacityAnim.value,
            child: Transform.scale(
              scale: scaleAnim.value,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      _floatingEmojis.add(widget);
    });

    controller.forward().then((_) {
      setState(() {
        _floatingEmojis.remove(widget);
      });
      controller.dispose();
    });
  }

  void _showQuickChat(String text) {
    _speechBubbleTimer?.cancel();
    setState(() {
      _speechBubbleText = text;
    });

    _speechBubbleTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _speechBubbleText = null;
      });
    });
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0D38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Emoji Expression',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _spawnFloatingEmoji(_emojis[index]);
                      },
                      child: Center(
                        child: Text(_emojis[index], style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0D38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter chat message...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pop(context);
                        _showQuickChat(controller.text);
                      }
                    },
                    icon: const Icon(Icons.send_rounded, color: Color(0xFFFFD200)),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Wrap(
                spacing: 8,
                children: [
                  'Aha!', 'Good game!', 'Play fast please!', 'Oops!', 'Nice roll!'
                ].map((msg) {
                  return ActionChip(
                    backgroundColor: Colors.white10,
                    label: Text(msg, style: const TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      _showQuickChat(msg);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  void _showSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool soundOn = _isSoundEnabled;
        bool musicOn = _isMusicEnabled;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C135C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Settings', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up, color: Colors.white),
                    title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: soundOn,
                      onChanged: (val) {
                        setModalState(() => soundOn = val);
                        setState(() => _isSoundEnabled = val);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.white),
                    title: const Text('Music', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: musicOn,
                      onChanged: (val) {
                        setModalState(() => musicOn = val);
                        setState(() => _isMusicEnabled = val);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    title: const Text('Leave Game', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      Navigator.of(dialogContext).pop(); // close settings dialog
                      final leave = await _showLeaveDialog();
                      if (leave && mounted) {
                        context.go(AppConstants.homeRoute);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customization = ref.watch(profileCustomizationProvider);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showLeaveDialog();
        if (shouldLeave && mounted) {
          context.go(AppConstants.homeRoute);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0620),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Theme Wallpaper Background Overlay (if selected) or Deep Violet Gradient
            Positioned.fill(
              child: Image.asset(
                customization.currentTheme.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A0A3A), Color(0xFF2B1160), Color(0xFF150733)],
                    ),
                  ),
                ),
              ),
            ),
            
            // Dark gameplay vignette to ensure the ludo board remains 100% focused & high-contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.65),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Soft cloud glow (top-left)
            Positioned(
              top: -90 * scale,
              left: -60 * scale,
              child: Container(
                width: 260 * scale,
                height: 260 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0)],
                  ),
                ),
              ),
            ),

            // Soft cloud glow (bottom-right)
            Positioned(
              bottom: -120 * scale,
              right: -80 * scale,
              child: Container(
                width: 320 * scale,
                height: 320 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF785AFF).withOpacity(0.25), const Color(0xFF785AFF).withOpacity(0)],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // TOP BAR
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                    child: Row(
                      children: [
                        // Settings icon-btn
                        _buildTopBarBtn(
                          onTap: _showSettings,
                          scale: scale,
                          child: Icon(Icons.settings_rounded, color: const Color(0xFFCFC9E8), size: 20 * scale),
                        ),
                        SizedBox(width: 8 * scale),
                        // Trophy Leaderboard icon-btn
                        _buildTopBarBtn(
                          onTap: () {
                            _spawnFloatingEmoji('🏆');
                          },
                          scale: scale,
                          child: Icon(Icons.emoji_events_rounded, color: const Color(0xFFFFCF42), size: 20 * scale),
                        ),
                        const Spacer(),
                        // Spectator Pill in center
                        Container(
                          width: 130 * scale,
                          height: 34 * scale,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A0E38), Color(0xFF120826)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(17 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Spectators',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE6E2F5),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 1 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFCFC9E8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Wallet Button on right
                        _buildTopBarBtn(
                          onTap: () {
                            _spawnFloatingEmoji('💎');
                          },
                          scale: scale,
                          isWallet: true,
                          child: Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF3AA0D8), size: 20 * scale),
                        ),
                      ],
                    ),
                  ),
                  
                  // PROFILE ROW (Opponents at the top)
                  Padding(
                    padding: EdgeInsets.only(top: 14 * scale, bottom: 8 * scale, right: 16 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Display opponents avatars based on player count
                        ..._buildOpponentAvatars(scale),
                      ],
                    ),
                  ),
                  
                  // BOARD - Using individual tile assets
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            padding: EdgeInsets.all(6 * scale),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5A2A18), Color(0xFF3A1810), Color(0xFF2A0F0A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.55),
                                  blurRadius: 18 * scale,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9 * scale),
                              child: Column(
                                children: List.generate(15, (row) {
                                  return Expanded(
                                    child: Row(
                                      children: List.generate(15, (col) {
                                        return Expanded(
                                          child: _buildLudoCell(row, col, scale),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // ARROW
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _arrowAnimation.value),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4 * scale),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: const Color(0xFF3FD45A),
                            size: 30 * scale,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // PLAYER PANEL
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Player avatar
                        _buildAvatarBlock(
                          player: _gameEngine.players.firstWhere((p) => p.isHuman),
                          avatarAsset: 'assets/graphics/musician_avatar.png',
                          scale: scale,
                          isPlayer: true,
                        ),
                        SizedBox(width: 14 * scale),
                        // 3D Reusable Animated Dice with equipped skin & callback
                        Ludo3DDiceWidget(
                          key: _diceKey,
                          size: 54 * scale,
                          isEnabled: _gameEngine.currentPlayer.isHuman && !_isRolling,
                          isRollingExternal: _isRolling && !_gameEngine.currentPlayer.isHuman,
                          targetValue: _gameEngine.lastDiceRoll > 0 ? _gameEngine.lastDiceRoll : null,
                          onRollStart: () {
                            setState(() {
                              _isRolling = true;
                            });
                          },
                          onRollComplete: (diceValue) {
                            _handleDiceRollResult(diceValue);
                          },
                        ),
                        SizedBox(width: 14 * scale),
                        // Refresh button
                        GestureDetector(
                          onTap: _resetGame,
                          child: Container(
                            width: 34 * scale,
                            height: 34 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2A2F45), Color(0xFF171A29)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(Icons.refresh_rounded, color: const Color(0xFF8FD0FF), size: 18 * scale),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 10 * scale),
                  
                  // BOTTOM CONTROLS
                  Padding(
                    padding: EdgeInsets.only(bottom: 12 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mic Button
                        _buildBottomBtn(
                          onTap: _toggleMic,
                          scale: scale,
                          isMic: true,
                          child: Icon(
                            _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: const Color(0xFFA9ADC2),
                            size: 18 * scale,
                          ),
                        ),
                        SizedBox(width: 14 * scale),
                        // Emoji Button
                        _buildBottomBtn(
                          onTap: _showEmojiPicker,
                          scale: scale,
                          isEmoji: true,
                          child: Icon(
                            Icons.emoji_emotions_outlined,
                            color: const Color(0xFF3A2A12),
                            size: 22 * scale,
                          ),
                        ),
                        SizedBox(width: 14 * scale),
                        // Chat Button
                        _buildBottomBtn(
                          onTap: _showChatInput,
                          scale: scale,
                          isChat: true,
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: const Color(0xFF3A2A12),
                            size: 22 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Speech Bubble overlay above player avatar
            if (_speechBubbleText != null)
              Positioned(
                bottom: 120 * scale,
                left: 30 * scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Text(
                    _speechBubbleText!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

            // Floating Emojis Layer
            ..._floatingEmojis,
          ],
        ),
      ),
    );
  }

  // Top bar icon buttons helper
  Widget _buildTopBarBtn({
    required VoidCallback onTap,
    required double scale,
    required Widget child,
    bool isWallet = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (isWallet ? 44 : 40) * scale,
        height: 40 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2F1A5C), Color(0xFF1C0E3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  // Bottom control buttons helper
  Widget _buildBottomBtn({
    required VoidCallback onTap,
    required double scale,
    required Widget child,
    bool isMic = false,
    bool isEmoji = false,
    bool isChat = false,
  }) {
    double width = 42;
    if (isChat) width = 64;
    
    Gradient gradient = const LinearGradient(
      colors: [Color(0xFF3D4256), Color(0xFF22283B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    
    if (isEmoji || isChat) {
      gradient = const LinearGradient(
        colors: [Color(0xFFFFB23D), Color(0xFFE6820F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * scale,
        height: 42 * scale,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(21 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  // Build opponent avatars based on game engine players
  List<Widget> _buildOpponentAvatars(double scale) {
    final avatars = <Widget>[];
    
    for (final player in _gameEngine.players) {
      if (player.isHuman) continue; // Skip human player
      
      avatars.add(_buildAvatarBlock(
        player: player,
        avatarAsset: 'assets/graphics/wealthy_avatar.png',
        scale: scale,
      ));
      
      avatars.add(SizedBox(width: 8 * scale));
    }
    
    return avatars;
  }

  // Opponent/Player circular avatars with gold border and level badge
  Widget _buildAvatarBlock({
    required LudoPlayer player,
    required String avatarAsset,
    required double scale,
    bool isPlayer = false,
  }) {
    final isTurnActive = _gameEngine.currentPlayer.id == player.id;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56 * scale,
          height: 56 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isTurnActive ? const Color(0xFF4BCF6D) : const Color(0xFFE0A83A),
              width: 3 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: isTurnActive ? const Color(0xFF4BCF6D).withOpacity(0.5) : Colors.black45,
                blurRadius: isTurnActive ? 8 : 4,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              avatarAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF3A3F52),
                child: const Icon(Icons.person, color: Colors.white70),
              ),
            ),
          ),
        ),
        // Mini badge at the bottom-right
        Positioned(
          bottom: -2 * scale,
          right: -2 * scale,
          child: Container(
            width: 18 * scale,
            height: 18 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9D3D), Color(0xFFE6720F)],
              ),
              border: Border.all(color: const Color(0xFF2A1152), width: 2),
            ),
            child: Center(
              child: Text(
                isPlayer ? 'P' : '${player.finishedCount}',
                style: TextStyle(
                  fontSize: 8 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Draw board cell layout grids (15x15 standard track slots matching Figma reference)
  Widget _buildLudoCell(int row, int col, double scale) {
    // Quadrant: GREEN top-left base (Row 0-5, Col 0-5)
    if (row < 6 && col < 6) {
      if (row == 0 && col == 0) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 6.0,
              heightFactor: 6.0,
              alignment: Alignment.topLeft,
              child: _buildHomeBaseQuadrant(PlayerColor.green, scale),
            ),
          ],
        );
      }
      return const SizedBox.expand();
    }
    
    // Quadrant: YELLOW top-right base (Row 0-5, Col 9-14)
    if (row < 6 && col >= 9) {
      if (row == 0 && col == 9) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 6.0,
              heightFactor: 6.0,
              alignment: Alignment.topLeft,
              child: _buildHomeBaseQuadrant(PlayerColor.yellow, scale),
            ),
          ],
        );
      }
      return const SizedBox.expand();
    }
    
    // Quadrant: RED bottom-left base (Row 9-14, Col 0-5)
    if (row >= 9 && col < 6) {
      if (row == 9 && col == 0) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 6.0,
              heightFactor: 6.0,
              alignment: Alignment.topLeft,
              child: _buildHomeBaseQuadrant(PlayerColor.red, scale),
            ),
          ],
        );
      }
      return const SizedBox.expand();
    }
    
    // Quadrant: BLUE bottom-right base (Row 9-14, Col 9-14)
    if (row >= 9 && col >= 9) {
      if (row == 9 && col == 9) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 6.0,
              heightFactor: 6.0,
              alignment: Alignment.topLeft,
              child: _buildHomeBaseQuadrant(PlayerColor.blue, scale),
            ),
          ],
        );
      }
      return const SizedBox.expand();
    }

    // Converging Home Triangle cells in center (Row 6-8, Col 6-8) - ONE single 3x3 pinwheel
    if (row >= 6 && row <= 8 && col >= 6 && col <= 8) {
      if (row == 6 && col == 6) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FractionallySizedBox(
              widthFactor: 3.0,
              heightFactor: 3.0,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                painter: PinwheelPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      }
      return const SizedBox.expand();
    }

    // Track grid cells - tile colors matching Figma node 257-374
    Color cellBgColor = Colors.white;
    
    // Home stretch arms (5 colored cells leading to center)
    if (col >= 6 && col <= 8 && row <= 5) {
      if (col == 7 && row >= 1) cellBgColor = const Color(0xFFF4B400); // Yellow stretch
    } else if (col >= 6 && col <= 8 && row >= 9) {
      if (col == 7 && row <= 13) cellBgColor = const Color(0xFFDB4437); // Red stretch
    } else if (row >= 6 && row <= 8 && col <= 5) {
      if (row == 7 && col >= 1) cellBgColor = const Color(0xFF0F9D58); // Green stretch
    } else if (row >= 6 && row <= 8 && col >= 9) {
      if (row == 7 && col <= 13) cellBgColor = const Color(0xFF4285F4); // Blue stretch
    }

    // Start point markers (colored start-tile with start icon)
    bool isStartPoint = false;
    if (row == 6 && col == 1) { cellBgColor = const Color(0xFF0F9D58); isStartPoint = true; } // Green start
    else if (row == 1 && col == 8) { cellBgColor = const Color(0xFFF4B400); isStartPoint = true; } // Yellow start
    else if (row == 8 && col == 13) { cellBgColor = const Color(0xFF4285F4); isStartPoint = true; } // Blue start
    else if (row == 13 && col == 6) { cellBgColor = const Color(0xFFDB4437); isStartPoint = true; } // Red start

    // Safe zone star locations (White tile with Gray Star icon)
    bool isStar = false;
    final safeTilePositions = [(2, 6), (6, 12), (12, 8), (8, 2)];
    if (safeTilePositions.any((pos) => pos.$1 == row && pos.$2 == col)) {
      isStar = true;
    }

    Widget? cellChild;
    if (isStar) {
      cellChild = Image.asset(
        'assets/graphics/game/tiles/star_safe_zone.png',
        width: 18 * scale,
        height: 18 * scale,
        fit: BoxFit.contain,
      );
    } else if (isStartPoint) {
      cellChild = Image.asset(
        'assets/graphics/game/tiles/start_point_of_piece.png',
        width: 18 * scale,
        height: 18 * scale,
        fit: BoxFit.contain,
      );
    }

    // Render active pieces on track using game engine data
    Widget? activePawn = _buildTrackPiece(row, col, scale);

    return Container(
      decoration: BoxDecoration(
        color: cellBgColor,
        border: Border.all(color: const Color(0xFFDFE5EB), width: 0.5),
      ),
      child: Stack(
        children: [
          if (cellChild != null)
            Center(child: cellChild),
          if (activePawn != null)
            Center(child: activePawn),
        ],
      ),
    );
  }

  // Get home base piece background asset path based on color
  String _getPieceBackgroundAsset(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return 'assets/graphics/game/pieces/red_piece_background.png';
      case PlayerColor.green:
        return 'assets/graphics/game/pieces/green_piece_background.png';
      case PlayerColor.yellow:
        return 'assets/graphics/game/pieces/yellow_piece_background.png';
      case PlayerColor.blue:
        return 'assets/graphics/game/pieces/blue_piece_background.png';
    }
  }

  // Helper to map PlayerColor to UI Color
  Color _getPlayerColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return const Color(0xFFDB4437);
      case PlayerColor.green:
        return const Color(0xFF0F9D58);
      case PlayerColor.yellow:
        return const Color(0xFFF4B400);
      case PlayerColor.blue:
        return const Color(0xFF4285F4);
    }
  }

  // Build the entire 6x6 home base quadrant as classic Ludo style:
  // Edge-to-edge solid color square + single centered circular background asset (~68% size) + 2x2 tokens
  Widget _buildHomeBaseQuadrant(PlayerColor playerColor, double scale) {
    final color = _getPlayerColor(playerColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Solid quadrant color filling edge-to-edge (no white panel, no borders)
        Positioned.fill(
          child: Container(color: color),
        ),
        // 2. Single circular background image centered, sized to ~68% of quadrant
        FractionallySizedBox(
          widthFactor: 0.68,
          heightFactor: 0.68,
          alignment: Alignment.center,
          child: Image.asset(
            _getPieceBackgroundAsset(playerColor),
            fit: BoxFit.contain,
          ),
        ),
        // 3. 4 Piece tokens in 2x2 arrangement centered over the 4 dot positions
        FractionallySizedBox(
          widthFactor: 0.68,
          heightFactor: 0.68,
          alignment: Alignment.center,
          child: Column(
            children: List.generate(2, (r) {
              return Expanded(
                child: Row(
                  children: List.generate(2, (c) {
                    return Expanded(
                      child: _buildHomeBaseSlotPawn(r * 2 + c, playerColor, scale),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeBaseSlotPawn(int slotIndex, PlayerColor playerColor, double scale) {
    final playerExists = _gameEngine.players.any((p) => p.color == playerColor);
    if (!playerExists) return const SizedBox.shrink();
    
    final player = _gameEngine.players.firstWhere(
      (p) => p.color == playerColor,
      orElse: () => _gameEngine.players.first,
    );
    
    if (slotIndex >= player.pieces.length) return const SizedBox.shrink();
    
    final piece = player.pieces[slotIndex];
    if (piece.state != PieceState.home) return const SizedBox.shrink();
    
    final isValidMove = _validMovePieceIds.contains(piece.id);
    final isSelected = _selectedPieceId == piece.id;
    final pieceAsset = _getPieceAsset(piece.color);

    return Center(
      child: GestureDetector(
        onTap: () {
          if (isValidMove && _gameEngine.currentPlayer.isHuman) {
            setState(() {
              _selectedPieceId = piece.id;
            });
            _movePiece(piece.id);
          }
        },
        child: Container(
          width: 24 * scale,
          height: 24 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              const BoxShadow(color: Colors.black26, blurRadius: 2),
              if (isValidMove)
                const BoxShadow(
                  color: Colors.green,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              if (isSelected)
                const BoxShadow(
                  color: Colors.amber,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
            border: isValidMove || isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Image.asset(
            pieceAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Build piece on track (shared path or home stretch)
  Widget? _buildTrackPiece(int row, int col, double scale) {
    final sharedPathIndex = _sharedPath.indexWhere((pos) => pos.$1 == row && pos.$2 == col);
    
    if (sharedPathIndex != -1) {
      for (final player in _gameEngine.players) {
        for (final piece in player.pieces) {
          if (piece.state == PieceState.active && piece.currentPosition == sharedPathIndex) {
            return _buildPieceWidget(piece, scale);
          }
        }
      }
    }
    
    for (final entry in _homeStretchPaths.entries) {
      final playerColor = entry.key;
      final path = entry.value;
      final homeStretchIndex = path.indexWhere((pos) => pos.$1 == row && pos.$2 == col);
      
      if (homeStretchIndex != -1) {
        for (final player in _gameEngine.players) {
          if (player.color != playerColor) continue;
          
          for (final piece in player.pieces) {
            if (piece.state == PieceState.homeStretch && piece.currentPosition == homeStretchIndex) {
              return _buildPieceWidget(piece, scale);
            }
          }
        }
      }
    }
    
    return null;
  }

  // Build individual piece widget using piece assets
  Widget _buildPieceWidget(LudoPiece piece, double scale) {
    final pieceAsset = _getPieceAsset(piece.color);
    final isValidMove = _validMovePieceIds.contains(piece.id);
    final isSelected = _selectedPieceId == piece.id;

    return GestureDetector(
      onTap: () {
        if (isValidMove && _gameEngine.currentPlayer.isHuman) {
          setState(() {
            _selectedPieceId = piece.id;
          });
          _movePiece(piece.id);
        }
      },
      child: Container(
        width: 24 * scale,
        height: 24 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 3 * scale, offset: const Offset(0, 1)),
            if (isValidMove)
              const BoxShadow(
                color: Colors.green,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            if (isSelected)
              const BoxShadow(
                color: Colors.amber,
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
          border: isValidMove || isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Image.asset(
          pieceAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Get piece asset path based on color and equipped token skin
  String _getPieceAsset(PlayerColor color) {
    if (color == PlayerColor.red) {
      final shopState = ref.watch(shopProvider);
      final equippedToken = shopState.items.firstWhere(
        (item) => item.category == ShopCategory.token && item.isEquipped,
        orElse: () => ShopCatalog.allItems.firstWhere((i) => i.id == 'token_classic'),
      );

      switch (equippedToken.id) {
        case 'token_chick':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Chick-4.png';
        case 'token_coffee':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Cofee-3.png';
        case 'token_desert_hammer':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Desert_Hammer-2.png';
        case 'token_blessing_basket':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Blessing_Basket-3.png';
        case 'token_fantasy_book':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Fantasy_Book-3.png';
        case 'token_ice_cream':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Icecream-3.png';
        case 'token_leisure_kitty':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Leisure_kitty-3.png';
        case 'token_rosy_life':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Rosy_Life-3.png';
        case 'token_warm_campfire':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Warm_Campfire-3.png';
        case 'token_wooden_case':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Wooden_Case-2.png';
        case 'token_earth_power':
          return 'assets/graphics/shop/03_piece_color_sets_TokenTab/Earth_power-7.png';
        case 'token_crystal':
          return 'assets/graphics/shop/01_dice_skins_DiceTab/Crystal.png';
        case 'token_dessert':
          return 'assets/graphics/shop/01_dice_skins_DiceTab/Dessert.png';
        case 'token_warrior_helmet':
          return 'assets/graphics/shop/01_dice_skins_DiceTab/Metal.png';
        case 'token_classic':
        default:
          return 'assets/graphics/game/pieces/red_piece.png';
      }
    }

    switch (color) {
      case PlayerColor.red:
        return 'assets/graphics/game/pieces/red_piece.png';
      case PlayerColor.green:
        return 'assets/graphics/game/pieces/green_piece.png';
      case PlayerColor.yellow:
        return 'assets/graphics/game/pieces/yellow_piece.png';
      case PlayerColor.blue:
        return 'assets/graphics/game/pieces/blue_piece.png';
    }
  }
}

// Custom Painter to draw the center pinwheel converging triangles
class PinwheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Top Triangle (Yellow)
    fillPaint.color = const Color(0xFFF4B400);
    path.reset();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(center.dx, center.dy);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Right Triangle (Blue)
    fillPaint.color = const Color(0xFF4285F4);
    path.reset();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(center.dx, center.dy);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Bottom Triangle (Red)
    fillPaint.color = const Color(0xFFDB4437);
    path.reset();
    path.moveTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(center.dx, center.dy);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Left Triangle (Green)
    fillPaint.color = const Color(0xFF0F9D58);
    path.reset();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(center.dx, center.dy);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Crisp white dividing lines between triangles
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), strokePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), strokePaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

