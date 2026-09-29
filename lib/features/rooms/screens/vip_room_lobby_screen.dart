// lib/features/rooms/screens/vip_room_lobby_screen.dart
//
// Real API-backed VIP Room Lobby Screen.
// Subscribes to vipRoomProvider (state machine + WebSocket room-lobby.{roomId}).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/game/models/ludo_board_args.dart';
import 'package:ludo_vibe/features/game/models/room_mode.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/providers/vip_room_provider.dart';
import 'package:ludo_vibe/features/rooms/widgets/room_widgets.dart';

class VipRoomLobbyScreen extends ConsumerStatefulWidget {
  const VipRoomLobbyScreen({super.key});

  @override
  ConsumerState<VipRoomLobbyScreen> createState() =>
      _VipRoomLobbyScreenState();
}

class _VipRoomLobbyScreenState extends ConsumerState<VipRoomLobbyScreen> {
  bool _isStartingCountdown = false;
  int? _countdown;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _onStart() async {
    final room = ref.read(vipRoomProvider).room;
    if (room == null || !room.canStart) return;
    await ref.read(vipRoomProvider.notifier).startMatch();
  }

  Future<void> _onToggleReady(bool currentlyReady) async {
    await ref
        .read(vipRoomProvider.notifier)
        .setReady(isReady: !currentlyReady);
  }

  Future<void> _onLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1250),
        title: const Text('Leave VIP room?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your seat will become available to another player.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('LEAVE',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(vipRoomProvider.notifier).leave();
    if (mounted) context.go(AppConstants.vipRoomRoute);
  }

  void _startCountdown(int gameId, PrivateRoomDto room, int myUserId) {
    if (_isStartingCountdown) return;
    setState(() {
      _isStartingCountdown = true;
      _countdown = 3;
    });
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown! > 1) {
        setState(() => _countdown = _countdown! - 1);
      } else {
        t.cancel();
        ref.read(vipRoomProvider.notifier).consumeNavEvent();
        context.push(
          AppConstants.ludoBoardRoute,
          extra: LudoBoardArgs(
            players: room.maxPlayers,
            bet: room.entryFee,
            roomId: room.id,
            gameId: room.gameId,
            isOnline: true,
            roomMode: RoomMode.vip,
            roomCode: room.roomCode,
            turnSeconds: room.turnSeconds,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vipRoomProvider);
    final myUserId = ref.watch(authProvider).user?.id;

    // React to nav events
    ref.listen<PrivateRoomState>(vipRoomProvider, (prev, next) {
      if (next.navEvent == PrivateRoomNavEvent.goToGame &&
          !_isStartingCountdown) {
        final room = next.room;
        if (room != null && myUserId != null) {
          final gameId = room.gameId ?? 0;
          _startCountdown(gameId, room, myUserId);
        }
      } else if (next.navEvent == PrivateRoomNavEvent.goHome) {
        ref.read(vipRoomProvider.notifier).consumeNavEvent();
        if (mounted) {
          _showRoomCancelledSnackbar();
          context.go(AppConstants.vipRoomRoute);
        }
      }
    });

    final room = state.room;

    if (room == null) {
      return Scaffold(
        body: RoomBackdrop(
          type: RoomType.vip,
          child: Center(
            child: state.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const RoomHeroIcon(type: RoomType.vip),
                        const SizedBox(height: 16),
                        const Text(
                          'VIP room not found or closed',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        RoomActionButton(
                          label: 'BACK TO VIP HUB',
                          type: RoomType.vip,
                          onPressed: () => context.go(AppConstants.vipRoomRoute),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    }

    final isHost = room.isHost(myUserId);
    final myParticipant = room.participants
        .where((p) => myUserId != null && p.userId == myUserId)
        .firstOrNull ??
        (isHost
            ? room.participants.where((p) => p.isHost).firstOrNull
            : null);
    final amIReady = myParticipant?.isReady ?? false;

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: Stack(
          children: [
            Column(
              children: [
                RoomHeader(
                  title: 'VIP GAME LOBBY',
                  subtitle:
                      isHost ? 'You are the host' : 'Waiting for host to start',
                  type: RoomType.vip,
                  onBack: state.isLoading ? null : _onLeave,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    children: [
                      RoomCodeCard(code: room.roomCode, type: RoomType.vip),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.people_rounded,
                              label: '${room.playerCount}/${room.maxPlayers}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.timer_rounded,
                              label: '${room.turnSeconds}s',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.workspace_premium_rounded,
                              label: '${room.entryFee}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: room.maxPlayers,
                        itemBuilder: (context, index) {
                          final seat = index + 1;
                          final participant = room.participants
                              .where((p) => p.seatPosition == seat)
                              .firstOrNull;
                          return _PlayerSeatCard(
                            seat: seat,
                            participant: participant,
                            isMe: (myUserId != null &&
                                    participant?.userId == myUserId) ||
                                (participant != null &&
                                    participant.isHost &&
                                    isHost),
                          );
                        },
                      ),
                      if (state.failure != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(
                          failure: state.failure!,
                          onDismiss: () => ref
                              .read(vipRoomProvider.notifier)
                              .clearFailure(),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                  child: isHost
                      ? RoomActionButton(
                          key: const Key('btn_start_vip_game'),
                          label: state.isLoading
                              ? 'STARTING...'
                              : room.canStart
                                  ? 'START GAME'
                                  : 'WAITING FOR PLAYERS',
                          icon: Icons.play_arrow_rounded,
                          type: RoomType.vip,
                          enabled: !state.isLoading && room.canStart,
                          onPressed: _onStart,
                        )
                      : RoomActionButton(
                          key: const Key('btn_toggle_vip_ready'),
                          label: state.isLoading
                              ? 'UPDATING...'
                              : amIReady
                                  ? 'READY ✓'
                                  : 'I AM READY',
                          icon: amIReady
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          type: RoomType.vip,
                          enabled: !state.isLoading,
                          onPressed: () => _onToggleReady(amIReady),
                        ),
                ),
              ],
            ),
            if (_countdown != null)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontSize: 110,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD45C),
                          ),
                        ),
                        const Text(
                          'GET READY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRoomCancelledSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VIP room was cancelled or expired'),
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
}

const _colorMap = <String, Color>{
  'red': Color(0xFFE53935),
  'green': Color(0xFF43A047),
  'yellow': Color(0xFFFDD835),
  'blue': Color(0xFF1E88E5),
};

class _PlayerSeatCard extends StatelessWidget {
  const _PlayerSeatCard({
    required this.seat,
    this.participant,
    this.isMe = false,
  });
  final int seat;
  final RoomParticipantDto? participant;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final color = _colorMap[participant?.color ?? ''] ?? Colors.white24;
    final isEmpty = participant == null;

    return Container(
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmpty ? Colors.white12 : color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_rounded,
                      color: const Color(0xFFFFD45C).withOpacity(0.4),
                      size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'Seat $seat',
                    style: const TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: color,
                        child: Text(
                          participant!.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      if (participant!.isHost)
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD45C), size: 16),
                      if (participant!.isReady && !participant!.isHost)
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF00C853), size: 16),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    isMe
                        ? '${participant!.username} (you)'
                        : participant!.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    participant!.isHost
                        ? 'Host'
                        : participant!.isReady
                            ? 'Ready'
                            : 'Not ready',
                    style: TextStyle(
                      color: participant!.isHost
                          ? const Color(0xFFFFD45C)
                          : participant!.isReady
                              ? const Color(0xFF00C853)
                              : Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.failure, required this.onDismiss});
  final RoomFailure failure;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              failure.message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
          IconButton(
            key: const Key('btn_dismiss_error'),
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
