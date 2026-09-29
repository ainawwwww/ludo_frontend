// lib/features/rooms/screens/private_room_lobby_screen.dart
//
// Real API-backed Private Room Lobby Screen (Phase 5).
//
// Responsibilities:
// - Subscribes to privateRoomProvider (state machine + WebSocket).
// - Reacts to PrivateRoomNavEvent.goToGame  -> pushes /ludo-board.
// - Reacts to PrivateRoomNavEvent.goHome    -> goes to /home.
// - Host: shows "START GAME" button (enabled when canStart).
// - Guest: shows "READY / NOT READY" toggle.
// - Displays live participant list with ready/color indicators.
// - Shows room code with clipboard copy.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/game/models/room_mode.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/widgets/room_widgets.dart';

// ---------------------------------------------------------------------------

class PrivateRoomLobbyScreen extends ConsumerStatefulWidget {
  const PrivateRoomLobbyScreen({super.key});

  @override
  ConsumerState<PrivateRoomLobbyScreen> createState() =>
      _PrivateRoomLobbyScreenState();
}

class _PrivateRoomLobbyScreenState
    extends ConsumerState<PrivateRoomLobbyScreen> {
  bool _isStartingCountdown = false;
  int? _countdown;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ---- Navigation handler -------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // ---- Actions ------------------------------------------------------------

  Future<void> _onStart() async {
    final room = ref.read(privateRoomProvider).room;
    if (room == null || !room.canStart) return;
    await ref.read(privateRoomProvider.notifier).startMatch();
    // Navigation happens via WS 'started' event -> navEvent -> listener below.
  }

  Future<void> _onToggleReady(bool currentlyReady) async {
    await ref
        .read(privateRoomProvider.notifier)
        .setReady(isReady: !currentlyReady);
  }

  Future<void> _onLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D1250),
        title: const Text('Leave room?',
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
    await ref.read(privateRoomProvider.notifier).leave();
    if (mounted) context.go(AppConstants.homeRoute);
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
        ref.read(privateRoomProvider.notifier).consumeNavEvent();
        context.push(
          AppConstants.ludoBoardRoute,
          extra: {
            'players': room.maxPlayers,
            'bet': room.entryFee,
            'room_id': room.id,
            'isOnline': true,
            'roomMode': RoomMode.private,
            'roomCode': room.roomCode,
          },
        );
      }
    });
  }

  // ---- Build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateRoomProvider);
    final myUserId = ref.watch(authProvider).user?.id;

    // React to nav events
    ref.listen<PrivateRoomState>(privateRoomProvider, (prev, next) {
      if (next.navEvent == PrivateRoomNavEvent.goToGame &&
          !_isStartingCountdown) {
        final room = next.room;
        if (room != null && myUserId != null) {
          final gameId = room.gameId ?? 0;
          _startCountdown(gameId, room, myUserId);
        }
      } else if (next.navEvent == PrivateRoomNavEvent.goHome) {
        ref.read(privateRoomProvider.notifier).consumeNavEvent();
        if (mounted) {
          _showRoomCancelledSnackbar();
          context.go(AppConstants.homeRoute);
        }
      }
    });

    final room = state.room;

    // No room -> redirected out; show loading while nav resolves
    if (room == null) {
      return Scaffold(
        body: RoomBackdrop(
          type: RoomType.private,
          child: Center(
            child: state.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.meeting_room_outlined,
                            color: Colors.white54, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Room not found',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        _ActionButton(
                          label: 'GO HOME',
                          onPressed: () => context.go(AppConstants.homeRoute),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      );
    }

    final isHost = myUserId != null && room.createdBy == myUserId;
    final myParticipant = room.participants
        .where((p) => p.userId == myUserId)
        .firstOrNull;
    final amIReady = myParticipant?.isReady ?? false;

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.private,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _LobbyHeader(
                  isHost: isHost,
                  onBack: state.isLoading ? null : _onLeave,
                ),

                // Body
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    children: [
                      // Room code card
                      _RoomCodeCard(
                          code: room.roomCode,
                          entryFee: room.entryFee),

                      const SizedBox(height: 14),

                      // Info pills
                      Row(
                        children: [
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.people_rounded,
                              label:
                                  '${room.playerCount}/${room.maxPlayers}',
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
                              icon: Icons.monetization_on_rounded,
                              label: room.entryFee == 0
                                  ? 'Free'
                                  : '${room.entryFee}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Participant grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
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
                            isMe: participant?.userId == myUserId,
                          );
                        },
                      ),

                      // Error banner
                      if (state.failure != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(
                          failure: state.failure!,
                          onDismiss: () => ref
                              .read(privateRoomProvider.notifier)
                              .clearFailure(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Bottom action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                  child: isHost
                      ? _ActionButton(
                          key: const Key('btn_start_game'),
                          label: state.isLoading
                              ? 'STARTING...'
                              : room.canStart
                                  ? 'START GAME'
                                  : 'WAITING FOR PLAYERS',
                          icon: Icons.play_arrow_rounded,
                          enabled:
                              !state.isLoading && room.canStart,
                          onPressed: _onStart,
                        )
                      : _ActionButton(
                          key: const Key('btn_toggle_ready'),
                          label: state.isLoading
                              ? 'UPDATING...'
                              : amIReady
                                  ? 'READY ✓'
                                  : 'I AM READY',
                          icon: amIReady
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          enabled: !state.isLoading,
                          color: amIReady
                              ? const Color(0xFF00C853)
                              : null,
                          onPressed: () =>
                              _onToggleReady(amIReady),
                        ),
                ),
              ],
            ),

            // Countdown overlay
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
                            color: Color(0xFF5FE8FF),
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
        content: Text('Room was cancelled or expired'),
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets

class _LobbyHeader extends StatelessWidget {
  const _LobbyHeader({required this.isHost, this.onBack});
  final bool isHost;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRIVATE LOBBY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    isHost ? 'You are the host' : 'Waiting for host to start',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
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

class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({required this.code, required this.entryFee});
  final String code;
  final int entryFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.dialpad_rounded, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ROOM CODE',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('btn_copy_code'),
            icon: const Icon(Icons.copy_rounded,
                color: Color(0xFF5FE8FF), size: 20),
            tooltip: 'Copy code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room code copied!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
    final color =
        _colorMap[participant?.color ?? ''] ?? Colors.white24;
    final isEmpty = participant == null;

    return Container(
      decoration: BoxDecoration(
        color: isEmpty ? Colors.white.withOpacity(0.05) : color.withOpacity(0.15),
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
                      color: Colors.white24, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'Seat $seat',
                    style: const TextStyle(
                        color: Colors.white24, fontSize: 11),
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
                          participant!.username
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.color,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? const Color(0xFF2C6EF2);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        key: key,
        onPressed: enabled ? onPressed : null,
        icon: icon != null
            ? Icon(icon, color: Colors.white, size: 20)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? bg : Colors.white24,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
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


