import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../widgets/room_widgets.dart';

import '../../auth/providers/auth_provider.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../providers/private_room_provider.dart';

class PrivateRoomHubScreen extends ConsumerStatefulWidget {
  const PrivateRoomHubScreen({super.key});

  @override
  ConsumerState<PrivateRoomHubScreen> createState() =>
      _PrivateRoomHubScreenState();
}

class _PrivateRoomHubScreenState extends ConsumerState<PrivateRoomHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref
            .read(privateRoomProvider.notifier)
            .restoreActiveRoom(myUserId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PrivateRoomState>(privateRoomProvider, (prev, next) {
      if (next.navEvent == PrivateRoomNavEvent.goToLobby) {
        ref.read(privateRoomProvider.notifier).consumeNavEvent();
        context.push(AppConstants.privateRoomLobbyRoute);
      } else if (next.navEvent == PrivateRoomNavEvent.goToGame) {
        final room = next.room;
        ref.read(privateRoomProvider.notifier).consumeNavEvent();
        if (room != null) {
          context.push(
            AppConstants.ludoBoardRoute,
            extra: LudoBoardArgs(
              players: room.maxPlayers,
              bet: room.entryFee,
              roomId: room.id,
              gameId: room.gameId,
              isOnline: true,
              roomMode: RoomMode.private,
              roomCode: room.roomCode,
              turnSeconds: room.turnSeconds,
            ),
          );
        }
      }
    });

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.private,
        child: Column(
          children: [
            const RoomHeader(
              title: 'PRIVATE ROOM',
              subtitle: 'Play your rules, with your people',
              type: RoomType.private,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Center(
                    child: RoomHeroIcon(type: RoomType.private, size: 106),
                  ),
                  const SizedBox(height: 18),
                  _EntryCard(
                    title: 'Create a private room',
                    subtitle: 'Choose players, entry fee and turn timer',
                    icon: Icons.add_home_work_rounded,
                    type: RoomType.private,
                    onTap: () =>
                        context.push(AppConstants.privateRoomCreateRoute),
                  ),
                  const SizedBox(height: 14),
                  _EntryCard(
                    title: 'Join with a code',
                    subtitle: 'Enter the 6-character code shared by a friend',
                    icon: Icons.dialpad_rounded,
                    type: RoomType.private,
                    onTap: () =>
                        context.push(AppConstants.privateRoomJoinRoute),
                  ),
                  const SizedBox(height: 22),
                  const RoomGlassCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Color(0xFF70F59A),
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Only invited players can enter. The host controls rules and starts the match.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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

class VipRoomEntryScreen extends StatelessWidget {
  const VipRoomEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: Column(
          children: [
            const RoomHeader(
              title: 'VIP ROOMS',
              subtitle: 'Premium tables & live lounges',
              type: RoomType.vip,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  const Center(
                    child: RoomHeroIcon(type: RoomType.vip, size: 118),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ROYAL ACCESS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFFFD45C),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create premium rooms, talk with friends and play exclusive Ludo tables.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.45),
                  ),
                  const SizedBox(height: 22),
                  _EntryCard(
                    title: 'Browse VIP rooms',
                    subtitle: 'Live lounges and open premium tables',
                    icon: Icons.diamond_rounded,
                    type: RoomType.vip,
                    onTap: () => context.push(AppConstants.vipRoomBrowserRoute),
                  ),
                  const SizedBox(height: 14),
                  _EntryCard(
                    title: 'Create a VIP room',
                    subtitle: 'Host a premium voice-enabled match',
                    icon: Icons.workspace_premium_rounded,
                    type: RoomType.vip,
                    onTap: () => context.push(AppConstants.vipRoomCreateRoute),
                  ),
                  const SizedBox(height: 20),
                  RoomActionButton(
                    label: 'VIP MEMBERSHIP',
                    icon: Icons.card_membership_rounded,
                    type: RoomType.vip,
                    onPressed: () =>
                        context.push(AppConstants.subscriptionRoute),
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

class VipRoomBrowserScreen extends ConsumerWidget {
  const VipRoomBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const rooms = [
      ('Royal Stars Lounge', '824610', 3),
      ('Champions Table', '721945', 2),
      ('Midnight VIP', '919270', 1),
    ];
    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: Column(
          children: [
            const RoomHeader(
              title: 'VIP LOUNGES',
              subtitle: 'Open premium rooms',
              type: RoomType.vip,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: rooms.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == rooms.length) {
                    return RoomActionButton(
                      label: 'JOIN WITH CODE',
                      icon: Icons.dialpad_rounded,
                      type: RoomType.vip,
                      onPressed: () =>
                          context.push(AppConstants.vipRoomJoinRoute),
                    );
                  }
                  final room = rooms[index];
                  return RoomGlassCard(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF4A267A),
                          radius: 28,
                          child: Icon(
                            Icons.mic_rounded,
                            color: Color(0xFFFFD45C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.$1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${room.$3}/4 playing  •  Voice live',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (await ref
                                    .read(roomFlowProvider.notifier)
                                    .joinRoom(RoomType.vip, room.$2) &&
                                context.mounted) {
                              context.push(AppConstants.vipRoomLobbyRoute);
                            }
                          },
                          child: const Text(
                            'JOIN',
                            style: TextStyle(
                              color: Color(0xFFFFD45C),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateGameRoomScreen extends ConsumerStatefulWidget {
  const CreateGameRoomScreen({super.key, required this.type});
  final RoomType type;

  @override
  ConsumerState<CreateGameRoomScreen> createState() =>
      _CreateGameRoomScreenState();
}

class _CreateGameRoomScreenState extends ConsumerState<CreateGameRoomScreen> {
  RoomSettings settings = const RoomSettings();

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(roomFlowProvider);
    final vip = widget.type == RoomType.vip;
    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: Column(
          children: [
            RoomHeader(
              title: vip ? 'CREATE VIP ROOM' : 'CREATE PRIVATE ROOM',
              subtitle: 'Set the table your way',
              type: widget.type,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _ChoiceSection(
                    title: 'PLAYERS',
                    children: [
                      _ChoiceChip(
                        label: '2 Players',
                        selected: settings.maxPlayers == 2,
                        onTap: () => setState(
                          () => settings = settings.copyWith(maxPlayers: 2),
                        ),
                      ),
                      _ChoiceChip(
                        label: '4 Players',
                        selected: settings.maxPlayers == 4,
                        onTap: () => setState(
                          () => settings = settings.copyWith(maxPlayers: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: 'TURN TIMER',
                    children: [10, 15, 30]
                        .map(
                          (v) => _ChoiceChip(
                            label: '${v}s',
                            selected: settings.turnSeconds == v,
                            onTap: () => setState(
                              () =>
                                  settings = settings.copyWith(turnSeconds: v),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: 'ENTRY FEE',
                    children: [0, 500, 1000, 5000]
                        .map(
                          (v) => _ChoiceChip(
                            label: v == 0 ? 'Free' : '$v',
                            selected: settings.entryFee == v,
                            onTap: () => setState(
                              () => settings = settings.copyWith(entryFee: v),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  RoomGlassCard(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: settings.friendsOnly,
                          onChanged: (v) => setState(
                            () => settings = settings.copyWith(friendsOnly: v),
                          ),
                          title: const Text(
                            'Invite only',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Only people with your code can join',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SwitchListTile.adaptive(
                          value: settings.voiceEnabled,
                          onChanged: (v) => setState(
                            () => settings = settings.copyWith(voiceEnabled: v),
                          ),
                          title: const Text(
                            'Voice lounge',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Talk before and during the match',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (flow.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        flow.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: RoomActionButton(
                label: flow.isLoading ? 'CREATING...' : 'CREATE ROOM',
                type: widget.type,
                enabled: !flow.isLoading,
                onPressed: () async {
                  final ok = await ref
                      .read(roomFlowProvider.notifier)
                      .createRoom(widget.type, settings);
                  if (ok && context.mounted)
                    context.push(
                      vip
                          ? AppConstants.vipRoomLobbyRoute
                          : AppConstants.privateRoomLobbyRoute,
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinGameRoomScreen extends ConsumerStatefulWidget {
  const JoinGameRoomScreen({super.key, required this.type});
  final RoomType type;
  @override
  ConsumerState<JoinGameRoomScreen> createState() => _JoinGameRoomScreenState();
}

class _JoinGameRoomScreenState extends ConsumerState<JoinGameRoomScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(roomFlowProvider);
    final vip = widget.type == RoomType.vip;
    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: Column(
          children: [
            RoomHeader(
              title: vip ? 'JOIN VIP ROOM' : 'JOIN PRIVATE ROOM',
              subtitle: 'Ask the host for their code',
              type: widget.type,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoomHeroIcon(type: widget.type, size: 94),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    if (flow.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          flow.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    const SizedBox(height: 20),
                    RoomActionButton(
                      label: flow.isLoading ? 'JOINING...' : 'JOIN ROOM',
                      type: widget.type,
                      enabled: !flow.isLoading,
                      onPressed: () async {
                        final ok = await ref
                            .read(roomFlowProvider.notifier)
                            .joinRoom(widget.type, controller.text);
                        if (ok && context.mounted)
                          context.push(
                            vip
                                ? AppConstants.vipRoomLobbyRoute
                                : AppConstants.privateRoomLobbyRoute,
                          );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.onTap,
  });
  final String title, subtitle;
  final IconData icon;
  final RoomType type;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => RoomGlassCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
          ),
          child: Icon(
            icon,
            color: type == RoomType.vip
                ? const Color(0xFFFFD45C)
                : const Color(0xFF5FE8FF),
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.white54),
      ],
    ),
  );
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => RoomGlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFF5D48E8),
    backgroundColor: Colors.white10,
    side: BorderSide(
      color: selected ? const Color(0xFFBFA8FF) : Colors.white12,
    ),
    labelStyle: TextStyle(
      color: selected ? Colors.white : Colors.white70,
      fontWeight: FontWeight.bold,
    ),
  );
}
