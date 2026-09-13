import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';
import '../../domain/tournament_card_model.dart';
import '../widgets/tournament_card_widget.dart';
import '../widgets/tournament_header_bar.dart';
import '../widgets/tournament_winner_ticker.dart';
import 'tournament_entry_sheet.dart';

class TournamentLobbyScreen extends ConsumerWidget {
  const TournamentLobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyAsync = ref.watch(tournamentLobbyProvider);
    final activeRun = ref.watch(tournamentRunControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Night-sky Tournament Arena Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/tournament/tournament_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF160A38), Color(0xFF070416)],
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Ornamental Header
                TournamentHeaderBar(
                  title: 'TOURNAMENT',
                  onBack: () => context.go(AppConstants.homeRoute),
                  onClose: () => context.go(AppConstants.homeRoute),
                ),

                // Congratulations Winner Ticker Bar
                const TournamentWinnerTicker(),

                const SizedBox(height: 6),

                // Active Run Resume Banner (if any)
                if (activeRun != null && !activeRun.isChampion && !activeRun.isEliminated) ...[
                  _buildResumeBanner(context, activeRun),
                  const SizedBox(height: 6),
                ],

                // Tournament Cards List
                Expanded(
                  child: lobbyAsync.when(
                    data: (cards) => ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return TournamentCardWidget(
                          tournament: card,
                          onTap: () => _handleCardTap(context, ref, card, activeRun),
                        );
                      },
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54A)),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        'Failed to load tournaments',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
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

  Widget _buildResumeBanner(BuildContext context, dynamic activeRun) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00796B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match In Progress',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${activeRun.title} — Round ${activeRun.currentRound}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54A),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              SoundService().playButtonClick();
              context.push(
                AppConstants.tournamentProgressRoute,
                extra: {'mode': activeRun.mode.name},
              );
            },
            child: const Text(
              'RESUME',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCardTap(
    BuildContext context,
    WidgetRef ref,
    TournamentCardModel card,
    dynamic activeRun,
  ) {
    if (activeRun != null && activeRun.tournamentId == card.id) {
      // Resume existing run
      context.push(
        AppConstants.tournamentProgressRoute,
        extra: {'mode': card.mode.name, 'tournament': card},
      );
    } else {
      // Open entry sheet
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => TournamentEntrySheet(tournament: card),
      );
    }
  }
}
