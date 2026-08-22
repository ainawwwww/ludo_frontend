import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/shared/widgets/league_rank_dialog.dart';

class LeagueBanner extends StatelessWidget {
  const LeagueBanner({
    super.key,
    this.leagueRank = 'No. 0',
    this.playerRank = 'No. 0',
  });

  final String leagueRank;
  final String playerRank;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        children: [
          // LEFT Card: League
          Expanded(
            child: _BannerCard(
              scale: scale,
              iconPath: 'assets/graphics/icon_league.png',
              title: 'League',
              subtitle: leagueRank,
              leftPadding: 8 * scale,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => LeagueRankDialog(
                    initialTab: 0,
                    leagueRank: leagueRank,
                    playerRank: playerRank,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10 * scale),
          // RIGHT Card: Rank
          Expanded(
            child: _BannerCard(
              scale: scale,
              iconPath: 'assets/graphics/icon_rank.png',
              title: 'Rank',
              subtitle: playerRank,
              leftPadding: 12 * scale,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => LeagueRankDialog(
                    initialTab: 1,
                    leagueRank: leagueRank,
                    playerRank: playerRank,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.scale,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.leftPadding,
    required this.onTap,
  });

  final double scale;
  final String iconPath;
  final String title;
  final String subtitle;
  final double leftPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF2D1FA3),
          borderRadius: BorderRadius.circular(14 * scale),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 12 * scale),
            Image.asset(
              iconPath,
              width: 52 * scale,
              height: 52 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 1 * scale),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
