import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';

class TournamentChampionScreen extends ConsumerStatefulWidget {
  const TournamentChampionScreen({super.key});

  @override
  ConsumerState<TournamentChampionScreen> createState() =>
      _TournamentChampionScreenState();
}

class _TournamentChampionScreenState
    extends ConsumerState<TournamentChampionScreen> {
  @override
  void initState() {
    super.initState();
    SoundService().playWinFanfare();
  }

  @override
  Widget build(BuildContext context) {
    final activeRun = ref.watch(tournamentRunControllerProvider);
    final formatter = NumberFormat('#,###');
    final isClaimed = activeRun?.isRewardClaimed ?? false;
    final grandPrize = (activeRun?.totalRewardEarned != null && activeRun!.totalRewardEarned > 0)
        ? activeRun.totalRewardEarned
        : 50000;

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

          // Confetti Celebration Overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/tournament/confetti_overlay.png',
              fit: BoxFit.cover,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 2500.ms),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Grand Crown Icon
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD54A).withValues(alpha: 0.7),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/tournament/crown_icon.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  // "CHAMPION!" Headline
                  const Text(
                    'CHAMPION! 👑',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD54A),
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          color: Color(0xFFE65100),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  const Text(
                    'Tournament Completed — Round 6 Won',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Grand Prize Showcase Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A148C), Color(0xFF1A0A3A)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFFD54A),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD54A).withValues(alpha: 0.35),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL GRAND PRIZE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/tournament/coin_icon.png',
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              formatter.format(grandPrize),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54A),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFB78103),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '25% Grand Pool + Round Rewards Credited',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CLAIM / CLAIMED Button with Glow
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isClaimed)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/tournament/claim_button_glow.png',
                              fit: BoxFit.fill,
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isClaimed
                                  ? const Color(0xFF424242)
                                  : Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: isClaimed
                                ? null
                                : () async {
                                    SoundService().playWinFanfare();
                                    await ref
                                        .read(tournamentRunControllerProvider.notifier)
                                        .claimChampionReward();
                                  },
                            child: isClaimed
                                ? const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Color(0xFF69F0AE), size: 22),
                                        SizedBox(width: 8),
                                        Text(
                                          'CLAIMED',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white70,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFFFEA79),
                                          Color(0xFFFFB300),
                                          Color(0xFFE68900),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFFFF7C2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'CLAIM REWARD 🏆',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF4A2800),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // View History & Return to Lobby
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.history, color: Color(0xFFFFD54A), size: 18),
                        label: const Text(
                          'View History',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFFFD54A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          context.push(AppConstants.tournamentHistoryRoute);
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          context.go(AppConstants.tournamentLobbyRoute);
                        },
                        child: Text(
                          'Back to Lobby',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
