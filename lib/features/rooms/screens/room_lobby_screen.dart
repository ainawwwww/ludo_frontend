import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../widgets/room_widgets.dart';

class RoomLobbyScreen extends ConsumerStatefulWidget {
  const RoomLobbyScreen({super.key, required this.type});
  final RoomType type;

  @override
  ConsumerState<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends ConsumerState<RoomLobbyScreen> {
  int? countdown;

  Future<void> _start(RoomSession session) async {
    if (!session.canStart) return;
    ref.read(roomFlowProvider.notifier).markStarting();
    for (var value = 3; value > 0; value--) {
      if (!mounted) return;
      setState(() => countdown = value);
      await Future<void>.delayed(const Duration(milliseconds: 650));
    }
    if (!mounted) return;
    context.push(
      AppConstants.ludoBoardRoute,
      extra: LudoBoardArgs(
        players: session.settings.maxPlayers,
        bet: session.settings.entryFee,
        roomId: session.id,
        isOnline: false,
        roomMode:
            session.type == RoomType.vip ? RoomMode.vip : RoomMode.private,
        roomCode: session.code,
        turnSeconds: session.settings.turnSeconds,
      ),
    );
    setState(() => countdown = null);
  }

  Future<void> _leave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1250),
        title: const Text('Leave room?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your seat will become available to another player.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'LEAVE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      ref.read(roomFlowProvider.notifier).leaveRoom();
      context.go(AppConstants.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomFlowProvider);
    final session = state.session;
    if (session == null) {
      return Scaffold(
        body: RoomBackdrop(
          type: widget.type,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RoomHeroIcon(type: widget.type),
                  const SizedBox(height: 18),
                  const Text(
                    'This room is no longer active.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  RoomActionButton(
                    label: 'BACK HOME',
                    type: widget.type,
                    onPressed: () => context.go(AppConstants.homeRoute),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final vip = widget.type == RoomType.vip;
    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: Stack(
          children: [
            Column(
              children: [
                RoomHeader(
                  title: vip ? 'VIP GAME LOBBY' : 'PRIVATE LOBBY',
                  subtitle: session.isHost
                      ? 'You are the host'
                      : 'Waiting for the host',
                  type: widget.type,
                  onBack: _leave,
                  trailing: IconButton(
                    onPressed: _showRules,
                    icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    children: [
                      RoomCodeCard(code: session.code, type: widget.type),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.people_rounded,
                              label: '${session.settings.maxPlayers} players',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.timer_rounded,
                              label: '${session.settings.turnSeconds}s turns',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.monetization_on_rounded,
                              label: session.settings.entryFee == 0
                                  ? 'Free'
                                  : '${session.settings.entryFee}',
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
                        itemCount: session.settings.maxPlayers,
                        itemBuilder: (context, index) {
                          RoomParticipant? participant;
                          for (final item in session.participants) {
                            if (item.seat == index + 1) participant = item;
                          }
                          return RoomPlayerSeat(
                            index: index + 1,
                            type: widget.type,
                            participant: participant,
                            onEmptyTap: session.isHost
                                ? ref
                                      .read(roomFlowProvider.notifier)
                                      .addMockGuest
                                : null,
                          );
                        },
                      ),
                      if (vip && session.settings.voiceEnabled) ...[
                        const SizedBox(height: 14),
                        RoomGlassCard(
                          onTap: () =>
                              context.push(AppConstants.vipVoiceLoungeRoute),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: Color(0xFFFFD45C),
                                size: 30,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VIP Voice Lounge',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Talk, chat and manage live seats',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                  child: session.isHost
                      ? RoomActionButton(
                          label: session.canStart
                              ? 'START GAME'
                              : 'WAITING FOR PLAYERS',
                          icon: Icons.play_arrow_rounded,
                          type: widget.type,
                          enabled: session.canStart,
                          onPressed: () => _start(session),
                        )
                      : RoomActionButton(
                          label:
                              session.participants
                                  .firstWhere((p) => p.id == 'me')
                                  .ready
                              ? 'READY!'
                              : 'I AM READY',
                          icon: Icons.check_circle_rounded,
                          type: widget.type,
                          onPressed: ref
                              .read(roomFlowProvider.notifier)
                              .toggleReady,
                        ),
                ),
              ],
            ),
            if (countdown != null)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$countdown',
                          style: TextStyle(
                            fontSize: 110,
                            fontWeight: FontWeight.w900,
                            color: vip
                                ? const Color(0xFFFFD45C)
                                : const Color(0xFF5FE8FF),
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

  void _showRules() {
    final session = ref.read(roomFlowProvider).session;
    if (session == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1D1250),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ROOM RULES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _RuleLine('Players', '${session.settings.maxPlayers}'),
              _RuleLine(
                'Turn timer',
                '${session.settings.turnSeconds} seconds',
              ),
              _RuleLine(
                'Entry fee',
                session.settings.entryFee == 0
                    ? 'Free'
                    : '${session.settings.entryFee} coins',
              ),
              _RuleLine(
                'Access',
                session.settings.friendsOnly ? 'Invite only' : 'Open',
              ),
              _RuleLine(
                'Voice lounge',
                session.settings.voiceEnabled ? 'Enabled' : 'Off',
              ),
            ],
          ),
        ),
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

class _RuleLine extends StatelessWidget {
  const _RuleLine(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white60)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
