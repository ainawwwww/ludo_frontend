import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../widgets/room_widgets.dart';
import '../../../shared/widgets/app_close_button.dart';

class TeamVsScreen extends ConsumerStatefulWidget {
  const TeamVsScreen({super.key, this.entryFee});
  final int? entryFee;

  @override
  ConsumerState<TeamVsScreen> createState() => _TeamVsScreenState();
}

class _TeamVsScreenState extends ConsumerState<TeamVsScreen>
    with SingleTickerProviderStateMixin {
  int _matchPhase = 0; // 0: Searching, 1: Teammate found, 2: Rival 1 found, 3: Rival 2 found, 4: Ready!
  Timer? _timer1;
  Timer? _timer2;
  Timer? _timer3;
  Timer? _timer4;
  Timer? _timerNav;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _startMatchmakingSequence();
  }

  void _startMatchmakingSequence() {
    // 1.2s: Teammate joins
    _timer1 = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _matchPhase = 1);
    });

    // 2.0s: Rival 1 joins
    _timer2 = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _matchPhase = 2);
    });

    // 2.8s: Rival 2 joins (All found!)
    _timer3 = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _matchPhase = 3);
    });

    // 3.4s: Match ready banner
    _timer4 = Timer(const Duration(milliseconds: 3400), () {
      if (mounted) setState(() => _matchPhase = 4);
    });

    // 4.3s: Direct navigation to Ludo Board game
    _timerNav = Timer(const Duration(milliseconds: 4300), () {
      if (!mounted) return;
      final session = ref.read(roomFlowProvider).session;
      final effectiveFee = widget.entryFee ?? session?.settings.entryFee ?? 500;
      context.pushReplacement(
        AppConstants.ludoBoardRoute,
        extra: LudoBoardArgs(
          players: 4,
          bet: effectiveFee,
          isOnline: false,
          roomMode: RoomMode.quickMatch,
          roomId: session?.id,
          gameId: session?.id,
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer1?.cancel();
    _timer2?.cancel();
    _timer3?.cancel();
    _timer4?.cancel();
    _timerNav?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(roomFlowProvider).session;
    final entry = widget.entryFee ?? session?.settings.entryFee ?? 500;
    final reward = entry * 2 - (entry ~/ 10);
    final authUser = ref.watch(authProvider).user;
    final myName = (authUser?.username.isNotEmpty == true) ? authUser!.username : 'Wania Shahid';
    final myAvatar = authUser?.avatarUrl;

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.team,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final scale = (constraints.maxWidth / AppConstants.designWidth)
                .clamp(.80, 1.25);
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                  child: Column(
                    children: [
                      // Top spacing for header
                      SizedBox(height: 8 * scale),

                      // Top VS Badge Illustration
                      Image.asset(
                        'assets/graphics/rooms/generated/vs_badge.png',
                        width: 180 * scale,
                        height: 135 * scale,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 6 * scale),

                      // Rank 1 & Coin Podium Plaque
                      Container(
                        height: 78 * scale,
                        margin: EdgeInsets.symmetric(horizontal: 10 * scale),
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0A3D73),
                              Color(0xFF1E88C8),
                              Color(0xFF0A3D73),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0288D1).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/graphics/rooms/generated/coin_podium.png',
                              width: 105 * scale,
                              height: 68 * scale,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8 * scale),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'RANK 1   ',
                                    style: TextStyle(
                                      color: const Color(0xFFFFCC00),
                                      fontSize: 22 * scale,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      shadows: const [
                                        Shadow(color: Colors.black54, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$reward',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24 * scale,
                                      fontWeight: FontWeight.w900,
                                      shadows: const [
                                        Shadow(color: Colors.black87, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * scale),

                      // Entry Coins Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Entry Coins   ',
                            style: TextStyle(
                              color: const Color(0xFFFFD438),
                              fontSize: 19 * scale,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                          Text(
                            '$entry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14 * scale),

                      // Silver Rod & Dual Hanging Banners (Red on Left, Blue on Right)
                      _SilverRodBannersSection(
                        scale: scale,
                        pulseController: _pulseController,
                        matchPhase: _matchPhase,
                        myName: myName,
                        myAvatar: myAvatar,
                      ),

                      SizedBox(height: 12 * scale),

                      // Match status indicator badge
                      _buildMatchStatusBadge(scale),
                    ],
                  ),
                ),

                // Top Close Button
                Positioned(
                  top: 8 * scale,
                  right: 12 * scale,
                  child: AppCloseButton(
                    size: 32 * scale,
                    onTap: () => context.pop(),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMatchStatusBadge(double scale) {
    String text;
    Color glowColor;
    if (_matchPhase < 3) {
      text = 'Searching players... (${_matchPhase + 1}/4)';
      glowColor = const Color(0xFF00FFCC);
    } else if (_matchPhase == 3) {
      text = 'All players joined! Preparing match...';
      glowColor = const Color(0xFFFFD700);
    } else {
      text = 'MATCH READY! STARTING GAME...';
      glowColor = const Color(0xFF00FF66);
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 8 * scale),
          decoration: BoxDecoration(
            color: const Color(0xCC0B1B38),
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: glowColor.withOpacity(0.6 + 0.4 * _pulseController.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.25 * _pulseController.value),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_matchPhase < 4) ...[
                SizedBox(
                  width: 14 * scale,
                  height: 14 * scale,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                  ),
                ),
                SizedBox(width: 8 * scale),
              ] else ...[
                Icon(Icons.check_circle_rounded, color: glowColor, size: 16 * scale),
                SizedBox(width: 6 * scale),
              ],
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5 * scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SilverRodBannersSection extends StatelessWidget {
  const _SilverRodBannersSection({
    required this.scale,
    required this.pulseController,
    required this.matchPhase,
    required this.myName,
    this.myAvatar,
  });

  final double scale;
  final AnimationController pulseController;
  final int matchPhase;
  final String myName;
  final String? myAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Metallic Silver Hanging Rod with Spheres
        SizedBox(
          width: 320 * scale,
          height: 18 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Silver Bar
              Container(
                width: 300 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E9EAB),
                      Color(0xFFFFFFFF),
                      Color(0xFF8E9EAB),
                      Color(0xFF637381),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Left Sphere Finial
              Positioned(
                left: 0,
                child: _buildSphereFinial(scale),
              ),
              // Right Sphere Finial
              Positioned(
                right: 0,
                child: _buildSphereFinial(scale),
              ),
            ],
          ),
        ),

        // Two Banners Hanging Side by Side
        SizedBox(
          height: 385 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red Team Flag (Left - Player Team)
              Expanded(
                child: _TeamBanner(
                  scale: scale,
                  bannerAsset: 'assets/graphics/rooms/generated/red_team_banner.png',
                  player1: _BannerPlayerData(
                    name: myName,
                    avatarUrl: myAvatar,
                    fallbackAsset: 'assets/graphics/profile/avatars/avatar_royal_queen.png',
                    isReady: true,
                  ),
                  player2: _BannerPlayerData(
                    name: 'الخزعلي 🇾🇪 🇾🇪',
                    avatarUrl: null,
                    fallbackAsset: 'assets/graphics/wealthy_avatar.png',
                    isReady: matchPhase >= 1,
                  ),
                  pulseController: pulseController,
                ),
              ),
              SizedBox(width: 8 * scale),
              // Blue Team Flag (Right - Rival Team)
              Expanded(
                child: _TeamBanner(
                  scale: scale,
                  bannerAsset: 'assets/graphics/rooms/generated/blue_team_banner.png',
                  player1: _BannerPlayerData(
                    name: 'Milina ❤️🫀🇩🇿',
                    avatarUrl: null,
                    fallbackAsset: 'assets/graphics/musician_avatar.png',
                    isReady: matchPhase >= 2,
                  ),
                  player2: _BannerPlayerData(
                    name: 'Guest_565023...',
                    avatarUrl: null,
                    fallbackAsset: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
                    isReady: matchPhase >= 3,
                  ),
                  pulseController: pulseController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSphereFinial(double scale) {
    return Container(
      width: 16 * scale,
      height: 16 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFD5D8DC),
            Color(0xFF7F8C8D),
            Color(0xFF34495E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _BannerPlayerData {
  const _BannerPlayerData({
    required this.name,
    required this.isReady,
    this.avatarUrl,
    this.fallbackAsset,
  });

  final String name;
  final bool isReady;
  final String? avatarUrl;
  final String? fallbackAsset;
}

class _TeamBanner extends StatelessWidget {
  const _TeamBanner({
    required this.scale,
    required this.bannerAsset,
    required this.player1,
    required this.player2,
    required this.pulseController,
  });

  final double scale;
  final String bannerAsset;
  final _BannerPlayerData player1;
  final _BannerPlayerData player2;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Flag Graphic with swallowtail cut
        Image.asset(bannerAsset, fit: BoxFit.fill),

        // Two Player Slots inside Banner
        Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 65 * scale, 16 * scale, 55 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PlayerSlot(
                scale: scale,
                player: player1,
                pulseController: pulseController,
              ),
              _PlayerSlot(
                scale: scale,
                player: player2,
                pulseController: pulseController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  const _PlayerSlot({
    required this.scale,
    required this.player,
    required this.pulseController,
  });

  final double scale;
  final _BannerPlayerData player;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 64.0 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Player Name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            player.isReady ? player.name : 'Searching...',
            key: ValueKey(player.isReady),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: player.isReady ? Colors.white : Colors.white60,
              fontSize: 13.5 * scale,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
        SizedBox(height: 6 * scale),

        // Circular Avatar with Glowing Neon Green Ring
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: player.isReady
              ? Container(
                  key: const ValueKey('ready'),
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FF88),
                      width: 3.5 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF88).withOpacity(0.55),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildAvatarImage(player),
                  ),
                )
              : AnimatedBuilder(
                  key: const ValueKey('waiting'),
                  animation: pulseController,
                  builder: (context, child) {
                    final pulse = pulseController.value;
                    return Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x33000000),
                        border: Border.all(
                          color: const Color(0xFF00FF88).withOpacity(0.3 + 0.5 * pulse),
                          width: (2.5 + 1.0 * pulse) * scale,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF88).withOpacity(0.2 * pulse),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.4 + 0.3 * pulse),
                        size: 34 * scale,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static Widget _buildAvatarImage(_BannerPlayerData player) {
    if (player.avatarUrl != null && player.avatarUrl!.isNotEmpty) {
      if (player.avatarUrl!.startsWith('http')) {
        return Image.network(
          player.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImage(player.fallbackAsset),
        );
      } else {
        return Image.asset(
          player.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImage(player.fallbackAsset),
        );
      }
    }
    return _fallbackImage(player.fallbackAsset);
  }

  static Widget _fallbackImage(String? asset) {
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF1E293B),
          child: const Icon(Icons.person, color: Colors.white70),
        ),
      );
    }
    return Container(
      color: const Color(0xFF1E293B),
      child: const Icon(Icons.person, color: Colors.white70),
    );
  }
}

