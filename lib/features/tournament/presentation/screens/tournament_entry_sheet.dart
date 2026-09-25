import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../application/tournament_providers.dart';
import '../../domain/tournament_card_model.dart';

class TournamentEntrySheet extends ConsumerWidget {
  final TournamentCardModel tournament;

  const TournamentEntrySheet({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat('#,###');
    final mode = tournament.mode;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF281754),
            Color(0xFF140B2D),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: mode.accentColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Mode Trophy & Title
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mode.accentColor, width: 1),
                  ),
                  child: Image.asset(mode.trophyAsset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${mode.displayName} Mode • 6 Rounds Elimination',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Prize & Entry Row Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Total Prize
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Prize Pool',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/tournament/coin_icon.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatter.format(tournament.prizeGold),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 38,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 16),

                  // Entry Fee
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entry Fee',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/tournament/coin_icon.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatter.format(tournament.entryFeeGold),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rules Checklist
            _buildRuleRow(Icons.offline_bolt_rounded, 'Fast 1-on-1 matches against live tournament players.'),
            _buildRuleRow(Icons.military_tech_rounded, 'Win 6 consecutive rounds to claim the Grand Champion Prize.'),
            _buildRuleRow(Icons.shield_rounded, 'Earn gold rewards at each round advanced on the ladder.'),

            const SizedBox(height: 20),

            // Join CTA Button with Glow Asset
            Builder(
              builder: (context) {
                final authUser = ref.watch(authProvider).user;
                final userLevel = authUser?.level ?? 1;
                final isLocked = userLevel < tournament.unlockLevel;
                final userCoins = authUser?.coins ?? 0;
                final hasEnoughCoins = userCoins >= tournament.entryFeeGold;

                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow background
                      if (!isLocked)
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/tournament/claim_button_glow.png',
                            fit: BoxFit.fill,
                          ),
                        ),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLocked ? const Color(0xFF424242) : Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: isLocked
                              ? null
                              : () async {
                                  SoundService().playButtonClick();
                                  if (!hasEnoughCoins) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFFE53935),
                                        content: Text(
                                          'Insufficient balance! You need ${formatter.format(tournament.entryFeeGold)} coins to join.',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final navigator = Navigator.of(context);
                                  final router = GoRouter.of(context);

                                  try {
                                    await ref
                                        .read(tournamentRunControllerProvider.notifier)
                                        .joinTournament(tournament);

                                    navigator.pop();

                                    router.push(
                                      AppConstants.tournamentProgressRoute,
                                      extra: {
                                        'mode': tournament.mode.name,
                                        'tournament': tournament,
                                      },
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFFE53935),
                                          content: Text(
                                            e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isLocked
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock_rounded, color: Colors.white70, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'UNLOCKED AT LEVEL ${tournament.unlockLevel}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white70,
                                          letterSpacing: 1.0,
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
                                      'JOIN TOURNAMENT',
                                      style: TextStyle(
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
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD54A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
