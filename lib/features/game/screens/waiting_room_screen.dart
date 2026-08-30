import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';

/// Phase 1 & 2: Real-time waiting room with:
/// - Instant check for buffered MatchFound events (Addition B)
/// - 15-second matchmaking countdown
/// - WebSocket subscription for MatchFound event on private-user.{userId}
/// - 3-second HTTP polling fallback (/api/v1/matchmaking/active-match)
/// - Final authoritative server check before declaring timeout
/// - Automatic queue leave on timeout or back-press with 'already_matched' recovery
/// - Immediate transition to board when match is found
class WaitingRoomScreen extends ConsumerStatefulWidget {
  const WaitingRoomScreen({
    super.key,
    this.betAmount = 500,
    this.playerCount = 4,
    this.initialMatchData,
  });

  final int betAmount;
  final int playerCount;

  /// If the quick-match response returned status: 'matched' immediately,
  /// this contains the match data (room_id, game_id, players).
  /// If null, we're in 'waiting' state and listen for MatchFound via WS and polling.
  final Map<String, dynamic>? initialMatchData;

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen>
    with TickerProviderStateMixin {
  // ── Matchmaking state ──────────────────────────────────────────────
  static const int _matchmakingTimeoutSec = 15;
  int _remainingSeconds = _matchmakingTimeoutSec;
  Timer? _countdownTimer;
  Timer? _pollingTimer;
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  bool _isLeavingQueue = false;
  bool _matchFound = false;

  // Players found so far (populated on MatchFound or immediate match)
  List<_WaitingPlayer> _players = [];
  int? _roomId;
  int? _gameId;

  // Pulse animation for searching slots
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize empty player slots
    _initializeSlots();

    // 1. Check if match was already returned immediately from lobby quick-match API call
    if (widget.initialMatchData != null) {
      final data = widget.initialMatchData!;
      final status = data['status']?.toString();
      if (status == 'matched') {
        _handleMatchFound(data);
        return;
      }
    }

    // 2. Check Addition B: Did a MatchFound event arrive in WS buffer during screen transition?
    final wsService = ref.read(webSocketServiceProvider);
    final bufferedMatch = wsService.consumeBufferedMatchFound();
    if (bufferedMatch != null) {
      if (kDebugMode) {
        print('⚡ [WR] Found buffered MatchFound event on screen mount! Navigating to match.');
      }
      _handleMatchFound(bufferedMatch);
      return;
    }

    // 3. Otherwise, start countdown, polling fallback & listen for WS events
    _startCountdown();
    _startPolling();
    _subscribeToMatchEvents();
  }

  void _initializeSlots() {
    _players = List.generate(widget.playerCount, (index) {
      return _WaitingPlayer(
        id: '',
        name: 'Searching...',
        avatarUrl: '',
        seatPosition: index + 1,
        color: '',
        isEmptySlot: true,
      );
    });
  }

  // ── Countdown Timer ─────────────────────────────────────────────────
  void _startCountdown() {
    _remainingSeconds = _matchmakingTimeoutSec;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  // ── Polling Fallback (every 3s) ──────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _matchFound || _isLeavingQueue) {
        timer.cancel();
        return;
      }

      try {
        final apiClient = ref.read(apiClientProvider);
        final response = await apiClient.get(ApiEndpoints.matchmakingActiveMatch);
        if (!mounted || _matchFound || _isLeavingQueue) return;

        if (response is Map<String, dynamic> && response['data'] != null) {
          final matchData = response['data'] as Map<String, dynamic>;
          if (matchData['status'] == 'matched') {
            if (kDebugMode) {
              print('🎯 [WR POLL] Match detected via polling fallback: $matchData');
            }
            _handleMatchFound(matchData);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [WR POLL] Error checking active match: $e');
        }
      }
    });
  }

  // ── WebSocket: Listen for MatchFound ────────────────────────────────
  void _subscribeToMatchEvents() {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    if (userId == null) {
      if (kDebugMode) print('⚠️ [WR] No userId found, cannot subscribe to WS');
      return;
    }

    final wsService = ref.read(webSocketServiceProvider);

    // Ensure user channel is subscribed
    if (!wsService.isConnected) {
      wsService.connect().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            wsService.subscribeToUserChannel(userId);
          }
        });
      });
    } else {
      wsService.subscribeToUserChannel(userId);
    }

    // Listen for MatchFound event
    _wsSubscription?.cancel();
    _wsSubscription = wsService.eventStream.listen((event) {
      if (kDebugMode) {
        print('📩 [WR] WS Event: ${event.event} on ${event.channel}');
      }

      if (event.event == '.match.found' || event.event == 'match.found') {
        if (mounted && !_matchFound) {
          _handleMatchFound(event.payload);
        }
      }
    });
  }

  // ── Match Found Handler ─────────────────────────────────────────────
  void _handleMatchFound(Map<String, dynamic> data) {
    // Single source of truth: immediately cancel all timers
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    final roomId = data['quick_match_id'] ?? data['room_id'];
    final gameId = data['game_id'];
    final playersRaw = data['players'] as List<dynamic>?;

    if (kDebugMode) {
      print('🎉 [WR] Match found! match=$roomId game=$gameId players=${playersRaw?.length}');
    }

    setState(() {
      _matchFound = true;
      _roomId = roomId is int ? roomId : int.tryParse(roomId.toString());
      _gameId = gameId is int ? gameId : int.tryParse(gameId.toString());

      if (playersRaw != null) {
        _players = playersRaw.map((p) {
          final pMap = p as Map<String, dynamic>;
          return _WaitingPlayer(
            id: pMap['user_id']?.toString() ?? '',
            name: pMap['username']?.toString() ?? 'Player',
            avatarUrl: pMap['avatar_url']?.toString() ?? '',
            seatPosition: pMap['seat_position'] ?? 0,
            color: pMap['color']?.toString() ?? '',
            isEmptySlot: false,
          );
        }).toList();

        // Pad remaining slots if less than playerCount
        while (_players.length < widget.playerCount) {
          _players.add(_WaitingPlayer(
            id: '',
            name: 'Searching...',
            avatarUrl: '',
            seatPosition: _players.length + 1,
            color: '',
            isEmptySlot: true,
          ));
        }
      }
    });

    // Short delay to show the "Match Found!" state, then navigate to board
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToBoard();
      }
    });
  }

  void _navigateToBoard() {
    context.go(
      AppConstants.ludoBoardRoute,
      extra: {
        'players': widget.playerCount,
        'bet': widget.betAmount,
        'quick_match_id': _roomId,
        'room_id': _roomId,
        'game_id': _gameId,
        'isOnline': true,
      },
    );
  }

  // ── Timeout Handler ─────────────────────────────────────────────────
  Future<void> _handleTimeout() async {
    if (_matchFound || _isLeavingQueue) return;

    // Phase 2 Fix: ONE final authoritative server check before declaring timeout
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.matchmakingActiveMatch);
      if (response is Map<String, dynamic> && response['data'] != null) {
        final matchData = response['data'] as Map<String, dynamic>;
        if (matchData['status'] == 'matched') {
          if (kDebugMode) {
            print('🛡️ [WR TIMEOUT GUARD] Last-second match found! Cancelling failure.');
          }
          if (mounted && !_matchFound) {
            _handleMatchFound(matchData);
            return;
          }
        }
      }
    } catch (_) {}

    if (!mounted || _matchFound || _isLeavingQueue) return;

    setState(() => _isLeavingQueue = true);
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    // Leave the matchmaking queue
    await _leaveQueue();

    if (!mounted || _matchFound) return;

    // Show "No opponents found" dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1058),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8C7DF5), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.search_off_rounded, color: Color(0xFFFF9B63), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No Opponents Found',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Could not find enough players in time. Your coins have NOT been deducted. Please try again.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) context.pop(); // Back to lobby
            },
            child: const Text(
              'TRY AGAIN',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFCCA3FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Leave Queue (API call) ──────────────────────────────────────────
  Future<void> _leaveQueue() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(ApiEndpoints.matchmakingLeave);

      // Backend safety net: If response indicates already_matched, recover gracefully!
      if (response is Map<String, dynamic> &&
          response['status'] == 'already_matched' &&
          response['data'] != null) {
        if (kDebugMode) {
          print('🛡️ [WR LEAVE GUARD] Backend reported already_matched on leave! Recovering match.');
        }
        if (mounted && !_matchFound) {
          _handleMatchFound(response['data'] as Map<String, dynamic>);
          return;
        }
      }

      if (kDebugMode) print('✅ [WR] Left matchmaking queue');
    } catch (e) {
      if (kDebugMode) print('⚠️ [WR] Error leaving queue: $e');
    }
  }

  // ── Back Button Handler ─────────────────────────────────────────────
  Future<void> _handleBackPress() async {
    if (_matchFound || _isLeavingQueue) return;

    setState(() => _isLeavingQueue = true);
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    await _leaveQueue();

    if (mounted && !_matchFound) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _wsSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── BUILD ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _isLeavingQueue ? Colors.white24 : Colors.white,
                          size: 24 * scale,
                        ),
                        onPressed: _isLeavingQueue ? null : _handleBackPress,
                      ),
                      Expanded(
                        child: Text(
                          _matchFound ? 'MATCH FOUND!' : 'FINDING MATCH',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 18 * scale,
                            color: _matchFound ? const Color(0xFF56AB2F) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 48 * scale),
                    ],
                  ),
                ),

                // ── Bet Info Capsule ────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C073E).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(color: const Color(0xFFFFD369), width: 1.5 * scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/graphics/icon_coins.png', width: 22 * scale, height: 22 * scale),
                      SizedBox(width: 6 * scale),
                      Text(
                        'ENTRY FEE: ${widget.betAmount} COINS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD369),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),

                // ── Countdown / Match Found Banner ──────────
                if (_matchFound)
                  _buildMatchFoundBanner(scale)
                else
                  _buildCountdownSection(scale),

                SizedBox(height: 28 * scale),

                // ── Player Slots Grid ───────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16 * scale,
                        mainAxisSpacing: 16 * scale,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: widget.playerCount,
                      itemBuilder: (context, index) {
                        if (index < _players.length) {
                          return _buildPlayerSlot(_players[index], scale);
                        }
                        return _buildPlayerSlot(
                          _WaitingPlayer(
                            id: '',
                            name: 'Searching...',
                            avatarUrl: '',
                            seatPosition: index + 1,
                            color: '',
                            isEmptySlot: true,
                          ),
                          scale,
                        );
                      },
                    ),
                  ),
                ),

                // ── Leave Queue Button ──────────────────────
                if (!_matchFound)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32 * scale, vertical: 16 * scale),
                    child: GestureDetector(
                      onTap: _isLeavingQueue ? null : _handleBackPress,
                      child: Container(
                        width: double.infinity,
                        height: 50 * scale,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25 * scale),
                          border: Border.all(
                            color: _isLeavingQueue ? Colors.white24 : const Color(0xFFFF4D4D),
                            width: 1.5 * scale,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _isLeavingQueue
                            ? SizedBox(
                                width: 22 * scale,
                                height: 22 * scale,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                ),
                              )
                            : Text(
                                'LEAVE QUEUE',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF4D4D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Countdown Section ───────────────────────────────────────────────
  Widget _buildCountdownSection(double scale) {
    final progress = _remainingSeconds / _matchmakingTimeoutSec;
    return Column(
      children: [
        Text(
          'SEARCHING FOR OPPONENTS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12 * scale,
            letterSpacing: 1.2,
            color: Colors.white60,
          ),
        ),
        SizedBox(height: 12 * scale),

        // Circular countdown timer
        SizedBox(
          width: 80 * scale,
          height: 80 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80 * scale,
                height: 80 * scale,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5 * scale,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.3 ? const Color(0xFFFF9B63) : const Color(0xFFFF4D4D),
                  ),
                ),
              ),
              Text(
                '${_remainingSeconds}s',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w900,
                  color: progress > 0.3 ? const Color(0xFFFF9B63) : const Color(0xFFFF4D4D),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8 * scale),
        Text(
          '${widget.playerCount}-Player Match  •  ${widget.betAmount} coins',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11 * scale,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  // ── Match Found Banner ──────────────────────────────────────────────
  Widget _buildMatchFoundBanner(double scale) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
            ),
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF56AB2F).withValues(alpha: 0.5),
                blurRadius: 20 * scale,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 24 * scale),
              SizedBox(width: 10 * scale),
              Text(
                'MATCH FOUND!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          'Starting game...',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12 * scale,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  // ── Player Slot Card ────────────────────────────────────────────────
  Widget _buildPlayerSlot(_WaitingPlayer player, double scale) {
    if (player.isEmptySlot) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05 * _pulseAnimation.value),
              borderRadius: BorderRadius.circular(20 * scale),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15 * _pulseAnimation.value),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32 * scale,
                  height: 32 * scale,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5 * scale,
                    color: const Color(0xFFFF9B63),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  'Searching...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Color-coded border based on seat color
    final borderColor = _getColorFromSeat(player.color);

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.listItemGradient,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: borderColor,
          width: 2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 8 * scale,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 54 * scale,
            height: 54 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2 * scale),
            ),
            child: ClipOval(
              child: player.avatarUrl.isNotEmpty
                  ? (player.avatarUrl.startsWith('http')
                      ? Image.network(
                          player.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            color: Colors.white60,
                            size: 30 * scale,
                          ),
                        )
                      : Image.asset(
                          player.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            color: Colors.white60,
                            size: 30 * scale,
                          ),
                        ))
                  : Icon(
                      Icons.person_rounded,
                      color: Colors.white60,
                      size: 30 * scale,
                    ),
            ),
          ),
          SizedBox(height: 8 * scale),

          // Player Name
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * scale),

          // Color pill
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10 * scale, vertical: 3 * scale),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Text(
              player.color.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromSeat(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return const Color(0xFFE53935);
      case 'green':
        return const Color(0xFF43A047);
      case 'yellow':
        return const Color(0xFFFFD600);
      case 'blue':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF8C7DF5);
    }
  }
}

class _WaitingPlayer {
  final String id;
  final String name;
  final String avatarUrl;
  final int seatPosition;
  final String color;
  final bool isEmptySlot;

  const _WaitingPlayer({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.seatPosition,
    required this.color,
    this.isEmptySlot = false,
  });
}
