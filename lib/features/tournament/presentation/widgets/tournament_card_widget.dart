import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/sound_service.dart';
import '../../domain/tournament_card_model.dart';

class TournamentCardWidget extends StatelessWidget {
  final TournamentCardModel tournament;
  final VoidCallback onTap;

  const TournamentCardWidget({
    super.key,
    required this.tournament,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final formattedPrize = formatter.format(tournament.prizeGold);
    final mode = tournament.mode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: mode.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mode.borderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mode.accentColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            SoundService().playButtonClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Left Trophy Panel
                Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: mode.accentColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    mode.trophyAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),

                // Center Title & Prize Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mode & In-Progress Badges
                      Row(
                        children: [
                          Text(
                            tournament.title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (tournament.isInProgress) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Round ${tournament.currentRound ?? 1}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // "Prize" Label + Coin Icon + Amount
                      Row(
                        children: [
                          Text(
                            'Prize',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Image.asset(
                            'assets/images/tournament/coin_icon.png',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              formattedPrize,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54A),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF996500),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Entry Fee info
                      Text(
                        'Entry: ${formatter.format(tournament.entryFeeGold)} Gold',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right Rounded Yellow Gradient CTA Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
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
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    tournament.isInProgress ? 'Play' : 'View',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A2800),
                      letterSpacing: 0.5,
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
}
