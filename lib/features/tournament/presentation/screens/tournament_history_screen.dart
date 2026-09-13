import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/tournament_providers.dart';
import '../widgets/tournament_header_bar.dart';

class TournamentHistoryScreen extends ConsumerWidget {
  const TournamentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(tournamentHistoryProvider);
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/tournament/tournament_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                TournamentHeaderBar(
                  title: 'TOURNAMENT HISTORY',
                  showHistoryButton: false,
                  onBack: () => Navigator.pop(context),
                  onClose: () => Navigator.pop(context),
                ),

                // History List / Empty State
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/tournament/trophy_gold_classic.png',
                                width: 80,
                                height: 80,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Tournament History Yet',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Join a tournament and fight your way to Round 6!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final isChampion = item.isChampion;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isChampion
                                      ? [const Color(0xFF382300), const Color(0xFF1E1300)]
                                      : [const Color(0xFF241544), const Color(0xFF120B24)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isChampion
                                      ? const Color(0xFFFFD54A)
                                      : const Color(0xFF654A98).withValues(alpha: 0.5),
                                  width: isChampion ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icon Badge
                                  Container(
                                    width: 48,
                                    height: 48,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.3),
                                      border: Border.all(
                                        color: isChampion
                                            ? const Color(0xFFFFD54A)
                                            : Colors.white24,
                                        width: 1,
                                      ),
                                    ),
                                    child: Image.asset(
                                      isChampion
                                          ? 'assets/images/tournament/crown_icon.png'
                                          : 'assets/images/tournament/defeat_icon.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.tournamentTitle,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isChampion
                                                    ? const Color(0xFFFFD54A)
                                                    : const Color(0xFFE53935),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isChampion ? 'CHAMPION' : 'ELIMINATED',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: isChampion ? Colors.black : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          'Reached Round ${item.roundReached} of 6',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.75),
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Reward
                                            Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/tournament/coin_icon.png',
                                                  width: 14,
                                                  height: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '+${formatter.format(item.rewardGold)} Gold',
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFFFFD54A),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Date
                                            Text(
                                              dateFormatter.format(item.completedAt),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 9,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
