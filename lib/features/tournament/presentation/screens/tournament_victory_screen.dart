import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';
import '../../domain/tournament_config.dart';

class TournamentVictoryScreen extends ConsumerStatefulWidget {
  final int round;
  final String mode;

  const TournamentVictoryScreen({
    super.key,
    this.round = 1,
    this.mode = 'classic',
  });

  @override
  ConsumerState<TournamentVictoryScreen> createState() =>
      _TournamentVictoryScreenState();
}

class _TournamentVictoryScreenState
    extends ConsumerState<TournamentVictoryScreen> {
  @override
  void initState() {
    super.initState();
    SoundService().playWinFanfare();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final roundConfig = TournamentConfig.defaultRounds.firstWhere(
      (r) => r.roundNumber == widget.round,
      orElse: () => TournamentConfig.defaultRounds.first,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background space gradient
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
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2000.ms),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Trophy Icon with Glow
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD54A).withValues(alpha: 0.6),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/tournament/trophy_gold_classic.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  // "VICTORY! 🏆" Headline
                  const Text(
                    'VICTORY! 🏆',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD54A),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Color(0xFFE65100),
                          offset: Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    'You won Round ${widget.round}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reward Earned Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF381552), Color(0xFF1D0E3B)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFFFD54A).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD54A).withValues(alpha: 0.2),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ROUND REWARD',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/tournament/coin_icon.png',
                              width: 26,
                              height: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${formatter.format(roundConfig.rewardGold)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54A),
                              ),
                            ),
                          ],
                        ),
                        if (roundConfig.bonusGold != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+ Bonus: ${formatter.format(roundConfig.bonusGold!)} Gold',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF69F0AE),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Compact Horizontal Ladder Status Strip
                  _buildCompactLadderStrip(widget.round),

                  const Spacer(flex: 2),

                  // CONTINUE CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        SoundService().playButtonClick();
                        await ref
                            .read(tournamentRunControllerProvider.notifier)
                            .completeRound(won: true);

                        if (!context.mounted) return;
                        if (widget.round >= 6) {
                          // All 6 rounds won -> Champion celebration!
                          context.pushReplacement(AppConstants.tournamentChampionRoute);
                        } else {
                          // Return to progress ladder for next round
                          context.pushReplacement(
                            AppConstants.tournamentProgressRoute,
                            extra: {'mode': widget.mode},
                          );
                        }
                      },
                      child: Ink(
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFA000).withValues(alpha: 0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.round >= 6 ? 'CLAIM CHAMPION TITLE 👑' : 'CONTINUE LADDER',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4A2800),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLadderStrip(int wonRound) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(6, (index) {
          final roundNum = index + 1;
          final isPassed = roundNum <= wonRound;
          final isNext = roundNum == wonRound + 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: isPassed
                    ? Image.asset('assets/images/tournament/check_icon.png')
                    : isNext
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD54A), width: 2),
                              color: const Color(0xFF4A3200),
                            ),
                            child: Center(
                              child: Text(
                                '$roundNum',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD54A),
                                ),
                              ),
                            ),
                          )
                        : Image.asset('assets/images/tournament/lock_icon.png'),
              ),
              const SizedBox(height: 4),
              Text(
                'R$roundNum',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isPassed
                      ? const Color(0xFF69F0AE)
                      : (isNext ? const Color(0xFFFFD54A) : Colors.white38),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
