import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';
import '../widgets/avatar_with_frame.dart';

class TournamentVsScreen extends ConsumerStatefulWidget {
  final int round;
  final String mode;

  const TournamentVsScreen({
    super.key,
    this.round = 1,
    this.mode = 'classic',
  });

  @override
  ConsumerState<TournamentVsScreen> createState() => _TournamentVsScreenState();
}

class _TournamentVsScreenState extends ConsumerState<TournamentVsScreen> {
  int _countdown = 3;
  Timer? _timer;

  final String _opponentName = 'Sultan_Ludo';
  final int _opponentLevel = 14;

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
    // Navigate into existing Ludo game engine with tournament context
    context.push(
      AppConstants.ludoBoardRoute,
      extra: {
        'players': 2,
        'bet': 2000,
        'isTournament': true,
        'tournamentRound': widget.round,
        'tournamentMode': widget.mode,
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
                      _buildPlayerCard(
                        name: 'You',
                        level: 12,
                        assetPath: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
                        isMe: true,
                      ).animate().slideX(begin: -0.8, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

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
                        name: _opponentName,
                        level: _opponentLevel,
                        assetPath: 'assets/graphics/profile/avatars/avatar_golden_sheikh.png',
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

                // Debug Simulation Panel (Strictly gated behind kDebugMode per User Correction #2)
                if (kDebugMode) ...[
                  _buildDebugSimulationBar(context),
                  const SizedBox(height: 12),
                ],
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

  Widget _buildDebugSimulationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            '🛠 DEBUG MATCH SIMULATOR',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  _timer?.cancel();
                  SoundService().playWinFanfare();
                  context.pushReplacement(
                    AppConstants.tournamentVictoryRoute,
                    extra: {
                      'round': widget.round,
                      'mode': widget.mode,
                    },
                  );
                },
                child: const Text('Simulate Win 🏆', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD50000),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  _timer?.cancel();
                  context.pushReplacement(
                    AppConstants.tournamentDefeatRoute,
                    extra: {
                      'round': widget.round,
                      'mode': widget.mode,
                    },
                  );
                },
                child: const Text('Simulate Loss ❌', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
