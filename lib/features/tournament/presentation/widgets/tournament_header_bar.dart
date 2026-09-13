import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/sound_service.dart';

class TournamentHeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final VoidCallback? onHistory;
  final bool showHistoryButton;

  const TournamentHeaderBar({
    super.key,
    this.title = 'TOURNAMENT',
    this.onBack,
    this.onClose,
    this.onHistory,
    this.showHistoryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            _buildCircularIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                SoundService().playButtonClick();
                if (onBack != null) {
                  onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go(AppConstants.homeRoute);
                }
              },
            ),

            // Center Ornamental Banner with Real Styled Title Text
            Expanded(
              child: SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ornamental Crossed-Flag Banner Graphic
                    Image.asset(
                      'assets/images/tournament/tournament_header_banner.png',
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    // Real text overlaid in banner center
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          color: Color(0xFFFFE875),
                          shadows: [
                            Shadow(
                              color: Color(0xFF590E17),
                              offset: Offset(0, 2),
                              blurRadius: 3,
                            ),
                            Shadow(
                              color: Color(0xFF000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Action Buttons: History & Close
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHistoryButton)
                  _buildCircularIconButton(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFFFD54A),
                    onTap: () {
                      SoundService().playButtonClick();
                      if (onHistory != null) {
                        onHistory!();
                      } else {
                        context.push(AppConstants.tournamentHistoryRoute);
                      }
                    },
                  ),
                const SizedBox(width: 8),
                _buildCircularIconButton(
                  icon: Icons.close_rounded,
                  onTap: () {
                    SoundService().playButtonClick();
                    if (onClose != null) {
                      onClose!();
                    } else {
                      context.go(AppConstants.homeRoute);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF382375),
              Color(0xFF1E1345),
            ],
          ),
          border: Border.all(color: const Color(0xFF7A5EC7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
