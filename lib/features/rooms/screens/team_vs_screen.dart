import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../models/room_models.dart';
import '../providers/team_room_provider.dart';
import '../widgets/room_widgets.dart';

class TeamVsScreen extends ConsumerStatefulWidget {
  const TeamVsScreen({super.key, this.entryFee, this.isSingle = false});
  final int? entryFee;
  final bool isSingle;

  @override
  ConsumerState<TeamVsScreen> createState() => _TeamVsScreenState();
}

class _TeamVsScreenState extends ConsumerState<TeamVsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _navTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Check if match data is already available on mount (e.g. instant match)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMatchData();
    });
  }

  void _checkMatchData() {
    final tState = ref.read(teamRoomProvider);
    if (tState.matchData != null && !_isNavigating) {
      _navigateToGame(tState.matchData!);
    }
  }

  void _navigateToGame(Map<String, dynamic> matchData) {
    if (_isNavigating || !mounted) return;
    setState(() => _isNavigating = true);

    final roomId = matchData['room_id'] is int
        ? matchData['room_id'] as int
        : int.tryParse(matchData['room_id']?.toString() ?? '');
    final gameId = matchData['game_id'] is int
        ? matchData['game_id'] as int
        : int.tryParse(matchData['game_id']?.toString() ?? '');
    final fee = widget.entryFee ??
        (matchData['entry_fee'] is int ? matchData['entry_fee'] as int : 500);

    _navTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      ref.read(teamRoomProvider.notifier).consumeNavEvent();
      context.pushReplacement(
        AppConstants.ludoBoardRoute,
        extra: LudoBoardArgs(
          players: 4,
          bet: fee,
          isOnline: true,
          roomMode: RoomMode.team,
          roomId: roomId,
          gameId: gameId,
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(teamRoomProvider);
    final authUser = ref.watch(authProvider).user;
    final myUserId = authUser?.id ?? 1;
    final myName = (authUser?.username.isNotEmpty == true) ? authUser!.username : 'Player 1';
    final myAvatar = authUser?.avatarUrl;

    // Listen for TeamMatchFound navigation events
    ref.listen<TeamRoomState>(teamRoomProvider, (prev, next) {
      if ((next.navEvent == TeamRoomNavEvent.goToGame || next.matchData != null) &&
          !_isNavigating) {
        if (next.matchData != null) {
          _navigateToGame(next.matchData!);
        }
      }
    });

    final isSingle = widget.isSingle || tState.isSingle;
    final room = tState.room;
    final matchData = tState.matchData;

    // Extract players from room snapshot or matchData
    String teammateName = 'Searching...';
    String? teammateAvatar;
    bool isTeammateFound = false;

    String rival1Name = 'Searching...';
    String? rival1Avatar;
    bool isRival1Found = false;

    String rival2Name = 'Searching...';
    String? rival2Avatar;
    bool isRival2Found = false;

    if (!isSingle && room != null && room.participants.length >= 2) {
      // CREATE / JOIN path: teammate is seat 2 (if host) or seat 1 (if guest)
      final teammatePlayer = room.participants.firstWhere(
        (p) => p.userId != myUserId,
        orElse: () => room.participants.last,
      );
      if (teammatePlayer.userId != myUserId) {
        teammateName = teammatePlayer.username;
        isTeammateFound = true;
      }
    }

    if (matchData != null) {
      final rawPlayers = matchData['players'];
      if (rawPlayers is List) {
        final playersList = rawPlayers.cast<Map<String, dynamic>>();
        // Find teammate and rivals from matchData
        final rivals = <Map<String, dynamic>>[];
        for (final p in playersList) {
          final pid = p['user_id'] is int
              ? p['user_id'] as int
              : int.tryParse(p['user_id']?.toString() ?? '');
          if (pid == myUserId) continue;

          final seat = p['seat_position'] is int
              ? p['seat_position'] as int
              : int.tryParse(p['seat_position']?.toString() ?? '0') ?? 0;

          // Seat 1 & 3 are Team 1; Seat 2 & 4 are Team 2.
          // Teammate is partner in same team.
          if ((seat == 3 && (p['color'] == 'yellow' || p['color'] == 'red')) ||
              (seat == 4 && (p['color'] == 'blue' || p['color'] == 'green'))) {
            teammateName = p['username']?.toString() ?? 'Teammate';
            teammateAvatar = p['avatar_url']?.toString();
            isTeammateFound = true;
          } else {
            rivals.add(p);
          }
        }

        if (rivals.isNotEmpty) {
          rival1Name = rivals[0]['username']?.toString() ?? 'Rival 1';
          rival1Avatar = rivals[0]['avatar_url']?.toString();
          isRival1Found = true;
        }
        if (rivals.length > 1) {
          rival2Name = rivals[1]['username']?.toString() ?? 'Rival 2';
          rival2Avatar = rivals[1]['avatar_url']?.toString();
          isRival2Found = true;
        }
      }
    }

    final entry = widget.entryFee ?? room?.entryFee ?? 500;
    final reward = entry * 2 - (entry ~/ 10);

    final isAllFound = _isNavigating || (isTeammateFound && isRival1Found && isRival2Found);

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
                      SizedBox(height: 8 * scale),
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

                      // Silver Rod & Dual Hanging Banners
                      _SilverRodBannersSection(
                        scale: scale,
                        pulseController: _pulseController,
                        isSingle: isSingle,
                        myName: myName,
                        myAvatar: myAvatar,
                        teammateName: teammateName,
                        teammateAvatar: teammateAvatar,
                        isTeammateFound: isTeammateFound,
                        rival1Name: rival1Name,
                        rival1Avatar: rival1Avatar,
                        isRival1Found: isRival1Found,
                        rival2Name: rival2Name,
                        rival2Avatar: rival2Avatar,
                        isRival2Found: isRival2Found,
                      ),

                      SizedBox(height: 12 * scale),

                      // Match status indicator badge
                      _buildMatchStatusBadge(scale, isSingle, isTeammateFound, isAllFound),
                    ],
                  ),
                ),

                // Top Close Button
                Positioned(
                  top: 8 * scale,
                  right: 12 * scale,
                  child: InkWell(
                    onTap: () async {
                      await ref.read(teamRoomProvider.notifier).leave();
                      if (context.mounted) context.pop();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22 * scale,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMatchStatusBadge(
    double scale,
    bool isSingle,
    bool isTeammateFound,
    bool isAllFound,
  ) {
    String text;
    Color glowColor;

    if (isAllFound) {
      text = 'MATCH READY! STARTING GAME...';
      glowColor = const Color(0xFF00FF66);
    } else if (isSingle && !isTeammateFound) {
      text = 'Searching for teammate...';
      glowColor = const Color(0xFF00FFCC);
    } else {
      text = 'Searching for rival team...';
      glowColor = const Color(0xFFFFD700);
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
              if (!isAllFound) ...[
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
    required this.isSingle,
    required this.myName,
    this.myAvatar,
    required this.teammateName,
    this.teammateAvatar,
    required this.isTeammateFound,
    required this.rival1Name,
    this.rival1Avatar,
    required this.isRival1Found,
    required this.rival2Name,
    this.rival2Avatar,
    required this.isRival2Found,
  });

  final double scale;
  final AnimationController pulseController;
  final bool isSingle;
  final String myName;
  final String? myAvatar;
  final String teammateName;
  final String? teammateAvatar;
  final bool isTeammateFound;
  final String rival1Name;
  final String? rival1Avatar;
  final bool isRival1Found;
  final String rival2Name;
  final String? rival2Avatar;
  final bool isRival2Found;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 320 * scale,
          height: 18 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              Positioned(left: 0, child: _buildSphereFinial(scale)),
              Positioned(right: 0, child: _buildSphereFinial(scale)),
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
                    name: teammateName,
                    avatarUrl: teammateAvatar,
                    fallbackAsset: 'assets/graphics/wealthy_avatar.png',
                    isReady: isTeammateFound,
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
                    name: rival1Name,
                    avatarUrl: rival1Avatar,
                    fallbackAsset: 'assets/graphics/musician_avatar.png',
                    isReady: isRival1Found,
                  ),
                  player2: _BannerPlayerData(
                    name: rival2Name,
                    avatarUrl: rival2Avatar,
                    fallbackAsset: 'assets/graphics/profile/avatars/avatar_cyber_tiger.png',
                    isReady: isRival2Found,
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
        Image.asset(bannerAsset, fit: BoxFit.fill),
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            player.isReady ? player.name : 'Searching...',
            key: ValueKey('${player.name}_${player.isReady}'),
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

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: player.isReady
              ? Container(
                  key: ValueKey('ready_${player.name}'),
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
