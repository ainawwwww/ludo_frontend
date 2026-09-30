import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

final tournamentWinnersProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  try {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get(ApiEndpoints.tournamentWinners);
    if (response != null && response['status'] == 'success') {
      final List data = response['data'] as List;
      final formatter = NumberFormat('#,###');

      final announcements = data.map<String>((item) {
        final Map<String, dynamic> m = item as Map<String, dynamic>;
        final username = m['username']?.toString() ?? 'Player';
        final prize = (m['prize_gold'] as num?)?.toInt() ?? 0;
        final title = m['tournament_title']?.toString() ?? 'Tournament';
        return 'Bravo! $username claimed ${formatter.format(prize)} golds in $title!';
      }).toList();

      if (announcements.isNotEmpty) return announcements;
    }
  } catch (_) {}

  return [];
});

class TournamentWinnerTicker extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;

  const TournamentWinnerTicker({
    super.key,
    this.onDismiss,
  });

  @override
  ConsumerState<TournamentWinnerTicker> createState() =>
      _TournamentWinnerTickerState();
}

class _TournamentWinnerTickerState
    extends ConsumerState<TournamentWinnerTicker> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = _currentIndex + 1;
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

    final winnersAsync = ref.watch(tournamentWinnersProvider);

    return winnersAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) return const SizedBox.shrink();
        final index = _currentIndex % announcements.length;
        final text = announcements[index];

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
                    text,
                    key: ValueKey<int>(index),
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
