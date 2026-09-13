import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
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
    this.roomId,
    this.gameId,
    this.isOnline = false,
    this.isTournament = false,
    this.tournamentRound,
    this.tournamentMode,
  });

  final int playerCount;
  final int betAmount;
  final int? roomId;
  final int? gameId;
  final bool isOnline;
  final bool isTournament;
  final int? tournamentRound;
  final String? tournamentMode;

  @override
  ConsumerState<LudoBoardScreen> createState() => _LudoBoardScreenState();
}

class _LudoBoardScreenState extends ConsumerState<LudoBoardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Practice Mode Engine ──────────────────────────────────────────
  late LudoGameEngine _gameEngine;

  // ── 3D Dice & UI State ────────────────────────────────────────────
  final GlobalKey<Ludo3DDiceState> _diceKey = GlobalKey<Ludo3DDiceState>();
  String? _lastPrecachedDiceSkin;

  // ── Online Match Real-Time State ─────────────────────────────────────
  Map<String, dynamic>? _onlineGameState;
  final Map<String, List<int>> _onlineTokenPositions = {};
  List<Map<String, dynamic>> _onlinePlayers = [];
  int? _currentTurnUserId;
  int? _currentTurnSeat;
  int? _lastDiceValue;
  List<int> _serverMovableTokens = [];
  bool _canRoll = true;
  bool _mustMove = false;
  int _turnSecondsRemaining = 15;
  int _turnDurationTotal = 15;
  Timer? _turnCountdownTimer;
  Timer? _onlineSyncTimer;
  StreamSubscription<WebSocketEvent>? _roomWsSubscription;
  final List<WebSocketEvent> _earlyEventBuffer = [];
  bool _isInitialStateFetched = false;
  bool _isFetchingState = false;
  String? _onlineWinnerUsername;

  Map<String, dynamic>? get onlineGameState => _onlineGameState;
  int? get currentTurnSeat => _currentTurnSeat;
  String? get onlineWinnerUsername => _onlineWinnerUsername;

  // ── UI State ────────────────────────────────────────────────────────
  bool _isRolling = false;
  bool _isOpponentRolling = false;
  bool _hasRolledDiceThisTurn = false;
  int _animatedDiceDisplayValue = 1;
  bool _isMuted = true;
  double _diceRotation = 0.0;
  List<String> _validMovePieceIds = []; // Valid piece IDs
  String? _selectedPieceId;

  // In-Match Player Chat Bubbles (userId -> message)
  final Map<int, String> _playerChatBubbles = {};
  final Map<int, Timer> _playerChatTimers = {};
  int _lastSeenMessageId = 0;
  bool _isFetchingMessages = false;

  // Emojis and animated elements
  final List<String> _emojis = ['😂', '👍', '🔥', '😮', '👑', '😎', '👏', '💔'];
  final List<Widget> _floatingEmojis = [];
  String? _speechBubbleText;
  Timer? _speechBubbleTimer;
  Timer? _aiTurnTimer;

  // Kill & Win Feedback System
  String? _killToastMessage;
  Timer? _killToastTimer;
  int? _flashingKillerUserId;
  int? _flashingVictimUserId;
  Timer? _avatarFlashTimer;

  // Arrow bounce animation
  late final AnimationController _arrowController;
  late final Animation<double> _arrowAnimation;

  // Board path coordinate mappings
  late final List<(int row, int col)> _sharedPath;
  late final Map<PlayerColor, List<(int row, int col)>> _homeStretchPaths;

  int? get _myUserId {
    final user = ref.read(authProvider).user;
    if (user != null) return user.id;
    return null;
  }

  bool get _isMyTurn {
    if (!widget.isOnline) {
      return _gameEngine.currentPlayer.isHuman;
    }
    if (_currentTurnUserId == null) return false;
    final myId = _myUserId;
    if (myId != null && _currentTurnUserId == myId) return true;

    // Fallback: match username in _onlinePlayers
    final authUser = ref.read(authProvider).user;
    if (authUser != null) {
      final turnPlayer = _onlinePlayers.firstWhere(
        (p) => (p['user_id'] is int ? p['user_id'] : int.tryParse(p['user_id']?.toString() ?? '')) == _currentTurnUserId,
        orElse: () => {},
      );
      if (turnPlayer.isNotEmpty && turnPlayer['username'] == authUser.username) {
        return true;
      }
    }
    return false;
  }

  String get _myColorName {
    if (!widget.isOnline) return 'red';
    final authUser = ref.read(authProvider).user;
    final myId = authUser?.id;
    for (final p in _onlinePlayers) {
      final uid = p['user_id'] is int ? p['user_id'] : int.tryParse(p['user_id']?.toString() ?? '');
      if ((myId != null && uid == myId) || (authUser != null && authUser.username.isNotEmpty && p['username'] == authUser.username)) {
        return (p['color']?.toString() ?? 'red').toLowerCase();
      }
    }
    return 'red';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeBoardPaths();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    if (widget.isOnline && widget.roomId != null) {
      if (kDebugMode) {
        print('🎮 [BOARD ONLINE] Initializing online room: ${widget.roomId}, game: ${widget.gameId}');
      }
      _subscribeToRoomWebSocket();
      _fetchOnlineGameState();
    } else {
      if (kDebugMode) {
        print('🤖 [BOARD PRACTICE] Initializing offline practice mode');
      }
      _initializeGameEngine();
    }
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
    _sharedPath = [
      (6, 1), (5, 1), (4, 1), (3, 1), (2, 1), (1, 1), (0, 1),
      (0, 2), (0, 3), (0, 4), (0, 5), (0, 6),
      (0, 8),
      (0, 9), (0, 10), (0, 11), (0, 12), (0, 13),
      (1, 13), (2, 13), (3, 13), (4, 13), (5, 13), (6, 13),
      (7, 13),
      (8, 13),
      (9, 13), (10, 13), (11, 13), (12, 13), (13, 13),
      (13, 12), (13, 11), (13, 10), (13, 9), (13, 8),
      (13, 6),
      (13, 5),
      (13, 4), (13, 3), (13, 2), (13, 1),
      (13, 0), (12, 0), (11, 0), (10, 0), (9, 0), (8, 0),
      (7, 0),
      (6, 0),
      (5, 0),
    ];

    _homeStretchPaths = {
      PlayerColor.red: [
        (7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6),
      ],
      PlayerColor.green: [
        (1, 7), (2, 7), (3, 7), (4, 7), (5, 7), (6, 7),
      ],
      PlayerColor.yellow: [
        (7, 12), (7, 11), (7, 10), (7, 9), (7, 8), (7, 7),
      ],
      PlayerColor.blue: [
        (12, 7), (11, 7), (10, 7), (9, 7), (8, 7), (7, 7),
      ],
    };
  }

  void _initializeGameEngine() {
    final players = <LudoPlayer>[];
    players.add(LudoPlayer(
      id: 'player_0',
      color: PlayerColor.red,
      isHuman: true,
    ));
    players.add(LudoPlayer(
      id: 'player_1',
      color: PlayerColor.yellow,
      isHuman: false,
    ));
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
    _gameEngine = LudoGameEngine(
      players: players,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isOnline && widget.roomId != null) {
      if (kDebugMode) {
        print('🔄 [BOARD RESUME] App resumed. Resyncing state from server...');
      }
      _fetchOnlineGameState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _arrowController.dispose();
    _speechBubbleTimer?.cancel();
    _aiTurnTimer?.cancel();
    _turnCountdownTimer?.cancel();
    _onlineSyncTimer?.cancel();
    _roomWsSubscription?.cancel();
    for (final t in _playerChatTimers.values) {
      t.cancel();
    }
    _playerChatTimers.clear();

    if (widget.isOnline && widget.roomId != null) {
      final ws = ref.read(webSocketServiceProvider);
      ws.unsubscribeChannel('private-room.${widget.roomId}');
      ws.unsubscribeChannel('room.${widget.roomId}');
    }

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
  }
  // ── Online WebSocket & State Synchronization ────────────────────────
  void _subscribeToRoomWebSocket() {
    final wsService = ref.read(webSocketServiceProvider);
    final roomId = widget.roomId!;

    // Subscribe immediately (Addition A)
    if (!wsService.isConnected) {
      wsService.connect().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            wsService.subscribeToRoomChannel(roomId);
          }
        });
      });
    } else {
      wsService.subscribeToRoomChannel(roomId);
    }

    // Active state and chat sync polling fallback (every 2.5s) to guarantee zero stuck turns and real-time chat sync
    _onlineSyncTimer?.cancel();
    _onlineSyncTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted || !widget.isOnline || widget.roomId == null) {
        timer.cancel();
        return;
      }
      if (!_isFetchingState && !_isRolling && !_isOpponentRolling) {
        _fetchOnlineGameState(silent: true);
      }
      _fetchOnlineChatMessages();
    });

    _roomWsSubscription = wsService.eventStream.listen((wsEvent) {
      // Filter for this room's events
      if (wsEvent.channel != 'private-room.$roomId' && wsEvent.channel != 'room.$roomId') return;

      if (!_isInitialStateFetched) {
        // Buffer events that arrive before GET /game/state finishes (Addition A)
        if (kDebugMode) {
          print('📦 [BOARD BUFFER] Buffered early event: ${wsEvent.event}');
        }
        _earlyEventBuffer.add(wsEvent);
      } else {
        _handleRoomWebSocketEvent(wsEvent);
      }
    });
  }

  Future<void> _fetchOnlineChatMessages() async {
    if (_isFetchingMessages || widget.roomId == null) return;
    _isFetchingMessages = true;

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        ApiEndpoints.quickMatchMessages,
        queryParameters: {'quick_match_id': widget.roomId},
      );

      if (!mounted) return;

      final data = response is Map<String, dynamic> ? response['data'] : null;
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final msgId = item['id'] is int
                ? item['id'] as int
                : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
            if (msgId > _lastSeenMessageId) {
              _handleChatMessageEvent(item);
            }
          }
        }
      }
    } catch (_) {
    } finally {
      _isFetchingMessages = false;
    }
  }

  Future<void> _fetchOnlineGameState({bool silent = false}) async {
    if (_isFetchingState || widget.roomId == null) return;
    _isFetchingState = true;

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        ApiEndpoints.quickMatchState,
        queryParameters: {'quick_match_id': widget.roomId},
      );

      if (!mounted) return;

      final data = response is Map<String, dynamic> ? response['data'] : null;
      if (data is Map<String, dynamic>) {
        _applyFullGameState(data);

        // Reconcile buffered early events (Addition A)
        _isInitialStateFetched = true;
        if (_earlyEventBuffer.isNotEmpty) {
          if (kDebugMode) {
            print('⚡ [BOARD BUFFER] Reconciling ${_earlyEventBuffer.length} buffered early events');
          }
          for (final bufferedEvent in _earlyEventBuffer) {
            _handleRoomWebSocketEvent(bufferedEvent);
          }
          _earlyEventBuffer.clear();
        }
      }
    } catch (e) {
      if (!silent && kDebugMode) {
        print('⚠️ [BOARD] Error fetching game state: $e');
      }
    } finally {
      _isFetchingState = false;
    }
  }

  void _applyFullGameState(Map<String, dynamic> data) {
    if (!mounted) return;
    final myId = _myUserId;
    final turnUserId = data['current_turn_user_id'] is int
        ? data['current_turn_user_id'] as int
        : int.tryParse(data['current_turn_user_id']?.toString() ?? '');
    final isMyTurn = myId != null && turnUserId == myId;

    setState(() {
      _onlineGameState = data;
      _currentTurnSeat = data['current_turn_seat'] is int
          ? data['current_turn_seat'] as int
          : int.tryParse(data['current_turn_seat']?.toString() ?? '0');
      _currentTurnUserId = turnUserId;
      _lastDiceValue = data['dice_value'] is int
          ? data['dice_value'] as int
          : int.tryParse(data['dice_value']?.toString() ?? '');
      
      _mustMove = data['must_move'] == true;
      _canRoll = data['can_roll'] == true || (isMyTurn && !_mustMove);
      _hasRolledDiceThisTurn = !_canRoll || _mustMove;

      // Parse token positions & detect kills via state diff
      if (data['token_positions'] is Map) {
        final tokenPosMap = data['token_positions'] as Map<String, dynamic>;
        tokenPosMap.forEach((colorRaw, positions) {
          final color = colorRaw.toLowerCase();
          if (positions is List) {
            final newPosList = positions.map((p) => int.tryParse(p.toString()) ?? -1).toList();
            if (_onlineTokenPositions.containsKey(color)) {
              final oldPosList = _onlineTokenPositions[color]!;
              for (int i = 0; i < newPosList.length && i < oldPosList.length; i++) {
                // If a token was on the track (>= 0) and now returned to base (-1), a kill occurred!
                if (oldPosList[i] >= 0 && newPosList[i] == -1) {
                  final victimPlayer = _onlinePlayers.firstWhere(
                    (pl) => pl['color']?.toString().toLowerCase() == color,
                    orElse: () => {'username': color.toUpperCase()},
                  );
                  final victimName = victimPlayer['username']?.toString() ?? color.toUpperCase();
                  final victimId = victimPlayer['user_id'] is int ? victimPlayer['user_id'] as int : int.tryParse(victimPlayer['user_id']?.toString() ?? '');

                  final killerPlayer = _onlinePlayers.firstWhere(
                    (pl) => pl['color']?.toString().toLowerCase() != color,
                    orElse: () => {'username': 'Opponent'},
                  );
                  final killerName = killerPlayer['username']?.toString() ?? 'Opponent';
                  final killerId = killerPlayer['user_id'] is int ? killerPlayer['user_id'] as int : int.tryParse(killerPlayer['user_id']?.toString() ?? '');

                  _triggerKillFeedback(
                    killerName: killerName,
                    victimName: victimName,
                    killerUserId: killerId,
                    victimUserId: victimId,
                  );
                }
              }
            }
            _onlineTokenPositions[color] = newPosList;
          }
        });
      }

      // If it's my turn and mustMove is true, ensure movable tokens are populated
      if (isMyTurn && _mustMove) {
        final movableRaw = data['movable_tokens'] as List<dynamic>?;
        if (movableRaw != null && movableRaw.isNotEmpty) {
          _serverMovableTokens = movableRaw
              .map((t) => int.tryParse(t.toString()) ?? 0)
              .toList();
        } else {
          _serverMovableTokens = _calculateLegalMovableTokens(_myColorName, _lastDiceValue ?? 6);
        }
      } else if (!isMyTurn) {
        _serverMovableTokens = [];
      }

      // Parse players list
      if (data['players'] is Map) {
        final playersMap = data['players'] as Map<String, dynamic>;
        _onlinePlayers = playersMap.values
            .map((p) => p is Map<String, dynamic> ? p : <String, dynamic>{})
            .toList();
      } else if (data['players'] is List) {
        _onlinePlayers = (data['players'] as List)
            .map((p) => p is Map<String, dynamic> ? p : <String, dynamic>{})
            .toList();
      }

      // Check for Completed Win condition
      if (data['status'] == 'completed' && _onlineWinnerUsername == null) {
        final winId = data['winner_id'] is int
            ? data['winner_id'] as int
            : int.tryParse(data['winner_id']?.toString() ?? '0') ?? 0;
        final winPlayer = _onlinePlayers.firstWhere(
          (pl) => (pl['user_id'] is int ? pl['user_id'] : int.tryParse(pl['user_id']?.toString() ?? '')) == winId,
          orElse: () => {'username': winId == _myUserId ? 'You' : 'Winner'},
        );
        final winName = winPlayer['username']?.toString() ?? (winId == _myUserId ? 'You' : 'Winner');
        _onlineWinnerUsername = winName;
        _turnCountdownTimer?.cancel();
        _showWinCelebrationModal(
          winnerId: winId,
          winnerUsername: winName,
          prizeCoins: 400,
        );
      }
    });

    _startTurnTimer(15);
  }

  List<int> _calculateLegalMovableTokens(String colorName, int diceValue) {
    final tokens = _onlineTokenPositions[colorName.toLowerCase()] ?? [-1, -1, -1, -1];
    final movable = <int>[];
    for (int i = 0; i < tokens.length; i++) {
      final steps = tokens[i];
      if (steps == -1) {
        if (diceValue == 6) movable.add(i);
      } else if (steps >= 0 && steps < 56) {
        if (steps + diceValue <= 56) movable.add(i);
      }
    }
    return movable;
  }

  void _handleRoomWebSocketEvent(WebSocketEvent event) {
    if (!mounted) return;
    final evt = event.event.toLowerCase();
    final payload = event.payload;

    if (kDebugMode) {
      print('📩 [BOARD EVENT] $evt: $payload');
    }

    if (evt == 'dice.rolled' || evt == '.dice.rolled' || evt == 'dicerolled') {
      _handleDiceRolledEvent(payload);
    } else if (evt == 'token.moved' || evt == '.token.moved' || evt == 'tokenmoved') {
      _handleTokenMovedEvent(payload);
    } else if (evt == 'turn.changed' || evt == '.turn.changed' || evt == 'turnchanged') {
      _handleTurnChangedEvent(payload);
    } else if (evt == 'game.ended' || evt == '.game.ended' || evt == 'gameended') {
      _handleGameEndedEvent(payload);
    } else if (evt == 'player.forfeited' || evt == '.player.forfeited' || evt == 'playerforfeited') {
      _handlePlayerForfeitedEvent(payload);
    } else if (evt == 'chat.message' || evt == '.chat.message' || evt == 'chatmessagesent' || evt == 'quickmatch.message') {
      _handleChatMessageEvent(payload);
    }
  }

  void _handleChatMessageEvent(Map<String, dynamic> payload) {
    final msgId = payload['id'] is int
        ? payload['id'] as int
        : int.tryParse(payload['id']?.toString() ?? '0') ?? 0;
    if (msgId > 0) {
      if (msgId <= _lastSeenMessageId) return; // Deduplicate already shown message
      _lastSeenMessageId = msgId;
    }

    final userId = payload['user_id'] is int
        ? payload['user_id'] as int
        : int.tryParse(payload['user_id']?.toString() ?? '0') ?? 0;
    final message = payload['message']?.toString() ?? '';
    final messageType = payload['message_type']?.toString() ?? 'text';

    if (message.isEmpty) return;

    if (messageType == 'emoji') {
      _spawnFloatingEmoji(message);
    } else {
      _showPlayerChatBubble(userId, message);
    }
  }

  void _showPlayerChatBubble(int userId, String message) {
    _playerChatTimers[userId]?.cancel();
    setState(() {
      _playerChatBubbles[userId] = message;
    });
    _playerChatTimers[userId] = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _playerChatBubbles.remove(userId);
        });
      }
    });
  }

  void _handleDiceRolledEvent(Map<String, dynamic> payload) {
    final diceVal = payload['dice_value'] is int
        ? payload['dice_value'] as int
        : int.tryParse(payload['dice_value']?.toString() ?? '1') ?? 1;
    final userId = payload['user_id'] is int
        ? payload['user_id'] as int
        : int.tryParse(payload['user_id']?.toString() ?? '0');
    final movableRaw = payload['movable_tokens'] as List<dynamic>?;

    SoundService().playDiceRoll();

    if (userId != _myUserId) {
      // Opponent rolled: animate dice roll for opponent so both players see the active roll!
      setState(() {
        _isOpponentRolling = true;
        _hasRolledDiceThisTurn = true; // Disappear 15s timer badge
      });

      int ticks = 0;
      Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _diceRotation += pi / 4;
          _animatedDiceDisplayValue = Random().nextInt(6) + 1;
        });
        ticks++;
        if (ticks >= 8) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isOpponentRolling = false;
              _diceRotation = 0.0;
              _lastDiceValue = diceVal;
              _canRoll = false;
              _serverMovableTokens = [];
              _mustMove = false;
            });
          }
        }
      });
    } else {
      // Local player
      setState(() {
        _lastDiceValue = diceVal;
        _canRoll = false;
        _hasRolledDiceThisTurn = true; // Disappear 15s timer badge

        if (movableRaw != null) {
          _serverMovableTokens = movableRaw
              .map((t) => int.tryParse(t.toString()) ?? 0)
              .toList();
          _mustMove = _serverMovableTokens.isNotEmpty;
        } else {
          _serverMovableTokens = [];
          _mustMove = false;
        }
      });
    }
  }

  void _handleTokenMovedEvent(Map<String, dynamic> payload) {
    final color = payload['color']?.toString().toLowerCase() ?? '';
    final tokenIndex = payload['token_index'] is int
        ? payload['token_index'] as int
        : int.tryParse(payload['token_index']?.toString() ?? '0') ?? 0;
    final newSteps = payload['new_steps'] is int
        ? payload['new_steps'] as int
        : int.tryParse(payload['new_steps']?.toString() ?? '-1') ?? -1;
    final isKill = payload['is_kill'] == true;
    final reachedHome = payload['reached_home'] == true;
    final killedTokens = payload['killed_tokens'] as List<dynamic>?;

    setState(() {
      if (_onlineTokenPositions.containsKey(color) &&
          tokenIndex >= 0 &&
          tokenIndex < 4) {
        _onlineTokenPositions[color]![tokenIndex] = newSteps;
      }

      // Reset killed tokens back to base (-1) & Trigger Kill Feedback System
      if (isKill && killedTokens != null) {
        String killerName = 'Player';
        int? killerId = payload['user_id'] is int
            ? payload['user_id'] as int
            : int.tryParse(payload['user_id']?.toString() ?? '');
        if (killerId != null) {
          final p = _onlinePlayers.firstWhere(
            (pl) => (pl['user_id'] is int ? pl['user_id'] : int.tryParse(pl['user_id']?.toString() ?? '')) == killerId,
            orElse: () => {'username': color.toUpperCase()},
          );
          killerName = p['username']?.toString() ?? color.toUpperCase();
        }

        for (final k in killedTokens) {
          if (k is Map<String, dynamic>) {
            final kColor = k['color']?.toString().toLowerCase();
            final kIdx = k['token_index'] is int
                ? k['token_index'] as int
                : int.tryParse(k['token_index']?.toString() ?? '0') ?? 0;
            if (kColor != null && _onlineTokenPositions.containsKey(kColor)) {
              _onlineTokenPositions[kColor]![kIdx] = -1;
            }

            final victimPlayer = _onlinePlayers.firstWhere(
              (pl) => pl['color']?.toString().toLowerCase() == kColor,
              orElse: () => {'username': kColor?.toUpperCase() ?? 'Opponent'},
            );
            final victimName = victimPlayer['username']?.toString() ?? (kColor?.toUpperCase() ?? 'Opponent');
            final victimId = victimPlayer['user_id'] is int
                ? victimPlayer['user_id'] as int
                : int.tryParse(victimPlayer['user_id']?.toString() ?? '');

            _triggerKillFeedback(
              killerName: killerName,
              victimName: victimName,
              killerUserId: killerId,
              victimUserId: victimId,
            );
          }
        }
      } else {
        SoundService().playPieceMove();
      }

      if (reachedHome) {
        _showQuickChat('Home! 🎉');
        _spawnFloatingEmoji('🎉');
      }

      _serverMovableTokens = [];
      _mustMove = false;
    });
  }

  void _triggerKillFeedback({
    required String killerName,
    required String victimName,
    int? killerUserId,
    int? victimUserId,
  }) {
    HapticFeedback.heavyImpact();
    SoundService().playPieceCapture();

    _killToastTimer?.cancel();
    _avatarFlashTimer?.cancel();

    setState(() {
      _killToastMessage = '🔥 $killerName killed $victimName\'s token!';
      _flashingKillerUserId = killerUserId;
      _flashingVictimUserId = victimUserId;
    });

    _avatarFlashTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _flashingKillerUserId = null;
          _flashingVictimUserId = null;
        });
      }
    });

    _killToastTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _killToastMessage = null;
        });
      }
    });
  }

  void _handleTurnChangedEvent(Map<String, dynamic> payload) {
    final nextUserId = payload['current_turn_user_id'] is int
        ? payload['current_turn_user_id'] as int
        : int.tryParse(payload['current_turn_user_id']?.toString() ?? '0');
    final nextSeat = payload['current_turn_seat'] is int
        ? payload['current_turn_seat'] as int
        : int.tryParse(payload['current_turn_seat']?.toString() ?? '0');
    final timerSec = payload['timer_seconds'] is int
        ? payload['timer_seconds'] as int
        : int.tryParse(payload['timer_seconds']?.toString() ?? '15') ?? 15;

    setState(() {
      _currentTurnUserId = nextUserId;
      _currentTurnSeat = nextSeat;
      _canRoll = true;
      _mustMove = false;
      _serverMovableTokens = [];
      _hasRolledDiceThisTurn = false; // Reset timer badge for new turn or 6-roll!
      _isRolling = false;
      _isOpponentRolling = false;
    });

    // Start server-driven turn timer (15s)
    _startTurnTimer(timerSec);
  }

  void _handleGameEndedEvent(Map<String, dynamic> payload) {
    _turnCountdownTimer?.cancel();

    final winnerId = payload['winner_id'] is int
        ? payload['winner_id'] as int
        : int.tryParse(payload['winner_id']?.toString() ?? '0');
    final winnerUsername = payload['winner_username']?.toString() ?? 'Player';
    final prizeCoins = payload['prize_coins'] is int
        ? payload['prize_coins'] as int
        : int.tryParse(payload['prize_coins']?.toString() ?? '0') ?? 400;

    setState(() {
      _onlineWinnerUsername = winnerUsername;
    });

    _showWinCelebrationModal(
      winnerId: winnerId ?? 0,
      winnerUsername: winnerUsername,
      prizeCoins: prizeCoins,
    );
  }

  void _handlePlayerForfeitedEvent(Map<String, dynamic> payload) {
    final leaverUsername = payload['username']?.toString() ?? 'Opponent';
    final isGameOver = payload['is_game_over'] == true;
    final winnerId = payload['winner_id'] is int
        ? payload['winner_id'] as int
        : int.tryParse(payload['winner_id']?.toString() ?? '0') ?? 0;
    final winnerUsername = payload['winner_username']?.toString() ?? 'Winner';
    final prizeCoins = payload['prize_coins'] is int
        ? payload['prize_coins'] as int
        : int.tryParse(payload['prize_coins']?.toString() ?? '400') ?? 400;

    if (isGameOver) {
      _turnCountdownTimer?.cancel();
      setState(() {
        _onlineWinnerUsername = winnerUsername;
      });
      _showWinCelebrationModal(
        winnerId: winnerId,
        winnerUsername: winnerUsername,
        prizeCoins: prizeCoins,
      );
    } else {
      _showQuickChat('🔥 $leaverUsername left the match!');
      _spawnFloatingEmoji('🚪');
    }
  }

  void _showWinCelebrationModal({
    required int winnerId,
    required String winnerUsername,
    required int prizeCoins,
  }) {
    final isMeWinner = winnerId != 0 && (winnerId == _myUserId || (winnerUsername.isNotEmpty && winnerUsername == ref.read(authProvider).user?.username));

    if (isMeWinner) {
      SoundService().playWinFanfare();
      HapticFeedback.vibrate();
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Non-dismissible by tapping outside
      builder: (dialogContext) {
        final scale = MediaQuery.of(dialogContext).size.width / 375.0;
        return PopScope(
          canPop: false, // Block back button
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 24 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMeWinner
                      ? [const Color(0xFF2A1650), const Color(0xFF16092E)]
                      : [const Color(0xFF201335), const Color(0xFF110820)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24 * scale),
                border: Border.all(
                  color: isMeWinner ? const Color(0xFFFFD700) : const Color(0xFF7A4BC8),
                  width: 2 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMeWinner ? const Color(0xFFFFD700) : const Color(0xFF7A4BC8))
                        .withValues(alpha: 0.4),
                    blurRadius: 25 * scale,
                    spreadRadius: 4 * scale,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title / Trophy Header
                  Text(
                    isMeWinner ? '🏆 VICTORY! 🏆' : 'GAME OVER',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w900,
                      color: isMeWinner ? const Color(0xFFFFD700) : Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Winner Avatar Center Stage
                  Container(
                    width: 76 * scale,
                    height: 76 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 3 * scale,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 15 * scale,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        isMeWinner
                            ? 'assets/graphics/musician_avatar.png'
                            : 'assets/graphics/wealthy_avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 40),
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),

                  // Winner Name & Status
                  Text(
                    isMeWinner ? 'You Won the Match!' : '$winnerUsername Won the Match',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!isMeWinner) ...[
                    SizedBox(height: 4 * scale),
                    Text(
                      'Rank: #2 (Runner Up)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  SizedBox(height: 18 * scale),

                  // Rewards Section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 20 * scale),
                            SizedBox(width: 6 * scale),
                            Text(
                              isMeWinner ? '+$prizeCoins Coins' : '+20 Coins',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 20 * scale, color: Colors.white24),
                        Row(
                          children: [
                            Icon(Icons.military_tech_rounded, color: const Color(0xFF00E676), size: 20 * scale),
                            SizedBox(width: 6 * scale),
                            Text(
                              isMeWinner ? '+150 XP' : '+50 XP',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00E676),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22 * scale),

                  // Action Buttons: Play Again & Home
                  Row(
                    children: [
                      // Home Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.go(AppConstants.homeRoute);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, color: Colors.white70, size: 16 * scale),
                              SizedBox(width: 6 * scale),
                              Text(
                                'Home',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),

                      // Play Again Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                            ),
                            borderRadius: BorderRadius.circular(12 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                blurRadius: 10 * scale,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                              padding: EdgeInsets.symmetric(vertical: 12 * scale),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              if (widget.isTournament) {
                                if (isMeWinner) {
                                  context.pushReplacement(
                                    AppConstants.tournamentVictoryRoute,
                                    extra: {
                                      'round': widget.tournamentRound ?? 1,
                                      'mode': widget.tournamentMode ?? 'classic',
                                    },
                                  );
                                } else {
                                  context.pushReplacement(
                                    AppConstants.tournamentDefeatRoute,
                                    extra: {
                                      'round': widget.tournamentRound ?? 1,
                                      'mode': widget.tournamentMode ?? 'classic',
                                    },
                                  );
                                }
                              } else {
                                context.go(AppConstants.battleLobbyRoute);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.isTournament
                                      ? (isMeWinner ? Icons.emoji_events_rounded : Icons.replay_rounded)
                                      : Icons.replay_rounded,
                                  color: Colors.white,
                                  size: 16 * scale,
                                ),
                                SizedBox(width: 6 * scale),
                                Text(
                                  widget.isTournament
                                      ? (isMeWinner ? 'Continue Ladder' : 'Tournament Ended')
                                      : 'Play Again',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startTurnTimer(int seconds) {
    _turnCountdownTimer?.cancel();
    _turnDurationTotal = seconds > 0 ? seconds : 15;
    _turnSecondsRemaining = _turnDurationTotal;

    _turnCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_turnSecondsRemaining > 0) {
        setState(() => _turnSecondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  // ── Online Roll & Move API Handlers ─────────────────────────────────
  Future<void> _rollDiceOnline() async {
    if (_isRolling || widget.roomId == null) return;
    if (!_isMyTurn) {
      if (kDebugMode) {
        print('⚠️ [ROLL] Not my turn! Turn user: $_currentTurnUserId, My ID: $_myUserId');
      }
      return;
    }
    if (_mustMove) {
      if (kDebugMode) {
        print('⚠️ [ROLL] Must move a token before rolling again!');
      }
      return;
    }

    SoundService().playDiceRoll();
    setState(() {
      _isRolling = true;
      _hasRolledDiceThisTurn = true; // Hide 15s timer badge immediately
    });

    int ticks = 0;
    final animTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (mounted) {
        setState(() {
          _diceRotation += pi / 4;
          _animatedDiceDisplayValue = Random().nextInt(6) + 1;
        });
      }
      ticks++;
      if (ticks >= 10) t.cancel();
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.quickMatchRoll,
        data: {'quick_match_id': widget.roomId},
      );

      animTimer.cancel();
      if (!mounted) return;

      final data = response is Map<String, dynamic> ? response['data'] : null;
      if (data is Map<String, dynamic>) {
        final diceVal = data['dice_value'] is int
            ? data['dice_value'] as int
            : int.tryParse(data['dice_value']?.toString() ?? '1') ?? 1;

        final movableRaw = (data['movable_tokens'] as List<dynamic>?) ??
            (data['game_state'] is Map ? (data['game_state']['movable_tokens'] as List<dynamic>?) : null);

        final stateMap = data['game_state'] is Map<String, dynamic>
            ? data['game_state'] as Map<String, dynamic>
            : (data.containsKey('current_turn_seat') ? data : null);

        if (stateMap != null) {
          _applyFullGameState(stateMap);
        }

        setState(() {
          _isRolling = false;
          _diceRotation = 0.0;
          _lastDiceValue = diceVal;
          _canRoll = false;

          if (movableRaw != null && movableRaw.isNotEmpty) {
            _serverMovableTokens = movableRaw
                .map((t) => int.tryParse(t.toString()) ?? 0)
                .toList();
            _mustMove = true;
          } else if (data['must_move'] == true || (stateMap != null && stateMap['must_move'] == true)) {
            _serverMovableTokens = _calculateLegalMovableTokens(_myColorName, diceVal);
            _mustMove = _serverMovableTokens.isNotEmpty;
          } else {
            _serverMovableTokens = [];
            _mustMove = false;
          }
        });
      }
    } catch (e) {
      animTimer.cancel();
      if (mounted) {
        setState(() {
          _isRolling = false;
          _diceRotation = 0.0;
        });
        if (kDebugMode) print('⚠️ [BOARD ROLL ERROR] $e');
      }
    }
  }

  Future<void> _moveTokenOnline(int tokenIndex) async {
    if (!_isMyTurn || widget.roomId == null) {
      if (kDebugMode) {
        print('⚠️ [MOVE] Blocked: isMyTurn=$_isMyTurn, roomId=${widget.roomId}');
      }
      return;
    }

    SoundService().playPieceMove();

    setState(() {
      _serverMovableTokens = [];
      _mustMove = false;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        ApiEndpoints.quickMatchMove,
        data: {
          'quick_match_id': widget.roomId,
          'token_index': tokenIndex,
        },
      );
      if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
        final resData = response['data'] as Map<String, dynamic>;
        
        // Instant Kill Feedback from API response
        if (resData.containsKey('move_result')) {
          final mr = resData['move_result'];
          if (mr is Map<String, dynamic> && mr['is_kill'] == true) {
            final killedList = mr['killed_tokens'] as List<dynamic>?;
            if (killedList != null && killedList.isNotEmpty) {
              for (final k in killedList) {
                if (k is Map<String, dynamic>) {
                  final kColor = k['color']?.toString().toLowerCase();
                  final victimPlayer = _onlinePlayers.firstWhere(
                    (pl) => pl['color']?.toString().toLowerCase() == kColor,
                    orElse: () => {'username': kColor?.toUpperCase() ?? 'Opponent'},
                  );
                  final victimName = victimPlayer['username']?.toString() ?? (kColor?.toUpperCase() ?? 'Opponent');
                  final victimId = victimPlayer['user_id'] is int ? victimPlayer['user_id'] as int : int.tryParse(victimPlayer['user_id']?.toString() ?? '');
                  _triggerKillFeedback(
                    killerName: ref.read(authProvider).user?.username ?? 'You',
                    victimName: victimName,
                    killerUserId: _myUserId,
                    victimUserId: victimId,
                  );
                }
              }
            }
          }
        }

        if (resData.containsKey('game_state')) {
          _applyFullGameState(resData['game_state'] as Map<String, dynamic>);
        } else if (resData.containsKey('token_positions')) {
          _applyFullGameState(resData);
        }
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ [BOARD MOVE ERROR] $e');
    }
  }

  Future<void> _sendOnlineChatMessage(String message, {String type = 'text'}) async {
    if (widget.isOnline && widget.roomId != null) {
      final myId = _myUserId;
      if (myId != null) {
        _showPlayerChatBubble(myId, message);
      }
      try {
        final apiClient = ref.read(apiClientProvider);
        final response = await apiClient.post(
          ApiEndpoints.quickMatchMessage,
          data: {
            'quick_match_id': widget.roomId,
            'message': message,
            'message_type': type,
          },
        );
        if (response is Map<String, dynamic> && response['data'] is Map<String, dynamic>) {
          final resData = response['data'] as Map<String, dynamic>;
          final msgId = resData['id'] is int
              ? resData['id'] as int
              : int.tryParse(resData['id']?.toString() ?? '0') ?? 0;
          if (msgId > _lastSeenMessageId) {
            _lastSeenMessageId = msgId;
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ [CHAT SEND ERROR] $e');
      }
    }
  }

  // ── Practice Mode Helpers (Untouched) ───────────────────────────────

  void _nextTurnPractice() {
    if (!mounted) return;
    setState(() {
      _gameEngine.nextTurn();
      _validMovePieceIds = [];
      _selectedPieceId = null;
      _hasRolledDiceThisTurn = false;
    });

    _startTurnTimer(15);

    if (!_gameEngine.currentPlayer.isHuman) {
      _aiTurnTimer = Timer(const Duration(milliseconds: 1500), () {
        _rollDiceAI();
      });
    }
  }

  void _rollDicePlayerPractice() {
    if (_isRolling || !_gameEngine.currentPlayer.isHuman) return;
    SoundService().playDiceRoll();
    setState(() {
      _isRolling = true;
      _hasRolledDiceThisTurn = true;
    });

    int ticks = 0;
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _diceRotation += pi / 4;
        _animatedDiceDisplayValue = Random().nextInt(6) + 1;
      });
      ticks++;

      if (ticks >= 8) {
        timer.cancel();
        final rollResult = _gameEngine.rollDice();

        setState(() {
          _isRolling = false;
          _diceRotation = 0.0;
        });

        if (rollResult.wasThirdSix) {
          _showQuickChat('Three 6s! Turn forfeited');
          _nextTurnPractice();
          return;
        }

        final validMoves = _gameEngine.getValidMoves(rollResult.value);
        if (validMoves.isEmpty) {
          _showQuickChat('No moves available');
          _nextTurnPractice();
        } else if (validMoves.length == 1) {
          _movePiecePractice(validMoves.first);
        } else {
          setState(() => _validMovePieceIds = validMoves);
        }
      }
    });
  }

  void _rollDiceAI() {
    if (!mounted || _gameEngine.currentPlayer.isHuman) return;
    SoundService().playDiceRoll();
    setState(() {
      _isRolling = true;
      _hasRolledDiceThisTurn = true;
    });

    int ticks = 0;
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _diceRotation += pi / 4;
        _animatedDiceDisplayValue = Random().nextInt(6) + 1;
      });
      ticks++;

      if (ticks >= 8) {
        timer.cancel();
        final rollResult = _gameEngine.rollDice();

        setState(() {
          _isRolling = false;
          _diceRotation = 0.0;
        });

        if (rollResult.wasThirdSix) {
          _nextTurnPractice();
          return;
        }

        final validMoves = _gameEngine.getValidMoves(rollResult.value);
        if (validMoves.isEmpty) {
          _nextTurnPractice();
        } else {
          final random = Random();
          final chosenPiece = validMoves[random.nextInt(validMoves.length)];
          _movePiecePractice(chosenPiece);
        }
      }
    });
  }

  void _movePiecePractice(String pieceId) {
    final moveResult = _gameEngine.movePiece(pieceId, _gameEngine.lastDiceRoll);
    if (!moveResult.success) {
      _showQuickChat(moveResult.invalidReason ?? 'Invalid move');
      return;
    }

    setState(() {
      _selectedPieceId = null;
      _validMovePieceIds = [];
    });

    if (moveResult.captured) {
      _triggerKillFeedback(
        killerName: _gameEngine.currentPlayer.color.name.toUpperCase(),
        victimName: 'Opponent',
      );
    } else {
      SoundService().playPieceMove();
    }

    if (moveResult.reachedFinish) {
      _showQuickChat('Finished!');
      _spawnFloatingEmoji('🎉');
    }

    final winner = _gameEngine.checkWinner();
    if (winner != null) {
      _showWinCelebrationModal(
        winnerId: winner.isHuman ? (_myUserId ?? 1) : 0,
        winnerUsername: winner.isHuman ? 'You' : winner.color.name.toUpperCase(),
        prizeCoins: 400,
      );
      return;
    }

    if (_gameEngine.shouldGetAnotherTurn(moveResult)) {
      if (!_gameEngine.currentPlayer.isHuman) {
        _aiTurnTimer = Timer(const Duration(milliseconds: 1000), () {
          _rollDiceAI();
        });
      }
    } else {
      _nextTurnPractice();
    }
  }

  // ── Dialogs & UI Effects ────────────────────────────────────────────
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
                  color: Colors.black.withValues(alpha: 0.55),
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
                Text(
                  widget.isOnline
                      ? 'Are you sure you want to quit? Leaving will forfeit your match.'
                      : 'Are you sure you want to quit the practice match?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE6393F), Color(0xFFB51B20)]),
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

  // Handle settled 3D dice roll result from Ludo3DDiceWidget callback
  void _handleDiceRollResult(int diceValue) {
    if (!mounted) return;
    
    final rollResult = _gameEngine.rollDice(forcedValue: diceValue);
    
    setState(() {
      _isRolling = false;
    });
    
    if (rollResult.wasThirdSix) {
      _showQuickChat('Three 6s! Turn forfeited');
      _nextTurnPractice();
      return;
    }
    
    final validMoves = _gameEngine.getValidMoves(rollResult.value);
    
    if (validMoves.isEmpty) {
      _showQuickChat('No moves available');
      _nextTurnPractice();
    } else if (validMoves.length == 1) {
      _movePiecePractice(validMoves.first);
    } else {
      if (_gameEngine.currentPlayer.isHuman) {
        setState(() {
          _validMovePieceIds = validMoves;
        });
      } else {
        final random = Random();
        final chosenPiece = validMoves[random.nextInt(validMoves.length)];
        _movePiecePractice(chosenPiece);
      }
    }
  }

  Future<void> _forfeitMatch() async {
    if (widget.isOnline && widget.roomId != null) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          ApiEndpoints.quickMatchForfeit,
          data: {'quick_match_id': widget.roomId},
        );
      } catch (e) {
        if (kDebugMode) print('⚠️ [FORFEIT ERROR] $e');
      }
    }
    if (mounted) {
      context.go(AppConstants.battleLobbyRoute);
    }
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
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
        );
      },
    );

    setState(() => _floatingEmojis.add(widget));

    controller.forward().then((_) {
      setState(() => _floatingEmojis.remove(widget));
      controller.dispose();
    });
  }

  void _showQuickChat(String text) {
    _speechBubbleTimer?.cancel();
    setState(() => _speechBubbleText = text);

    _speechBubbleTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _speechBubbleText = null);
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
                        final emoji = _emojis[index];
                        Navigator.pop(context);
                        _spawnFloatingEmoji(emoji);
                        if (widget.isOnline) {
                          _sendOnlineChatMessage(emoji, type: 'emoji');
                        }
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
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(context);
                        if (widget.isOnline) {
                          _sendOnlineChatMessage(text, type: 'text');
                        } else {
                          _showQuickChat(text);
                        }
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
                      if (widget.isOnline) {
                        _sendOnlineChatMessage(msg, type: 'text');
                      } else {
                        _showQuickChat(msg);
                      }
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

  void _showSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C135C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Settings', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up, color: Colors.white),
                title: const Text('Mute Audio', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: _isMuted,
                  onChanged: (val) {
                    setState(() => _isMuted = val);
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app_rounded, color: Color(0xFFFF5252)),
                title: const Text('Leave Game', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  final leave = await _showLeaveDialog();
                  if (leave && mounted) {
                    await _forfeitMatch();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── BUILD MAIN SCREEN ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final customization = ref.watch(profileCustomizationProvider);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    final displayDice = widget.isOnline
        ? (_lastDiceValue ?? 0)
        : _gameEngine.lastDiceRoll;

    final authUser = ref.watch(authProvider).user;
    final myId = authUser?.id ?? _myUserId;
    final isMyTurnNow = widget.isOnline
        ? (_isMyTurn || (_currentTurnUserId != null && myId != null && _currentTurnUserId == myId))
        : _gameEngine.currentPlayer.isHuman;

    final canRollControls = widget.isOnline
        ? (isMyTurnNow && !_mustMove && !_isRolling)
        : (!_isRolling && _gameEngine.currentPlayer.isHuman);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showLeaveDialog();
        if (shouldLeave && mounted) {
          await _forfeitMatch();
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

            SafeArea(
              child: Column(
                children: [
                  // TOP BAR
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                    child: Row(
                      children: [
                        // Exit Match Button
                        _buildTopBarBtn(
                          onTap: () async {
                            final shouldLeave = await _showLeaveDialog();
                            if (shouldLeave && mounted) {
                              await _forfeitMatch();
                            }
                          },
                          scale: scale,
                          child: Icon(Icons.exit_to_app_rounded, color: const Color(0xFFFF5252), size: 19 * scale),
                        ),
                        SizedBox(width: 8 * scale),
                        _buildTopBarBtn(
                          onTap: _showSettings,
                          scale: scale,
                          child: Icon(Icons.settings_rounded, color: const Color(0xFFCFC9E8), size: 20 * scale),
                        ),
                        SizedBox(width: 8 * scale),
                        _buildTopBarBtn(
                          onTap: _showEmojiPicker,
                          scale: scale,
                          child: Icon(Icons.emoji_emotions_rounded, color: const Color(0xFFFFCF42), size: 20 * scale),
                        ),
                        const Spacer(),

                        // Mode Badge / Spectators
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A0E38), Color(0xFF120826)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(17 * scale),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isOnline ? Icons.public_rounded : Icons.smart_toy_rounded,
                                size: 14 * scale,
                                color: widget.isOnline ? const Color(0xFF00E676) : const Color(0xFFFF9B63),
                              ),
                              SizedBox(width: 6 * scale),
                              Text(
                                widget.isOnline ? 'Online Battle' : 'Practice Mode',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Chat button
                        _buildTopBarBtn(
                          onTap: _showChatInput,
                          scale: scale,
                          child: Icon(Icons.chat_bubble_rounded, color: const Color(0xFF3AA0D8), size: 20 * scale),
                        ),
                      ],
                    ),
                  ),

                  // WAITING PLAYERS ROW (Top)
                  Padding(
                    padding: EdgeInsets.only(top: 8 * scale, bottom: 6 * scale, right: 16 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _buildWaitingPlayersAvatars(scale),
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
                                          child: _buildTrackCell(row, col, scale),
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

                  // TURN INDICATOR ARROW
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _arrowAnimation.value),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4 * scale),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: widget.isOnline
                                ? (_isMyTurn ? const Color(0xFF00E676) : Colors.white30)
                                : const Color(0xFF3FD45A),
                            size: 30 * scale,
                          ),
                        ),
                      );
                    },
                  ),

                  // LOCAL PLAYER PANEL & DICE
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Player Avatar with Pulsing Halo, Timer & Name
                        _buildActivePlayerBlock(scale),

                        SizedBox(width: 14 * scale),
                        // 3D Reusable Animated Dice with equipped skin & callback
                        Ludo3DDiceWidget(
                          key: _diceKey,
                          size: 54 * scale,
                          isEnabled: widget.isOnline
                              ? canRollControls
                              : (_gameEngine.currentPlayer.isHuman && !_isRolling),
                          isRollingExternal: _isRolling &&
                              (widget.isOnline
                                  ? !_isMyTurn
                                  : !_gameEngine.currentPlayer.isHuman),
                          targetValue: widget.isOnline
                              ? _lastDiceValue
                              : (_gameEngine.lastDiceRoll > 0 ? _gameEngine.lastDiceRoll : null),
                          onRollStart: () {
                            if (widget.isOnline) {
                              _rollDiceOnline();
                            } else {
                              setState(() {
                                _isRolling = true;
                              });
                            }
                          },
                          onRollComplete: (diceValue) {
                            if (!widget.isOnline) {
                              _handleDiceRollResult(diceValue);
                            }
                          },
                        ),
                        if (!widget.isOnline) ...[
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

                  // Optional General Speech Bubble Text if active
                  if (_speechBubbleText != null && !_playerChatBubbles.containsValue(_speechBubbleText)) ...[
                    SizedBox(height: 6 * scale),
                    _buildSpeechBubble(_speechBubbleText!, scale),
                  ],
                ],
              ),
            ),

            // Lightweight Kill Banner / Toast (Auto-dismiss 3.5s, non-blocking)
            if (_killToastMessage != null)
              Positioned(
                top: 75 * scale,
                left: 16 * scale,
                right: 16 * scale,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 10 * scale),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF1744), Color(0xFFB71C1C), Color(0xFF4A0E17)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22 * scale),
                          border: Border.all(color: const Color(0xFFFFD700), width: 2 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1744).withValues(alpha: 0.8),
                              blurRadius: 18 * scale,
                              spreadRadius: 3 * scale,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                              blurRadius: 10 * scale,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFFD700), size: 20 * scale),
                            SizedBox(width: 6 * scale),
                            Flexible(
                              child: Text(
                                _killToastMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6 * scale),
                            Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFFD700), size: 20 * scale),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Floating Emoji Layer
            ..._floatingEmojis,
          ],
        ),
      ),
    );
  }

  // ── In-Match Speech Bubble Widget (Screenshot 2 Match) ───────────────
  Widget _buildSpeechBubble(String text, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 3.5 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF13092A),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFFFFD200), width: 1.8 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD200).withValues(alpha: 0.3),
            blurRadius: 6 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFD200),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Realistic Mini Dice Cube Widget (Screenshot 1 Match) ─────────────
  Widget _buildMiniDiceCube(int value, double scale) {
    return Container(
      width: 22 * scale,
      height: 22 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(color: const Color(0xFFD4D4D8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 3 * scale,
            offset: Offset(0, 1.5 * scale),
          ),
        ],
      ),
      child: Center(
        child: _buildDiceDots(value, scale),
      ),
    );
  }

  Widget _buildDiceDot(double dotSize, {bool red = false}) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: red ? const Color(0xFFE53935) : const Color(0xFF1E1E24),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDiceDots(int value, double scale) {
    final dotSize = 3.6 * scale;

    if (value <= 1) {
      return _buildDiceDot(dotSize, red: true);
    } else if (value == 2) {
      return Padding(
        padding: EdgeInsets.all(2.5 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: _buildDiceDot(dotSize)),
            Align(alignment: Alignment.bottomLeft, child: _buildDiceDot(dotSize)),
          ],
        ),
      );
    } else if (value == 3) {
      return Padding(
        padding: EdgeInsets.all(2.5 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: _buildDiceDot(dotSize)),
            Align(alignment: Alignment.center, child: _buildDiceDot(dotSize, red: true)),
            Align(alignment: Alignment.bottomLeft, child: _buildDiceDot(dotSize)),
          ],
        ),
      );
    } else if (value == 4) {
      return Padding(
        padding: EdgeInsets.all(2.5 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
          ],
        ),
      );
    } else if (value == 5) {
      return Padding(
        padding: EdgeInsets.all(2.5 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
            Center(child: _buildDiceDot(dotSize, red: true)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(2.5 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDiceDot(dotSize), _buildDiceDot(dotSize)]),
          ],
        ),
      );
    }
  }

  // ── Top Bar Button Widget ───────────────────────────────────────────
  Widget _buildTopBarBtn({
    required VoidCallback onTap,
    required Widget child,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36 * scale,
        height: 36 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1352),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  void _toggleMic() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _showQuickChat(_isMuted ? 'Muted mic' : 'Unmuted mic');
  }

  Widget _buildBottomBtn({
    required VoidCallback onTap,
    required double scale,
    required Widget child,
    bool isMic = false,
    bool isEmoji = false,
    bool isChat = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1352),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFD200), width: 1.5 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  // ── Active Player & Waiting Players Indicator Layout ───────────────
  Map<String, dynamic> _getActivePlayerData() {
    if (widget.isOnline) {
      if (_currentTurnUserId != null) {
        final p = _onlinePlayers.firstWhere(
          (pl) => (pl['user_id'] is int ? pl['user_id'] : int.tryParse(pl['user_id']?.toString() ?? '')) == _currentTurnUserId,
          orElse: () => _onlinePlayers.isNotEmpty ? _onlinePlayers.first : <String, dynamic>{},
        );
        if (p.isNotEmpty) {
          final uid = p['user_id'] is int ? p['user_id'] : int.tryParse(p['user_id']?.toString() ?? '0') ?? 0;
          return {
            'user_id': uid,
            'username': p['username']?.toString() ?? 'Player',
            'color': (p['color']?.toString() ?? 'red').toLowerCase(),
            'isMe': _myUserId != null && uid == _myUserId,
          };
        }
      }
      return {
        'user_id': _myUserId ?? 0,
        'username': ref.read(authProvider).user?.username ?? 'You',
        'color': _myColorName,
        'isMe': true,
      };
    } else {
      final p = _gameEngine.currentPlayer;
      return {
        'user_id': p.isHuman ? (_myUserId ?? 0) : -1,
        'username': p.isHuman ? 'You' : p.color.name.toUpperCase(),
        'color': p.color.name.toLowerCase(),
        'isMe': p.isHuman,
      };
    }
  }

  List<Map<String, dynamic>> _getWaitingPlayersList() {
    final active = _getActivePlayerData();
    final activeUserId = active['user_id'];
    final list = <Map<String, dynamic>>[];

    if (widget.isOnline) {
      for (final p in _onlinePlayers) {
        final uid = p['user_id'] is int ? p['user_id'] : int.tryParse(p['user_id']?.toString() ?? '');
        if (uid != null && uid == activeUserId) continue; // Skip active player
        list.add({
          'user_id': uid ?? 0,
          'username': p['username']?.toString() ?? 'Player',
          'color': (p['color']?.toString() ?? 'yellow').toLowerCase(),
          'isMe': _myUserId != null && uid == _myUserId,
        });
      }
    } else {
      for (int i = 0; i < _gameEngine.players.length; i++) {
        final p = _gameEngine.players[i];
        if (p.id == _gameEngine.currentPlayer.id) continue;
        list.add({
          'user_id': -(i + 1),
          'username': p.isHuman ? 'You' : p.color.name.toUpperCase(),
          'color': p.color.name.toLowerCase(),
          'isMe': p.isHuman,
        });
      }
    }
    return list;
  }

  // ── ACTIVE PLAYER BLOCK (Prominent at Bottom next to Dice) ─────────
  Widget _buildActivePlayerBlock(double scale) {
    final active = _getActivePlayerData();
    final userId = active['user_id'] as int;
    final username = active['username'] as String;
    final colorName = active['color'] as String;
    final isMe = active['isMe'] as bool;
    final colorVal = _getPlayerColor(_parseColor(colorName));

    final isKiller = _flashingKillerUserId != null && _flashingKillerUserId == userId;
    final isVictim = _flashingVictimUserId != null && _flashingVictimUserId == userId;

    final avatarBorderColor = isKiller
        ? const Color(0xFFFF3D00)
        : isVictim
            ? const Color(0xFFE6393F)
            : const Color(0xFF00E676); // Active turn glowing neon ring

    final hasChat = _playerChatBubbles.containsKey(userId);
    final chatMsg = _playerChatBubbles[userId];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey('active_player_$userId'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Large Prominent Avatar (62 scale) with Pulsing Glow
              AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  final pulse = 1.0 + (_arrowAnimation.value / 12.0) * 0.04;
                  return Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 62 * scale,
                      height: 62 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarBorderColor,
                          width: 3.2 * scale,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avatarBorderColor.withValues(alpha: 0.65),
                            blurRadius: 14 * scale,
                            spreadRadius: 2.5 * scale,
                          ),
                          BoxShadow(
                            color: colorVal.withValues(alpha: 0.4),
                            blurRadius: 8 * scale,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          isMe ? 'assets/graphics/musician_avatar.png' : 'assets/graphics/wealthy_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Attached Turn Countdown Timer Badge (15s)
              if (!_hasRolledDiceThisTurn)
                Positioned(
                  bottom: -3 * scale,
                  right: -3 * scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(color: Colors.white, width: 1.2 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4 * scale,
                          offset: Offset(0, 1.5 * scale),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_turnSecondsRemaining}s',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Active Player Color Badge & Username
          SizedBox(height: 4 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
            decoration: BoxDecoration(
              color: colorVal.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8 * scale),
              border: Border.all(color: Colors.white, width: 1 * scale),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4 * scale,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6 * scale,
                  height: 6 * scale,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Text(
                  isMe ? '$username (YOU)' : '$username (${colorName.toUpperCase()})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8.5 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Pop Chat Bubble beneath active avatar if active
          if (hasChat && chatMsg != null) ...[
            SizedBox(height: 5 * scale),
            _buildSpeechBubble(chatMsg, scale),
          ],
        ],
      ),
    );
  }

  // ── WAITING PLAYERS (Top Row - Horizontally Arranged) ───────────────
  List<Widget> _buildWaitingPlayersAvatars(double scale) {
    final waitingList = _getWaitingPlayersList();
    return waitingList.map((player) {
      final uid = player['user_id'] as int;
      final username = player['username'] as String;
      final colorName = player['color'] as String;
      final isMe = player['isMe'] as bool;
      final colorVal = _getPlayerColor(_parseColor(colorName));

      final isKiller = _flashingKillerUserId != null && _flashingKillerUserId == uid;
      final isVictim = _flashingVictimUserId != null && _flashingVictimUserId == uid;

      final avatarBorderColor = isKiller
          ? const Color(0xFFFF3D00)
          : isVictim
              ? const Color(0xFFE6393F)
              : colorVal.withValues(alpha: 0.45);

      final hasChat = _playerChatBubbles.containsKey(uid);
      final chatMsg = _playerChatBubbles[uid];

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.only(left: 8 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.75, // Muted/dimmed waiting status
              child: Container(
                width: 38 * scale,
                height: 38 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarBorderColor,
                    width: 1.8 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4 * scale,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    isMe ? 'assets/graphics/musician_avatar.png' : 'assets/graphics/wealthy_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2 * scale),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1.2 * scale),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(5 * scale),
                border: Border.all(color: colorVal.withValues(alpha: 0.5), width: 0.8),
              ),
              child: Text(
                isMe ? 'YOU' : '$username (${colorName[0].toUpperCase()})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 7 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
            if (hasChat && chatMsg != null) ...[
              SizedBox(height: 3 * scale),
              _buildSpeechBubble(chatMsg, scale * 0.85),
            ],
          ],
        ),
      );
    }).toList();
  }

  // ── Track Builders & Cell Grids ─────────────────────────────────────
  Widget _buildVerticalTrack(int startRow, int endRow, int startCol, int endCol, double scale) {
    final rowCount = endRow - startRow + 1;
    final colCount = endCol - startCol + 1;
    return Column(
      children: List.generate(rowCount, (r) {
        final row = startRow + r;
        return Expanded(
          child: Row(
            children: List.generate(colCount, (c) {
              final col = startCol + c;
              return Expanded(
                child: _buildTrackCell(row, col, scale),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalTrack(int startRow, int endRow, int startCol, int endCol, double scale) {
    final rowCount = endRow - startRow + 1;
    final colCount = endCol - startCol + 1;
    return Column(
      children: List.generate(rowCount, (r) {
        final row = startRow + r;
        return Expanded(
          child: Row(
            children: List.generate(colCount, (c) {
              final col = startCol + c;
              return Expanded(
                child: _buildTrackCell(row, col, scale),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildTrackCell(int row, int col, double scale) {
    // Colored Track Tiles
    Color cellBgColor = Colors.white;

    if (col >= 6 && col <= 8 && row <= 5) {
      if (col == 7 && row >= 1) cellBgColor = const Color(0xFFF4B400); // Yellow stretch
    } else if (col >= 6 && col <= 8 && row >= 9) {
      if (col == 7 && row <= 13) cellBgColor = const Color(0xFFDB4437); // Red stretch
    } else if (row >= 6 && row <= 8 && col <= 5) {
      if (row == 7 && col >= 1) cellBgColor = const Color(0xFF0F9D58); // Green stretch
    } else if (row >= 6 && row <= 8 && col >= 9) {
      if (row == 7 && col <= 13) cellBgColor = const Color(0xFF4285F4); // Blue stretch
    }

    // Start Markers
    bool isStartPoint = false;
    if (row == 6 && col == 1) { cellBgColor = const Color(0xFF0F9D58); isStartPoint = true; }
    else if (row == 1 && col == 8) { cellBgColor = const Color(0xFFF4B400); isStartPoint = true; }
    else if (row == 8 && col == 13) { cellBgColor = const Color(0xFF4285F4); isStartPoint = true; }
    else if (row == 13 && col == 6) { cellBgColor = const Color(0xFFDB4437); isStartPoint = true; }

    // Safe Stars
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

    Widget? activePawn = _buildTrackPiece(row, col, scale);

    return Container(
      decoration: BoxDecoration(
        color: cellBgColor,
        border: Border.all(color: const Color(0xFFDFE5EB), width: 0.5),
      ),
      child: Stack(
        children: [
          if (cellChild != null) Center(child: cellChild),
          if (activePawn != null) Center(child: activePawn),
        ],
      ),
    );
  }

  // ── Home Base Quadrants ─────────────────────────────────────────────
  Widget _buildHomeBaseQuadrant(PlayerColor playerColor, double scale) {
    final color = _getPlayerColor(playerColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: color)),
        FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.72,
          alignment: Alignment.center,
          child: Image.asset(
            _getPieceBackgroundAsset(playerColor),
            fit: BoxFit.contain,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.72,
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(5 * scale),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: Center(child: _buildHomeBaseSlotPawn(0, playerColor, scale))),
                      Expanded(child: Center(child: _buildHomeBaseSlotPawn(1, playerColor, scale))),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: Center(child: _buildHomeBaseSlotPawn(2, playerColor, scale))),
                      Expanded(child: Center(child: _buildHomeBaseSlotPawn(3, playerColor, scale))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeBaseSlotPawn(int slotIndex, PlayerColor playerColor, double scale) {
    if (widget.isOnline) {
      // Online mode base tokens
      final colorName = playerColor.name.toLowerCase();

      // Check if this color belongs to an active player in match
      final isActiveColor = _onlinePlayers.any(
        (p) => (p['color']?.toString().toLowerCase()) == colorName,
      );
      if (!isActiveColor) {
        return const SizedBox.shrink(); // Inactive corner remains empty!
      }

      final positions = _onlineTokenPositions[colorName];
      if (positions == null || slotIndex >= positions.length) return const SizedBox.shrink();

      final step = positions[slotIndex];
      if (step != -1) return const SizedBox.shrink(); // Token not in base

      final isMyColor = colorName == _myColorName;
      final isTurnActive = _isMyTurn;
      final isMovable = _serverMovableTokens.contains(slotIndex) ||
          (isTurnActive && isMyColor && _lastDiceValue == 6);
      final isValidMove = isTurnActive && isMyColor && isMovable;
      final pieceAsset = _getPieceAsset(playerColor);

      if (isValidMove) {
        return Center(
          child: AnimatedBuilder(
            animation: _arrowAnimation,
            builder: (context, child) {
              final bounce = 1.0 + (_arrowAnimation.value / 12.0) * 0.18;
              return Transform.scale(
                scale: bounce,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (kDebugMode) print('🎲 [BASE PAWN TAP] slot=$slotIndex, color=$colorName');
                    _moveTokenOnline(slotIndex);
                  },
                  child: Container(
                    width: 26 * scale,
                    height: 26 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF00E676), blurRadius: 10, spreadRadius: 3),
                      ],
                      border: Border.all(color: const Color(0xFF00E676), width: 2.5 * scale),
                    ),
                    child: Image.asset(pieceAsset, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
        );
      }

      return Center(
        child: Container(
          width: 24 * scale,
          height: 24 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 2),
            ],
          ),
          child: Image.asset(pieceAsset, fit: BoxFit.contain),
        ),
      );
    }

    // Practice mode base tokens
    final playerExists = _gameEngine.players.any((p) => p.color == playerColor);
    if (!playerExists) return const SizedBox.shrink();

    final player = _gameEngine.players.firstWhere((p) => p.color == playerColor);
    if (slotIndex >= player.pieces.length) return const SizedBox.shrink();

    final piece = player.pieces[slotIndex];
    if (piece.state != PieceState.home) return const SizedBox.shrink();

    final isValidMove = _validMovePieceIds.contains(piece.id);
    final pieceAsset = _getPieceAsset(piece.color);

    return Center(
      child: GestureDetector(
        onTap: () {
          if (isValidMove && _gameEngine.currentPlayer.isHuman) {
            setState(() => _selectedPieceId = piece.id);
            _movePiecePractice(piece.id);
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
                const BoxShadow(color: Colors.green, blurRadius: 8, spreadRadius: 2),
            ],
            border: isValidMove ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Image.asset(pieceAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }

  // ── Track Pieces (Shared Track & Home Stretch) ───────────────────────
  Widget? _buildTrackPiece(int row, int col, double scale) {
    if (widget.isOnline) {
      // ── ONLINE PIECE POSITIONING ──────────────────────────────────
      final sharedPathIndex = _sharedPath.indexWhere((pos) => pos.$1 == row && pos.$2 == col);

      if (sharedPathIndex != -1) {
        // Collect all tokens on this shared track cell across active player colors
        final cellTokens = <Map<String, dynamic>>[];
        for (final p in _onlinePlayers) {
          final colorName = p['color']?.toString().toLowerCase() ?? '';
          final stepsList = _onlineTokenPositions[colorName] ?? [];
          final startOffset = _getStartOffsetForColor(colorName);

          for (int i = 0; i < stepsList.length; i++) {
            final steps = stepsList[i];
            if (steps >= 0 && steps <= 50) {
              final globalPos = (startOffset + steps) % 52;
              if (globalPos == sharedPathIndex) {
                final pColor = _parseColor(colorName);
                final isMyColor = colorName == _myColorName;
                final isTurnActive = _isMyTurn;
                final isMovable = _serverMovableTokens.contains(i) ||
                    (isTurnActive && isMyColor && steps >= 0 && steps + (_lastDiceValue ?? 0) <= 56);
                final isValidMove = isTurnActive && isMyColor && isMovable;
                cellTokens.add({
                  'color': pColor,
                  'is_valid_move': isValidMove,
                  'token_index': i,
                });
              }
            }
          }
        }

        if (cellTokens.isNotEmpty) {
          cellTokens.sort((a, b) => (b['is_valid_move'] == true ? 1 : 0).compareTo(a['is_valid_move'] == true ? 1 : 0));
          final topToken = cellTokens.first;
          final pColor = topToken['color'] as PlayerColor;
          final isValidMove = topToken['is_valid_move'] == true;
          final tokenIdx = topToken['token_index'] as int;
          return _buildTokenWidget(
            pColor,
            isValidMove,
            () => _moveTokenOnline(tokenIdx),
            scale,
            count: cellTokens.length,
          );
        }
      }

      // Check home stretch tokens (steps 51 to 55)
      for (final entry in _homeStretchPaths.entries) {
        final playerColor = entry.key;
        final colorName = playerColor.name.toLowerCase();

        final isActiveColor = _onlinePlayers.any(
          (p) => (p['color']?.toString().toLowerCase()) == colorName,
        );
        if (!isActiveColor) continue;

        final path = entry.value;
        final homeStretchIndex = path.indexWhere((pos) => pos.$1 == row && pos.$2 == col);

        if (homeStretchIndex != -1) {
          final stepsList = _onlineTokenPositions[colorName] ?? [];
          for (int i = 0; i < stepsList.length; i++) {
            final steps = stepsList[i];
            if (steps >= 51 && steps <= 55) {
              final stretchPos = steps - 51;
              if (stretchPos == homeStretchIndex) {
                final isMyColor = colorName == _myColorName;
                final isTurnActive = _isMyTurn;
                final isMovable = _serverMovableTokens.contains(i) ||
                    (isTurnActive && isMyColor && steps >= 51 && steps + (_lastDiceValue ?? 0) <= 56);
                final isValidMove = isTurnActive && isMyColor && isMovable;
                return _buildTokenWidget(playerColor, isValidMove, () => _moveTokenOnline(i), scale);
              }
            }
          }
        }
      }

      return null;
    }

    // ── PRACTICE MODE PIECE POSITIONING ──────────────────────────────
    final sharedPathIndex = _sharedPath.indexWhere((pos) => pos.$1 == row && pos.$2 == col);
    if (sharedPathIndex != -1) {
      for (final player in _gameEngine.players) {
        for (final piece in player.pieces) {
          if (piece.state == PieceState.active && piece.currentPosition == sharedPathIndex) {
            final isValidMove = _validMovePieceIds.contains(piece.id);
            return _buildTokenWidget(
              piece.color,
              isValidMove,
              () {
                if (isValidMove && _gameEngine.currentPlayer.isHuman) {
                  setState(() => _selectedPieceId = piece.id);
                  _movePiecePractice(piece.id);
                }
              },
              scale,
              isSelected: _selectedPieceId == piece.id,
            );
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
              final isValidMove = _validMovePieceIds.contains(piece.id);
              return _buildTokenWidget(
                piece.color,
                isValidMove,
                () {
                  if (isValidMove && _gameEngine.currentPlayer.isHuman) {
                    setState(() => _selectedPieceId = piece.id);
                    _movePiecePractice(piece.id);
                  }
                },
                scale,
                isSelected: _selectedPieceId == piece.id,
              );
            }
          }
        }
      }
    }

    return null;
  }

  Widget _buildTokenWidget(
    PlayerColor color,
    bool isValidMove,
    VoidCallback onTap,
    double scale, {
    bool isSelected = false,
    int count = 1,
  }) {
    final pieceAsset = _getPieceAsset(color);

    final tokenCore = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 24 * scale,
          height: 24 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 3 * scale,
                offset: const Offset(0, 1),
              ),
              if (isValidMove)
                const BoxShadow(
                  color: Color(0xFF00E676),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              if (isSelected)
                const BoxShadow(
                  color: Colors.amber,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
            border: isValidMove
                ? Border.all(color: const Color(0xFF00E676), width: 2.5 * scale)
                : isSelected
                    ? Border.all(color: Colors.amber, width: 2 * scale)
                    : null,
          ),
          child: Image.asset(pieceAsset, fit: BoxFit.contain),
        ),
        if (count > 1)
          Positioned(
            top: -2 * scale,
            right: -2 * scale,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 1 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD200),
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: Colors.black87, width: 1),
              ),
              child: Text(
                'x$count',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 7 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );

    if (isValidMove) {
      return AnimatedBuilder(
        animation: _arrowAnimation,
        builder: (context, child) {
          final bounce = 1.0 + (_arrowAnimation.value / 12.0) * 0.16;
          return Transform.scale(
            scale: bounce,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: tokenCore,
            ),
          );
        },
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isValidMove ? onTap : null,
      child: tokenCore,
    );
  }

  // ── Asset & Color Helpers ───────────────────────────────────────────
  int _getStartOffsetForColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return 0;
      case 'green':
        return 13;
      case 'yellow':
        return 26;
      case 'blue':
        return 39;
      default:
        return 0;
    }
  }

  PlayerColor _parseColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return PlayerColor.red;
      case 'green':
        return PlayerColor.green;
      case 'yellow':
        return PlayerColor.yellow;
      case 'blue':
        return PlayerColor.blue;
      default:
        return PlayerColor.red;
    }
  }

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
}

// ── Pinwheel Center CustomPainter ──────────────────────────────────────
class PinwheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Top Triangle: GREEN
    paint.color = const Color(0xFF0F9D58);
    final greenPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Right Triangle: YELLOW
    paint.color = const Color(0xFFF4B400);
    final yellowPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Bottom Triangle: BLUE
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Left Triangle: RED
    paint.color = const Color(0xFFDB4437);
    final redPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
