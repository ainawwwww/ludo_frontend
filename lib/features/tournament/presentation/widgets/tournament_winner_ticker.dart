import 'dart:async';
import 'package:flutter/material.dart';

class TournamentWinnerTicker extends StatefulWidget {
  final VoidCallback? onDismiss;

  const TournamentWinnerTicker({
    super.key,
    this.onDismiss,
  });

  @override
  State<TournamentWinnerTicker> createState() => _TournamentWinnerTickerState();
}

class _TournamentWinnerTickerState extends State<TournamentWinnerTicker> {
  final List<String> _announcements = [
    'Congratulations! Sarah_VIP won 3,729,007 golds in Classic Tournament!',
    'Bravo! Prince_Ludo claimed 1,814,357 golds in Quick Tournament!',
    'Incredible! TigerKing99 took 3,729,007 golds in Final Round 6!',
  ];

  int _currentIndex = 0;
  Timer? _timer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _announcements.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF381552).withValues(alpha: 0.9),
            const Color(0xFF1D0E3B).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD54A).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54A).withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Small Coin Icon
          Image.asset(
            'assets/images/tournament/coin_icon.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),

          // Animated Switcher for announcements
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _announcements[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFE58F),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),
          // Dismiss Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isVisible = false;
              });
              widget.onDismiss?.call();
            },
            child: Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
