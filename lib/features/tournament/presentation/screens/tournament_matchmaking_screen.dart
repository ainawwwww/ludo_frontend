import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../application/tournament_providers.dart';
import '../widgets/avatar_with_frame.dart';

class TournamentMatchmakingScreen extends ConsumerStatefulWidget {
  final int round;
  final String modeName;
  final dynamic tournamentId;

  const TournamentMatchmakingScreen({
    super.key,
    this.round = 1,
    this.modeName = 'classic',
    this.tournamentId,
  });

  @override
  ConsumerState<TournamentMatchmakingScreen> createState() =>
      _TournamentMatchmakingScreenState();
}

class _TournamentMatchmakingScreenState
    extends ConsumerState<TournamentMatchmakingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _fallbackTimer;
  Timer? _pollingTimer;
  StreamSubscription? _wsSubscription;
  late AnimationController _pulseController;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMatchmaking();
    });
  }

  void _initializeMatchmaking() async {
    ref.read(tournamentRunControllerProvider.notifier).startMatchmaking();

    final wsService = ref.read(webSocketServiceProvider);
    await wsService.connect();

    final authUser = ref.read(authProvider).user;
    if (authUser != null) {
      wsService.subscribeToUserChannel(authUser.id);
    }

    // Listen to WebSocket stream for TournamentMatchFound event
    _wsSubscription = wsService.eventStream.listen((event) {
      if (_isTransitioning) return;
      final eventName = event.event.toLowerCase();

      if (eventName.contains('match.found') ||
          eventName.contains('matchfound') ||
          eventName.contains('tournamentmatchfound')) {
        _handleMatchFound(event.payload);
      }
    });

    // Also check if match was buffered recently
    final buffered = wsService.consumeBufferedMatchFound();
    if (buffered != null && !_isTransitioning) {
      _handleMatchFound(buffered);
      return;
    }

    // Call backend continue / queue API for this tournament
    var activeRun = ref.read(tournamentRunControllerProvider);
    if (activeRun == null) {
      await ref.read(tournamentRunControllerProvider.notifier).resumeActiveRun(widget.tournamentId);
      activeRun = ref.read(tournamentRunControllerProvider);
    }

    final effectiveTournamentId = widget.tournamentId ?? activeRun?.tournamentId ?? 1;

    try {
      final repo = ref.read(tournamentRepositoryProvider);
      final res = await repo.continueMatchApi(effectiveTournamentId);
      final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
      if (res['status'] == 'matched' || data['status'] == 'matched') {
        _handleMatchFound(data);
        return;
      }
    } catch (_) {}

    // Polling fallback every 2 seconds to guarantee match resolution
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || _isTransitioning) {
        timer.cancel();
        return;
      }
      try {
        final repo = ref.read(tournamentRepositoryProvider);
        final res = await repo.continueMatchApi(effectiveTournamentId);
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
        if (res['status'] == 'matched' || data['status'] == 'matched') {
          timer.cancel();
          _handleMatchFound(data);
        }
      } catch (_) {}
    });
  }

  void _handleMatchFound(Map<String, dynamic> payload) {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    _fallbackTimer?.cancel();
    _pollingTimer?.cancel();
    _wsSubscription?.cancel();

    final map = payload['data'] is Map<String, dynamic>
        ? payload['data'] as Map<String, dynamic>
        : payload;

    final int? roomId = map['room_id'] is int
        ? map['room_id'] as int
        : int.tryParse(map['room_id']?.toString() ?? '');
    final int? gameId = map['game_id'] is int
        ? map['game_id'] as int
        : int.tryParse(map['game_id']?.toString() ?? '');

    final authUser = ref.read(authProvider).user;
    String opponentName = 'Challenger';
    int opponentLevel = widget.round * 2 + 1;
    String? opponentAvatar;

    final playersList = map['players'] ?? payload['players'];
    if (playersList is List) {
      for (final p in playersList) {
        if (p is Map) {
          final pId = (p['user_id'] as num?)?.toInt();
          if (authUser == null || pId != authUser.id) {
            opponentName = p['username']?.toString() ?? 'Opponent';
            opponentAvatar = p['avatar_url']?.toString();
            opponentLevel = (p['level'] as num?)?.toInt() ?? opponentLevel;
            break;
          }
        }
      }
    }

    _transitionToVs(
      roomId: roomId,
      gameId: gameId,
      opponentName: opponentName,
      opponentLevel: opponentLevel,
      opponentAvatar: opponentAvatar,
    );
  }

  void _transitionToVs({
    int? roomId,
    int? gameId,
    required String opponentName,
    required int opponentLevel,
    String? opponentAvatar,
  }) {
    if (!mounted) return;
    context.pushReplacement(
      AppConstants.tournamentVsRoute,
      extra: {
        'round': widget.round,
        'mode': widget.modeName,
        'roomId': roomId,
        'gameId': gameId,
        'opponentName': opponentName,
        'opponentLevel': opponentLevel,
        'opponentAvatar': opponentAvatar,
      },
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _pollingTimer?.cancel();
    _wsSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Night-sky background
          Positioned.fill(
            child: Image.asset(
              'assets/images/tournament/tournament_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top spacer & cancel button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _cancel,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // "ROUND N" Glowing Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF283593)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD54A),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54A).withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.round >= 6 ? 'FINAL ROUND 6' : 'ROUND ${widget.round}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Color(0xFFFFE57F),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 24),

                // "Finding Opponent…" with Pulsing Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Finding Opponent',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    _buildPulsingDots(),
                  ],
                ),

                const SizedBox(height: 40),

                // Two Avatars with VS Burst in Center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Player Avatar
                    Builder(
                      builder: (context) {
                        final authUser = ref.watch(authProvider).user;
                        final myName = authUser?.username ?? 'You';
                        final myLevel = authUser?.level ?? 1;
                        final myAvatar = authUser?.avatarUrl ?? 'assets/graphics/profile/avatars/avatar_cyber_tiger.png';

                        return Column(
                          children: [
                            AvatarWithFrame(
                              size: 96,
                              assetPath: myAvatar,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              myName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Lvl $myLevel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(width: 20),

                    // Pulsing / Rotating VS Burst
                    RotationTransition(
                      turns: Tween(begin: -0.04, end: 0.04).animate(_pulseController),
                      child: ScaleTransition(
                        scale: Tween(begin: 0.95, end: 1.1).animate(_pulseController),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/tournament/vs_burst.png',
                              width: 88,
                              height: 88,
                            ),
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF4A1000),
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Opponent Placeholder Avatar (Searching shimmer)
                    Column(
                      children: [
                        const AvatarWithFrame(
                          size: 96,
                          isOpponent: true,
                        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .shimmer(duration: 1200.ms, color: const Color(0xFF64B5F6)),
                        const SizedBox(height: 8),
                        const Text(
                          'Searching…',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Matchmaking',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Cancel Button at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    ),
                    onPressed: _cancel,
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDots() {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFFFD54A),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(delay: (index * 200).ms, duration: 400.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2));
      }),
    );
  }

  void _cancel() async {
    SoundService().playButtonClick();
    _fallbackTimer?.cancel();
    _pollingTimer?.cancel();
    _wsSubscription?.cancel();
    final activeRun = ref.read(tournamentRunControllerProvider);
    final effectiveTournamentId = widget.tournamentId ?? activeRun?.tournamentId ?? 1;
    try {
      final repo = ref.read(tournamentRepositoryProvider);
      await repo.leaveQueueApi(effectiveTournamentId);
    } catch (_) {}
    ref.read(tournamentRunControllerProvider.notifier).cancelMatchmaking();
    if (mounted) context.pop();
  }
}
