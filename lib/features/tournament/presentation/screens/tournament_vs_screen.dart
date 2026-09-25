import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../application/tournament_providers.dart';
import '../widgets/avatar_with_frame.dart';

class TournamentVsScreen extends ConsumerStatefulWidget {
  final int round;
  final String mode;
  final int? roomId;
  final int? gameId;
  final String opponentName;
  final int opponentLevel;
  final String? opponentAvatar;

  const TournamentVsScreen({
    super.key,
    this.round = 1,
    this.mode = 'classic',
    this.roomId,
    this.gameId,
    this.opponentName = 'Sultan_Ludo',
    this.opponentLevel = 14,
    this.opponentAvatar,
  });

  @override
  ConsumerState<TournamentVsScreen> createState() => _TournamentVsScreenState();
}

class _TournamentVsScreenState extends ConsumerState<TournamentVsScreen> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 3-2-1 Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _launchMatch();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _launchMatch() {
    ref.read(tournamentRunControllerProvider.notifier).startMatch();
    // Navigate into Ludo game engine with tournament context
    context.push(
      AppConstants.ludoBoardRoute,
      extra: {
        'players': 2,
        'bet': 2000,
        'isTournament': true,
        'tournamentRound': widget.round,
        'tournamentMode': widget.mode,
        'room_id': widget.roomId,
        'quick_match_id': widget.roomId,
        'game_id': widget.gameId,
        'isOnline': widget.roomId != null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Space Arena Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/tournament/tournament_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Top "ROUND N" Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E24AA), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFFD54A),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54A).withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.round >= 6 ? 'FINAL CHAMPIONSHIP' : 'ROUND ${widget.round}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFFFFE57F),
                    ),
                  ),
                ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

                const Spacer(),

                // Face-Off Section: Player vs Opponent
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Player Side
                      Builder(
                        builder: (context) {
                          final authUser = ref.watch(authProvider).user;
                          final myName = authUser?.username ?? 'You';
                          final myLevel = authUser?.level ?? 1;
                          final myAvatar = authUser?.avatarUrl ?? 'assets/graphics/profile/avatars/avatar_cyber_tiger.png';

                          return _buildPlayerCard(
                            name: myName,
                            level: myLevel,
                            assetPath: myAvatar,
                            isMe: true,
                          ).animate().slideX(begin: -0.8, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
                        },
                      ),

                      // Center Big VS Burst
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/tournament/vs_burst.png',
                              width: 110,
                              height: 110,
                            ),
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF4A1000),
                                shadows: [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                      // Opponent Side
                      _buildPlayerCard(
                        name: widget.opponentName,
                        level: widget.opponentLevel,
                        assetPath: widget.opponentAvatar ?? 'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
                        isMe: false,
                      ).animate().slideX(begin: 0.8, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                    ],
                  ),
                ),

                const Spacer(),

                // 3-2-1 Countdown Indicator
                Column(
                  children: [
                    Text(
                      'MATCH STARTING IN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        '$_countdown',
                        key: ValueKey<int>(_countdown),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD54A),
                          shadows: [
                            Shadow(
                              color: Color(0xFFE65100),
                              offset: Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required int level,
    required String assetPath,
    required bool isMe,
  }) {
    return Column(
      children: [
        AvatarWithFrame(
          size: 100,
          assetPath: assetPath,
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF2979FF) : const Color(0xFFFF1744),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Lvl $level',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
