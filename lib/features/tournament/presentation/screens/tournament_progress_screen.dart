import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';
import '../../application/tournament_providers.dart';
import '../../domain/tournament_card_model.dart';
import '../../domain/tournament_mode.dart';
import '../../domain/tournament_round_info.dart';
import '../../domain/tournament_run_state.dart';
import '../widgets/ladder_path_painter.dart';
import '../widgets/ladder_platform_widget.dart';
import '../widgets/tournament_header_bar.dart';

class TournamentProgressScreen extends ConsumerStatefulWidget {
  final TournamentMode mode;
  final TournamentCardModel? tournament;

  const TournamentProgressScreen({
    super.key,
    this.mode = TournamentMode.classic,
    this.tournament,
  });

  @override
  ConsumerState<TournamentProgressScreen> createState() =>
      _TournamentProgressScreenState();
}

class _TournamentProgressScreenState
    extends ConsumerState<TournamentProgressScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Scroll smoothly towards the active round
        final activeRun = ref.read(tournamentRunControllerProvider);
        final round = activeRun?.currentRound ?? 1;
        // Invert scroll since round 1 is at the bottom
        final targetOffset = (6 - round) * 110.0;
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeRun = ref.watch(tournamentRunControllerProvider);
    final repo = ref.watch(tournamentRepositoryProvider);
    final currentRound = activeRun?.currentRound ?? 1;
    final formatter = NumberFormat('#,###');

    // Check if user level meets unlock level (default 1 unlocks, 3 or 5 for higher tiers)
    const userLevel = 5; // Default player level
    final unlockLevel = widget.tournament?.unlockLevel ?? 1;
    final isLockedByLevel = userLevel < unlockLevel;

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

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                TournamentHeaderBar(
                  title: '${widget.mode.displayName.toUpperCase()} LADDER',
                  onBack: () => context.go(AppConstants.tournamentLobbyRoute),
                  onClose: () => context.go(AppConstants.tournamentLobbyRoute),
                ),

                // Top Balance & Congratulations Pill
                _buildTopInfoBar(formatter),

                // Main Zig-Zag Ladder Path
                Expanded(
                  child: FutureBuilder<List<TournamentRoundInfo>>(
                    future: repo.getLadderRounds(
                      mode: widget.mode,
                      currentRound: currentRound,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Color(0xFFFFD54A)),
                          ),
                        );
                      }

                      final rounds = snapshot.data!;
                      return _buildLadderContent(context, rounds, currentRound);
                    },
                  ),
                ),

                // Bottom Action Panel
                _buildBottomActionPanel(context, activeRun, currentRound),
              ],
            ),
          ),

          // Frosted Glass Unlock Level Overlay (if level locked)
          if (isLockedByLevel) _buildLockedOverlay(unlockLevel),
        ],
      ),
    );
  }

  Widget _buildTopInfoBar(NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E103E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9070D4).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Golds Balance
          Row(
            children: [
              Image.asset(
                'assets/images/tournament/coin_icon.png',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 6),
              const Text(
                'Current Golds: ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const Text(
                '50,000',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFD54A),
                ),
              ),
            ],
          ),

          // Mode Indicator Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: widget.mode.accentColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.mode.accentColor, width: 1),
            ),
            child: Text(
              widget.mode.displayName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: widget.mode.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLadderContent(
    BuildContext context,
    List<TournamentRoundInfo> rounds,
    int currentRound,
  ) {
    // Screen width for positioning zig-zag nodes
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;

    // Platform X positions zig-zagging left and right
    // Index 0 (Round 1) to Index 5 (Round 6)
    // Ladder layout from bottom to top: Round 6 at Y=60, Round 1 at Y=750
    const double stepY = 130.0;
    const double totalHeight = stepY * 6 + 100;

    // Define positions for rounds 1 (bottom) to 6 (top)
    final List<Offset> platformCenters = [
      Offset(centerX - 60, totalHeight - 110), // Round 1
      Offset(centerX + 65, totalHeight - 110 - stepY), // Round 2
      Offset(centerX - 70, totalHeight - 110 - stepY * 2), // Round 3
      Offset(centerX + 65, totalHeight - 110 - stepY * 3), // Round 4
      Offset(centerX - 60, totalHeight - 110 - stepY * 4), // Round 5
      Offset(centerX, totalHeight - 110 - stepY * 5), // Round 6 (Center Grand Final)
    ];

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: screenWidth,
        height: totalHeight,
        child: Stack(
          children: [
            // Connecting Dashed Zig-Zag Path
            Positioned.fill(
              child: CustomPaint(
                painter: LadderPathPainter(
                  points: platformCenters,
                  lineColor: widget.mode.accentColor,
                  glowColor: widget.mode.accentColor.withValues(alpha: 0.4),
                ),
              ),
            ),

            // Platforms (Round 1 to 6)
            for (int i = 0; i < rounds.length; i++) ...[
              _buildPositionedPlatform(
                round: rounds[i],
                center: platformCenters[i],
                isCurrent: rounds[i].roundNumber == currentRound,
                animationDelayIndex: i,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedPlatform({
    required TournamentRoundInfo round,
    required Offset center,
    required bool isCurrent,
    required int animationDelayIndex,
  }) {
    // Width and height of platform container
    final pWidth = round.isFinal ? 200.0 : 160.0;
    final pHeight = round.isFinal ? 170.0 : 140.0;

    return Positioned(
      left: center.dx - (pWidth / 2),
      top: center.dy - (pHeight / 2),
      width: pWidth,
      child: LadderPlatformWidget(
        roundInfo: round,
        isCurrentRound: isCurrent,
        onTap: () {
          SoundService().playButtonClick();
        },
      )
          .animate()
          .fadeIn(
            duration: 400.ms,
            delay: (animationDelayIndex * 90).ms,
            curve: Curves.easeOut,
          )
          .slideY(
            begin: 0.25,
            end: 0,
            duration: 400.ms,
            delay: (animationDelayIndex * 90).ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _buildBottomActionPanel(
    BuildContext context,
    TournamentRunState? activeRun,
    int currentRound,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14082B).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF5A3C9A).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Round indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ACTIVE STAGE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                ),
              ),
              Text(
                currentRound >= 6 ? 'FINAL ROUND 6' : 'ROUND $currentRound OF 6',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD54A),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Primary PLAY CTA Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  SoundService().playButtonClick();
                  context.push(
                    AppConstants.tournamentMatchmakingRoute,
                    extra: {
                      'mode': widget.mode.name,
                      'round': currentRound,
                    },
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                        color: const Color(0xFFFFA000).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentRound >= 6 ? 'PLAY FINAL ROUND 🏆' : 'PLAY ROUND $currentRound',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A2800),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay(int unlockLevel) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withValues(alpha: 0.65),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1B5B), Color(0xFF160B33)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF865ED6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/tournament/lock_icon.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LOCKED TOURNAMENT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlocks at Level $unlockLevel. Play games to level up and unlock this tournament!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54A),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: const Text(
                        'BACK TO LOBBY',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
