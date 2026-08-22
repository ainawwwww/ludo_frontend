import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/profile/widgets/profile_dialogs.dart';

class LeagueRankDialog extends StatefulWidget {
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
  State<LeagueRankDialog> createState() => _LeagueRankDialogState();
}

class _LeagueRankDialogState extends State<LeagueRankDialog> {
  late int _selectedTab;

  static const leaderboardData = [
    {'rank': 1, 'name': 'King_Ludo', 'score': '45,200 pts', 'avatar': Icons.workspace_premium, 'color': Color(0xFFFFD54F)},
    {'rank': 2, 'name': 'StarPlayer99', 'score': '38,900 pts', 'avatar': Icons.military_tech, 'color': Color(0xFFE0E0E0)},
    {'rank': 3, 'name': 'Master_Ali', 'score': '31,400 pts', 'avatar': Icons.emoji_events, 'color': Color(0xFFFF8F00)},
    {'rank': 4, 'name': 'Guest_37869213', 'score': '24,100 pts', 'avatar': Icons.person, 'color': Color(0xFF7C4DFF)},
    {'rank': 5, 'name': 'LudoPro_X', 'score': '19,800 pts', 'avatar': Icons.person_outline, 'color': Color(0xFFB388FF)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
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
                        'League (${widget.leagueRank})',
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

            // Content Area
            if (_selectedTab == 0) ...[
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
                      'League Status: ${widget.leagueRank}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Season ends in: 3 days 14 hrs',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Leaderboard list
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFEADBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: leaderboardData.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFC7B3FF), height: 1),
                itemBuilder: (context, index) {
                  final item = leaderboardData[index];
                  final isUser = item['rank'] == 4;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFD6C7FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '#${item['rank']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item['color'] as Color,
                            ),
                          ),
                        ),
                        Icon(item['avatar'] as IconData, color: item['color'] as Color, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                              color: const Color(0xFF260D5C),
                            ),
                          ),
                        ),
                        Text(
                          item['score'] as String,
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
        ),
      ),
    );
  }
}
