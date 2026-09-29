import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../models/private_room_dto.dart';
import '../models/room_failure.dart';
import '../models/room_models.dart';
import '../providers/private_room_provider.dart';
import '../providers/room_flow_provider.dart';
import '../providers/vip_room_provider.dart';
import '../widgets/room_widgets.dart';

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

    final privateRoomState = ref.watch(privateRoomProvider);
    final activeRoom = privateRoomState.room;

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
                  if (activeRoom != null &&
                      (activeRoom.isWaiting || activeRoom.isPlaying)) ...[
                    RoomGlassCard(
                      child: InkWell(
                        onTap: () {
                          if (activeRoom.isPlaying) {
                            context.push(
                              AppConstants.ludoBoardRoute,
                              extra: LudoBoardArgs(
                                players: activeRoom.maxPlayers,
                                bet: activeRoom.entryFee,
                                roomId: activeRoom.id,
                                gameId: activeRoom.gameId,
                                isOnline: true,
                                roomMode: RoomMode.private,
                                roomCode: activeRoom.roomCode,
                                turnSeconds: activeRoom.turnSeconds,
                              ),
                            );
                          } else {
                            context.push(AppConstants.privateRoomLobbyRoute);
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF00C853).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.meeting_room_rounded,
                                color: Color(0xFF00C853),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activeRoom.isPlaying
                                            ? 'ACTIVE MATCH'
                                            : 'ACTIVE ROOM LOBBY',
                                        style: const TextStyle(
                                          color: Color(0xFF00C853),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (activeRoom.roomCode.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            activeRoom.roomCode,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeRoom.isPlaying
                                        ? 'Tap to resume match'
                                        : 'Tap to return to lobby (${activeRoom.playerCount}/${activeRoom.maxPlayers})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
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

class VipRoomEntryScreen extends ConsumerStatefulWidget {
  const VipRoomEntryScreen({super.key});

  @override
  ConsumerState<VipRoomEntryScreen> createState() => _VipRoomEntryScreenState();
}

class _VipRoomEntryScreenState extends ConsumerState<VipRoomEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref
            .read(vipRoomProvider.notifier)
            .restoreActiveRoom(myUserId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PrivateRoomState>(vipRoomProvider, (prev, next) {
      if (next.navEvent == PrivateRoomNavEvent.goToLobby) {
        ref.read(vipRoomProvider.notifier).consumeNavEvent();
        context.push(AppConstants.vipRoomLobbyRoute);
      } else if (next.navEvent == PrivateRoomNavEvent.goToGame) {
        final room = next.room;
        ref.read(vipRoomProvider.notifier).consumeNavEvent();
        if (room != null) {
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
      }
    });

    final vipRoomState = ref.watch(vipRoomProvider);
    final activeRoom = vipRoomState.room;

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
                  const SizedBox(height: 18),
                  if (activeRoom != null &&
                      (activeRoom.isWaiting || activeRoom.isPlaying)) ...[
                    RoomGlassCard(
                      child: InkWell(
                        onTap: () {
                          if (activeRoom.isPlaying) {
                            context.push(
                              AppConstants.ludoBoardRoute,
                              extra: LudoBoardArgs(
                                players: activeRoom.maxPlayers,
                                bet: activeRoom.entryFee,
                                roomId: activeRoom.id,
                                gameId: activeRoom.gameId,
                                isOnline: true,
                                roomMode: RoomMode.vip,
                                roomCode: activeRoom.roomCode,
                                turnSeconds: activeRoom.turnSeconds,
                              ),
                            );
                          } else {
                            context.push(AppConstants.vipRoomLobbyRoute);
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFFD45C).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFFFD45C),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activeRoom.isPlaying
                                            ? 'ACTIVE MATCH'
                                            : 'ACTIVE VIP LOBBY',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD45C),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (activeRoom.roomCode.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            activeRoom.roomCode,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeRoom.isPlaying
                                        ? 'Tap to resume match'
                                        : 'Tap to return to lobby (${activeRoom.playerCount}/${activeRoom.maxPlayers})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
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
                    subtitle: 'Host a premium match',
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
  late int _maxPlayers;
  late int _entryFee;
  int _turnSeconds = 15;

  @override
  void initState() {
    super.initState();
    _maxPlayers = 2;
    _entryFee = widget.type == RoomType.vip
        ? kVipAllowedEntryFees.first
        : kAllowedEntryFees.first;
  }

  Future<void> _create() async {
    final myUserId = ref.read(authProvider).user?.id;
    if (myUserId == null) return;

    final provider =
        widget.type == RoomType.vip ? vipRoomProvider : privateRoomProvider;

    await ref.read(provider.notifier).create(
          maxPlayers: _maxPlayers,
          entryFee: _entryFee,
          turnSeconds: _turnSeconds,
          myUserId: myUserId,
        );

    if (!mounted) return;
    final state = ref.read(provider);
    if (state.room != null) {
      context.pushReplacement(
        widget.type == RoomType.vip
            ? AppConstants.vipRoomLobbyRoute
            : AppConstants.privateRoomLobbyRoute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        widget.type == RoomType.vip ? vipRoomProvider : privateRoomProvider;
    final state = ref.watch(provider);
    final userCoins = ref.watch(authProvider).user?.coins;
    final allowedFees =
        widget.type == RoomType.vip ? kVipAllowedEntryFees : kAllowedEntryFees;
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
                    children: kAllowedMaxPlayers
                        .map((v) => _ChoiceChip(
                              label: '$v Players',
                              selected: _maxPlayers == v,
                              onTap: () => setState(() => _maxPlayers = v),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: 'TURN TIMER',
                    children: kAllowedTurnSeconds
                        .map((v) => _ChoiceChip(
                              label: '${v}s',
                              selected: _turnSeconds == v,
                              onTap: () => setState(() => _turnSeconds = v),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: userCoins != null
                        ? 'ENTRY FEE  (Balance: $userCoins)'
                        : 'ENTRY FEE',
                    children: allowedFees
                        .map((v) => _ChoiceChip(
                              label: v == 0 ? 'Free' : '$v',
                              selected: _entryFee == v,
                              onTap: () => setState(() => _entryFee = v),
                            ))
                        .toList(),
                  ),
                  if (state.failure != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.redAccent.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              state.failure!.message,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13),
                            ),
                            if (state.failure is RoomAlreadyActive) ...[
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.meeting_room_rounded,
                                    size: 18),
                                label: const Text('GO TO YOUR ACTIVE ROOM'),
                                onPressed: () async {
                                  final uid = ref.read(authProvider).user?.id;
                                  if (uid != null) {
                                    await ref
                                        .read(provider.notifier)
                                        .restoreActiveRoom(myUserId: uid);
                                    if (context.mounted &&
                                        ref.read(provider).room != null) {
                                      context.pushReplacement(
                                        widget.type == RoomType.vip
                                            ? AppConstants.vipRoomLobbyRoute
                                            : AppConstants
                                                .privateRoomLobbyRoute,
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: Key('btn_create_room_${widget.type.name}'),
                  onPressed: state.isLoading ? null : _create,
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.add_home_work_rounded,
                          color: Colors.white),
                  label: Text(
                    state.isLoading ? 'CREATING...' : 'CREATE ROOM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vip
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFF2C6EF2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
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
  ConsumerState<JoinGameRoomScreen> createState() =>
      _JoinGameRoomScreenState();
}

class _JoinGameRoomScreenState extends ConsumerState<JoinGameRoomScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _localError;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim().toUpperCase();
    if (!RegExp(kRoomCodePattern).hasMatch(code)) {
      setState(() =>
          _localError = 'Enter a valid 6-character code (letters & numbers)');
      return;
    }
    setState(() => _localError = null);

    final myUserId = ref.read(authProvider).user?.id;
    if (myUserId == null) return;

    final provider =
        widget.type == RoomType.vip ? vipRoomProvider : privateRoomProvider;

    await ref.read(provider.notifier).join(code, myUserId: myUserId);

    if (!mounted) return;
    final state = ref.read(provider);
    if (state.room != null) {
      context.pushReplacement(
        widget.type == RoomType.vip
            ? AppConstants.vipRoomLobbyRoute
            : AppConstants.privateRoomLobbyRoute,
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    final cleaned =
        text.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length >= 6) {
      _controller.text = cleaned.substring(0, 6);
      _join();
    } else if (cleaned.isNotEmpty) {
      _controller.text = cleaned;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        widget.type == RoomType.vip ? vipRoomProvider : privateRoomProvider;
    final state = ref.watch(provider);
    final errorText = _localError ?? state.failure?.message;
    final vip = widget.type == RoomType.vip;

    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: Column(
          children: [
            RoomHeader(
              title: vip ? 'JOIN VIP ROOM' : 'JOIN PRIVATE ROOM',
              subtitle: 'Enter the code shared by the host',
              type: widget.type,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dialpad_rounded,
                      color: vip
                          ? const Color(0xFFFFD45C)
                          : const Color(0xFF5FE8FF),
                      size: 64,
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      key: Key('input_room_code_${widget.type.name}'),
                      controller: _controller,
                      focusNode: _focus,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]')),
                        _UpperCaseFormatter(),
                      ],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'ABCDE1',
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: vip
                                ? const Color(0xFFFFD45C)
                                : const Color(0xFF5FE8FF),
                            width: 2,
                          ),
                        ),
                        errorText: errorText,
                        errorStyle: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                      ),
                      onSubmitted: (_) => _join(),
                      onChanged: (_) {
                        if (_localError != null) {
                          setState(() => _localError = null);
                        }
                        if (state.failure != null) {
                          ref.read(provider.notifier).clearFailure();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: Key('btn_paste_code_${widget.type.name}'),
                        onPressed: state.isLoading ? null : _pasteFromClipboard,
                        icon: Icon(Icons.content_paste_rounded,
                            size: 16,
                            color: vip
                                ? const Color(0xFFFFD45C)
                                : const Color(0xFF5FE8FF)),
                        label: Text(
                          'Paste from Clipboard',
                          style: TextStyle(
                            color: vip
                                ? const Color(0xFFFFD45C)
                                : const Color(0xFF5FE8FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        key: Key('btn_join_room_${widget.type.name}'),
                        onPressed: state.isLoading ? null : _join,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.login_rounded,
                                color: Colors.white),
                        label: Text(
                          state.isLoading ? 'JOINING...' : 'JOIN ROOM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vip
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF2C6EF2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    if (state.failure is RoomAlreadyActive) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          key: Key(
                              'btn_reenter_active_room_${widget.type.name}'),
                          onPressed: () async {
                            final uid = ref.read(authProvider).user?.id;
                            if (uid != null) {
                              await ref
                                  .read(provider.notifier)
                                  .restoreActiveRoom(myUserId: uid);
                              if (context.mounted &&
                                  ref.read(provider).room != null) {
                                context.pushReplacement(
                                  widget.type == RoomType.vip
                                      ? AppConstants.vipRoomLobbyRoute
                                      : AppConstants.privateRoomLobbyRoute,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.meeting_room_rounded,
                              color: Colors.white),
                          label: const Text(
                            'ENTER YOUR ROOM LOBBY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Codes are 6 characters — letters and numbers only\n'
                      '(no ambiguous characters like 0, O, I, or 1)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white38, fontSize: 11, height: 1.5),
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
              decoration: const BoxDecoration(
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

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
