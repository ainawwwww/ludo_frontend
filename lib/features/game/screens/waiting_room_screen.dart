import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({
    super.key,
    this.betAmount = 500,
    this.playerCount = 4,
  });

  final int betAmount;
  final int playerCount;

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool _isMicMuted = false;
  bool _isSpeakerMuted = false;
  bool _isReady = false;
  int _countdownSeconds = 5;
  Timer? _timer;

  final List<_WaitingPlayer> _players = [
    const _WaitingPlayer(
      id: 'p1',
      name: 'Ali (You)',
      avatarUrl: 'assets/graphics/musician_avatar.png',
      isReady: true,
      isHost: true,
      pingMs: 24,
    ),
    const _WaitingPlayer(
      id: 'p2',
      name: 'Sara_Ludo',
      avatarUrl: 'assets/graphics/wealthy_avatar.png',
      isReady: true,
      isHost: false,
      pingMs: 45,
    ),
    const _WaitingPlayer(
      id: 'p3',
      name: 'ProGamer99',
      avatarUrl: 'assets/graphics/musician_avatar.png',
      isReady: false,
      isHost: false,
      pingMs: 62,
    ),
    const _WaitingPlayer(
      id: 'p4',
      name: 'Searching...',
      avatarUrl: '',
      isReady: false,
      isHost: false,
      pingMs: 0,
      isEmptySlot: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        _timer?.cancel();
        // Start game
        if (mounted) {
          context.go(
            AppConstants.ludoBoardRoute,
            extra: {
              'players': widget.playerCount,
              'bet': widget.betAmount,
            },
          );
        }
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
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white, size: 24 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'PRE-GAME LOBBY',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),

              // Bet info capsule
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C073E).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(color: const Color(0xFFFFD369), width: 1.5 * scale),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/graphics/icon_coins.png', width: 22 * scale, height: 22 * scale),
                    SizedBox(width: 6 * scale),
                    Text(
                      'BET AMOUNT: ${widget.betAmount} COINS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD369),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * scale),

              // Countdown text
              Text(
                'MATCH STARTING IN',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  letterSpacing: 1.2,
                  color: Colors.white60,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                '00:0$_countdownSeconds',
                style: AppTextStyles.headingLarge.copyWith(
                  fontSize: 36 * scale,
                  color: const Color(0xFFFF9B63),
                  fontWeight: FontWeight.w900,
                  shadows: const [
                    Shadow(color: Color(0xFFF97023), blurRadius: 16),
                  ],
                ),
              ),
              SizedBox(height: 28 * scale),

              // 4 Player Slots Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16 * scale,
                      mainAxisSpacing: 16 * scale,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      return _buildPlayerSlot(player, scale);
                    },
                  ),
                ),
              ),

              // Audio Controls & Mic Check Overlay
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1352).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16 * scale),
                  border: Border.all(color: AppColors.primaryBorder.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Mic toggle
                    IconButton(
                      icon: Icon(
                        _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMicMuted ? Colors.white38 : const Color(0xFF56AB2F),
                        size: 26 * scale,
                      ),
                      onPressed: () => setState(() => _isMicMuted = !_isMicMuted),
                    ),
                    // Speaker toggle
                    IconButton(
                      icon: Icon(
                        _isSpeakerMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: _isSpeakerMuted ? Colors.white38 : const Color(0xFF00E5FF),
                        size: 26 * scale,
                      ),
                      onPressed: () => setState(() => _isSpeakerMuted = !_isSpeakerMuted),
                    ),
                    // Signal status
                    Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: const Color(0xFF56AB2F), size: 18 * scale),
                        SizedBox(width: 4 * scale),
                        Text(
                          '24ms',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11 * scale,
                            color: const Color(0xFF56AB2F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ready CTA Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * scale, vertical: 16 * scale),
                child: OrangeButton(
                  text: _isReady ? 'START GAME NOW' : 'READY',
                  onPressed: () {
                    setState(() => _isReady = true);
                    context.go(
                      AppConstants.ludoBoardRoute,
                      extra: {
                        'players': widget.playerCount,
                        'bet': widget.betAmount,
                      },
                    );
                  },
                  width: double.infinity,
                  height: 50 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(_WaitingPlayer player, double scale) {
    if (player.isEmptySlot) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: Colors.white24, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: CircularProgressIndicator(
                strokeWidth: 2.5 * scale,
                color: const Color(0xFFFF9B63),
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              'Searching...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.listItemGradient,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: player.isReady ? const Color(0xFF56AB2F) : AppColors.primaryBorder,
          width: 2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: player.isReady ? const Color(0xFF56AB2F).withOpacity(0.3) : Colors.black26,
            blurRadius: 8 * scale,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 54 * scale,
            height: 54 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD369), width: 2 * scale),
            ),
            child: ClipOval(
              child: Image.asset(
                player.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),

          // Name & Host Badge
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * scale),

          // Ready Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
            decoration: BoxDecoration(
              color: player.isReady ? const Color(0xFF56AB2F) : Colors.white24,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Text(
              player.isReady ? 'READY' : 'WAITING',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingPlayer {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isReady;
  final bool isHost;
  final int pingMs;
  final bool isEmptySlot;

  const _WaitingPlayer({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isReady,
    required this.isHost,
    required this.pingMs,
    this.isEmptySlot = false,
  });
}
