import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';
import '../widgets/avatar_with_frame.dart';

class TournamentMatchmakingScreen extends ConsumerStatefulWidget {
  final int round;
  final String modeName;

  const TournamentMatchmakingScreen({
    super.key,
    this.round = 1,
    this.modeName = 'classic',
  });

  @override
  ConsumerState<TournamentMatchmakingScreen> createState() =>
      _TournamentMatchmakingScreenState();
}

class _TournamentMatchmakingScreenState
    extends ConsumerState<TournamentMatchmakingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _matchmakingTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Simulate 2.5s matchmaking delay before transitioning to VS face-off
    _matchmakingTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        context.pushReplacement(
          AppConstants.tournamentVsRoute,
          extra: {
            'round': widget.round,
            'mode': widget.modeName,
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _matchmakingTimer?.cancel();
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
                    Column(
                      children: [
                        const AvatarWithFrame(
                          size: 96,
                          assetPath: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Lvl 12',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
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

  void _cancel() {
    SoundService().playButtonClick();
    _matchmakingTimer?.cancel();
    ref.read(tournamentRunControllerProvider.notifier).cancelMatchmaking();
    if (mounted) context.pop();
  }
}
