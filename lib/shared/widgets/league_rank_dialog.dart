import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/utils/image_utils.dart';
import 'package:ludo_vibe/features/profile/models/league_model.dart';
import 'package:ludo_vibe/features/profile/providers/league_provider.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';
import 'package:ludo_vibe/features/social/providers/social_provider.dart';

class LeagueRankDialog extends ConsumerStatefulWidget {
  final int initialTab; // 0: League, 1: Rank
  final String leagueRank;
  final String playerRank;

  const LeagueRankDialog({
    super.key,
    this.initialTab = 0,
    this.leagueRank = 'No. 0',
    this.playerRank = 'No. 0',
  });

  @override
  ConsumerState<LeagueRankDialog> createState() => _LeagueRankDialogState();
}

class _LeagueRankDialogState extends ConsumerState<LeagueRankDialog> {
  late int _selectedTab;
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int initialSeconds) {
    _timer?.cancel();
    _secondsRemaining = initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  String _formatSeconds(int seconds) {
    if (seconds <= 0) return 'Season ending...';
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (d > 0) {
      return '$d days $h hrs';
    }
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final divisionAsync = ref.watch(leagueDivisionProvider);
    final globalLeaderboardAsync = ref.watch(leaderboardProvider('global'));

    return PurplePopupDialog(
      title: _selectedTab == 0 ? 'League Status' : 'Global Leaderboard',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: [
            // Tabs: League | Rank
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFFFF8F00) : const Color(0xFFEADBFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.leagueRank.isEmpty || widget.leagueRank == 'No. 0'
                            ? 'League'
                            : (widget.leagueRank == 'Locked'
                                ? 'League (Locked)'
                                : 'League (${widget.leagueRank})'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 0 ? Colors.white : const Color(0xFF260D5C),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFFFF8F00) : const Color(0xFFEADBFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Rank (${widget.playerRank})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 1 ? Colors.white : const Color(0xFF260D5C),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // TAB 0: Real Weekly Division Standings
            if (_selectedTab == 0) ...[
              divisionAsync.when(
                data: (data) {
                  if (_timer == null || _secondsRemaining <= 0) {
                    _startTimer(data.season.secondsRemaining);
                  }

                  if (data.userSummary.isLocked) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_clock_rounded, color: Color(0xFFFFD54F), size: 48),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFD54F), width: 1),
                            ),
                            child: Text(
                              'Unlocks at Level ${data.userSummary.unlockLevel}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD54F),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Play games, earn XP, and reach Level 4 to unlock the weekly Division League and compete for top tier rankings!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Current League Banner Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.workspace_premium, color: Color(0xFFFFD54F), size: 48),
                            const SizedBox(height: 6),
                            Text(
                              'Tier: ${data.userSummary.tierName} (Division #${data.userSummary.divisionNumber})',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Season ends in: ${_formatSeconds(_secondsRemaining)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xD9FFFFFF)),
                            ),
                            if (data.userSummary.pointsNeededForNextTier > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${data.userSummary.pointsNeededForNextTier} pts needed for next tier',
                                style: const TextStyle(fontSize: 10, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Division Members List
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADBFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: data.divisionMembers.length,
                          separatorBuilder: (context, index) => const Divider(color: Color(0xFFC7B3FF), height: 1),
                          itemBuilder: (context, index) {
                            final item = data.divisionMembers[index];
                            final isTop5 = item.rank <= 5;

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: item.isMe ? const Color(0xFFD6C7FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: item.isMe ? Border.all(color: const Color(0xFFFF8F00), width: 1.5) : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    child: Row(
                                      children: [
                                        if (isTop5)
                                          const Icon(
                                            Icons.emoji_events_rounded,
                                            size: 13,
                                            color: Color(0xFFFF8F00),
                                          ),
                                        Text(
                                          '#${item.rank}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isTop5
                                                ? const Color(0xFFE65100)
                                                : const Color(0xFF260D5C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildAvatar(item),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.username,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: item.isMe ? FontWeight.bold : FontWeight.w500,
                                        color: const Color(0xFF260D5C),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.pointsInDivision} pts',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8F00),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 260,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                error: (err, stack) => SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      'Failed to load division standings',
                      style: TextStyle(color: Colors.red.shade100, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],

            // TAB 1: Global Rank Leaderboard
            if (_selectedTab == 1) ...[
              globalLeaderboardAsync.when(
                data: (leaderboard) {
                  return Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEADBFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: leaderboard.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFFC7B3FF), height: 1),
                      itemBuilder: (context, index) {
                        final item = leaderboard[index];

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '#${item.rank}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8F00),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.username,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF260D5C),
                                  ),
                                ),
                              ),
                              Text(
                                '${item.totalWins} Wins',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8F00),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                error: (err, stack) => const SizedBox(
                  height: 280,
                  child: Center(
                    child: Text('Failed to load global leaderboard', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(LeagueDivisionMemberModel item) {
    final url = formatAvatarUrl(item.avatarUrl);
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF7C53F6),
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 16),
              )
            : const Icon(Icons.person, color: Colors.white, size: 16),
      ),
    );
  }
}
