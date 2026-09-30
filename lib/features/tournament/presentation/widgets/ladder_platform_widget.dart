import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/tournament_round_info.dart';

class LadderPlatformWidget extends StatelessWidget {
  final TournamentRoundInfo roundInfo;
  final bool isCurrentRound;
  final VoidCallback? onTap;

  const LadderPlatformWidget({
    super.key,
    required this.roundInfo,
    this.isCurrentRound = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final isFinal = roundInfo.isFinal;
    final isCompleted = roundInfo.isCompleted;
    final isLocked = roundInfo.isLocked;

    final islandWidth = isFinal ? 170.0 : 130.0;
    final islandHeight = isFinal ? 90.0 : 70.0;
    final badgeSize = isFinal ? 84.0 : 66.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle for Round 6 if present
          if (roundInfo.subtitle != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                roundInfo.subtitle!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],

          // Stack of Island Platform + Round Badge + Status Overlay
          SizedBox(
            width: islandWidth + 30,
            height: islandHeight + 40,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Floating Island Platform Base
                Positioned(
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/tournament/island_platform.png',
                    width: islandWidth,
                    height: islandHeight,
                    fit: BoxFit.contain,
                  ),
                ),

                // Active Pulse Glow Halo
                if (isCurrentRound)
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: badgeSize + 18,
                      height: badgeSize + 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD54A).withValues(alpha: 0.6),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Round Badge (1 to 6)
                Positioned(
                  bottom: 14,
                  child: SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          roundInfo.badgeAsset,
                          width: badgeSize,
                          height: badgeSize,
                          fit: BoxFit.contain,
                        ),
                        // Completed Checkmark Overlay
                        if (isCompleted)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Image.asset(
                              'assets/images/tournament/check_icon.png',
                              width: 26,
                              height: 26,
                            ),
                          ),
                        // Locked Padlock Overlay
                        if (isLocked)
                          Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/tournament/lock_icon.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Crown icon for Final Stage
                if (isFinal)
                  Positioned(
                    top: -12,
                    child: Image.asset(
                      'assets/images/tournament/crown_icon.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Reward Gold Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrentRound
                    ? [const Color(0xFF6B4500), const Color(0xFF331F00)]
                    : [const Color(0xFF1E143C), const Color(0xFF100925)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrentRound
                    ? const Color(0xFFFFD54A)
                    : const Color(0xFF6749A3).withValues(alpha: 0.5),
                width: isCurrentRound ? 1.5 : 1,
              ),
              boxShadow: isCurrentRound
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD54A).withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/tournament/coin_icon.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatter.format(roundInfo.rewardGold),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isFinal ? 13 : 11,
                        fontWeight: FontWeight.w800,
                        color: isCurrentRound
                            ? const Color(0xFFFFE57F)
                            : (isCompleted ? Colors.white70 : const Color(0xFFFFD54A)),
                      ),
                    ),
                  ],
                ),
                // Secondary Bonus Value for Round 6 (+19,570)
                if (roundInfo.bonusGold != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    '+${formatter.format(roundInfo.bonusGold!)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF69F0AE),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 3),

          // Independent Players Remaining Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 3),
                Text(
                  '${roundInfo.playersRemaining} players',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
