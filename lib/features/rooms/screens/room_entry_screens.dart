import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/vip_access_provider.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../providers/vip_room_provider.dart';
import '../widgets/room_widgets.dart';
import 'private_room_create_screen.dart';
import 'private_room_join_screen.dart';
import 'vip_room_create_screen.dart';
import 'vip_room_join_screen.dart';

class PrivateRoomHubScreen extends StatelessWidget {
  const PrivateRoomHubScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const CreateGameRoomScreen(type: RoomType.private);
}

class TeamRoomHubScreen extends StatelessWidget {
  const TeamRoomHubScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const CreateGameRoomScreen(type: RoomType.team);
}

class VipRoomEntryScreen extends StatelessWidget {
  const VipRoomEntryScreen({super.key});
  @override
  Widget build(BuildContext context) => const VipRoomBrowserScreen();
}

class VipRoomBrowserScreen extends ConsumerWidget {
  const VipRoomBrowserScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const rooms = [
      ('Royal Stars', '824610', 500, 3, 'Classic'),
      ('Moon Crown', '721945', 1000, 2, 'Quick'),
      ('Golden Night', '919270', 2500, 1, 'Master'),
    ];
    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: SafeArea(
          child: Column(children: [
            SizedBox(
              height: 72,
              child: Row(children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_alt_rounded,
                        color: Color(0xFFFFD45C), size: 30)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search_rounded,
                        color: Color(0xFFFFD45C), size: 30)),
                Expanded(
                    child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                      'assets/graphics/rooms/generated/vip_header_plaque.png',
                      height: 64,
                      fit: BoxFit.fill),
                  const Text('LUDO VIP',
                      style: TextStyle(
                          color: Color(0xFFFFF08A),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 3)
                          ])),
                ])),
                IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFFFFD45C), size: 34)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                _roundIcon(Icons.tune_rounded),
                const SizedBox(width: 10),
                _roundIcon(Icons.search_rounded),
                const Spacer(),
                TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('New rooms'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD45C))),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return RoomGlassCard(
                    child: Row(children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFFFD45C), width: 2),
                            gradient: const LinearGradient(colors: [
                              Color(0xFF5B2D88),
                              Color(0xFF17113E)
                            ])),
                        child: const Icon(Icons.workspace_premium_rounded,
                            color: Color(0xFFFFD45C), size: 34),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(room.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            Text('🪙 ${room.$3}   •   Rank 1',
                                style: const TextStyle(
                                    color: Color(0xFFFFD45C), fontSize: 12)),
                            Text('${room.$4}/4 players  •  ${room.$5}',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11)),
                          ])),
                      TextButton(
                        onPressed: () async {
                          guardVipAction(context, ref, () async {
                            final myUserId = ref.read(authProvider).user?.id;
                            if (myUserId == null) return;
                            await ref.read(vipRoomProvider.notifier).join(
                                  room.$2,
                                  myUserId: myUserId,
                                );
                            if (context.mounted &&
                                ref.read(vipRoomProvider).room != null) {
                              context.push(AppConstants.vipRoomLobbyRoute);
                            }
                          });
                        },
                        child: const Text('JOIN',
                            style: TextStyle(
                                color: Color(0xFFFFD45C),
                                fontWeight: FontWeight.w900)),
                      ),
                    ]),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              decoration: const BoxDecoration(
                  color: Color(0xCC120D35),
                  border: Border(top: BorderSide(color: Color(0x66FFD45C)))),
              child: Row(children: [
                Expanded(
                    child: _VipBottomButton(
                        label: 'Seat',
                        icon: Icons.event_seat_rounded,
                        onTap: () => guardVipAction(context, ref,
                            () async => _join(context, RoomType.vip)))),
                const SizedBox(width: 8),
                Expanded(
                    child: _VipBottomButton(
                        label: 'Host',
                        icon: Icons.add_circle_rounded,
                        primary: true,
                        onTap: () => guardVipAction(
                            context,
                            ref,
                            () async => context
                                .push(AppConstants.vipRoomCreateRoute)))),
                const SizedBox(width: 8),
                Expanded(
                    child: _VipBottomButton(
                        label: 'Join',
                        icon: Icons.login_rounded,
                        onTap: () => guardVipAction(context, ref,
                            () async => _join(context, RoomType.vip)))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _roundIcon(IconData icon) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24)),
        child: Icon(icon, color: Colors.white),
      );
}

class CreateGameRoomScreen extends ConsumerStatefulWidget {
  const CreateGameRoomScreen({super.key, required this.type});
  final RoomType type;
  @override
  ConsumerState<CreateGameRoomScreen> createState() =>
      _CreateGameRoomScreenState();
}

class _CreateGameRoomScreenState extends ConsumerState<CreateGameRoomScreen> {
  RoomSettings settings = const RoomSettings(entryFee: 500);
  @override
  Widget build(BuildContext context) {
    if (widget.type == RoomType.private) {
      return const PrivateRoomCreateScreen();
    }
    if (widget.type == RoomType.vip) {
      return const VipRoomCreateScreen();
    }
    final flow = ref.watch(roomFlowProvider);
    final title = widget.type == RoomType.team
        ? 'TEAM'
        : widget.type == RoomType.vip
            ? 'VIP ROOM'
            : 'PRIVATE';
    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: SafeArea(
          child: Column(children: [
            SizedBox(
              height: 160,
              child: Stack(children: [
                Center(
                    child: Image.asset(
                        'assets/graphics/rooms/generated/vs_badge.png',
                        width: 175,
                        fit: BoxFit.contain)),
                PositionedDirectional(
                    start: 14,
                    top: 12,
                    child: CircleAvatar(
                        backgroundColor: const Color(0xFF1B5187),
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.help_outline_rounded,
                                color: Colors.white)))),
                PositionedDirectional(
                    end: 0,
                    top: 12,
                    child: InkWell(
                        onTap: () => context.pop(),
                        child: Container(
                            width: 62,
                            height: 48,
                            decoration: BoxDecoration(
                                color: const Color(0xFFC94128),
                                borderRadius:
                                    const BorderRadiusDirectional.only(
                                        topStart: Radius.circular(12),
                                        bottomStart: Radius.circular(12)),
                                border: Border.all(
                                    color: const Color(0xFFFFB42C), width: 3)),
                            child: const Icon(Icons.close_rounded,
                                color: Color(0xFFFFE56D), size: 34)))),
                PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFFFCC31),
                            fontSize: 20,
                            fontWeight: FontWeight.w900))),
              ]),
            ),
            Expanded(
                child: ListView(padding: const EdgeInsets.all(18), children: [
              RoomGlassCard(
                  child: Column(children: [
                const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Select Mode', style: _headingStyle),
                      SizedBox(width: 8),
                      Icon(Icons.help_outline_rounded, color: Colors.white70)
                    ]),
                const SizedBox(height: 12),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LudoRoomMode.values
                        .map((mode) => _ModeButton(
                            mode: mode,
                            selected: settings.mode == mode,
                            onTap: () => setState(() =>
                                settings = settings.copyWith(mode: mode))))
                        .toList()),
              ])),
              const SizedBox(height: 18),
              RoomGlassCard(
                  child: Row(children: [
                Checkbox(
                    value: settings.magicDice,
                    onChanged: (value) => setState(() => settings =
                        settings.copyWith(magicDice: value ?? false)),
                    activeColor: const Color(0xFFFFC928)),
                const Spacer(),
                const Icon(Icons.casino_rounded,
                    color: Color(0xFFFFD22E), size: 36),
                const SizedBox(width: 8),
                const Text('Magic',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                const Icon(Icons.help_outline_rounded,
                    color: Colors.white70, size: 30),
              ])),
              const SizedBox(height: 18),
              const Text('Entry Coins', style: _headingStyle),
              const SizedBox(height: 10),
              RoomGlassCard(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    IconButton(
                        onPressed: settings.entryFee > 0
                            ? () => setState(() => settings = settings.copyWith(
                                entryFee: settings.entryFee - 500))
                            : null,
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.white)),
                    Container(
                        width: 130,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF19103F),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD45C))),
                        child: Text('🪙 ${settings.entryFee}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFFFFD45C),
                                fontSize: 18,
                                fontWeight: FontWeight.w900))),
                    IconButton(
                        onPressed: () => setState(() => settings = settings
                            .copyWith(entryFee: settings.entryFee + 500)),
                        icon:
                            const Icon(Icons.add_circle, color: Colors.white)),
                  ])),
              if (flow.error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(flow.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent))),
            ])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                Expanded(
                    child: _LobbyButton(
                        label: 'Single',
                        onTap: () =>
                            context.push(AppConstants.ludoLobbyRoute))),
                const SizedBox(width: 12),
                Expanded(
                    child: _LobbyButton(
                        label: flow.isLoading ? 'CREATING...' : 'CREATE',
                        enabled: !flow.isLoading,
                        onTap: _create)),
              ]),
            ),
            const SizedBox(height: 12),
            SafeArea(
                top: false,
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                    color: const Color(0xAA130E38),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                              child: Text('Have a team code?',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800))),
                          _GreenJoinButton(
                              onTap: () => _join(context, widget.type)),
                        ]))),
          ]),
        ),
      ),
    );
  }

  Future<void> _create() async {
    if (widget.type == RoomType.vip && !ref.read(isVipEligibleProvider)) {
      await guardVipAction(context, ref, () async {});
      return;
    }
    final adjusted =
        settings.copyWith(maxPlayers: widget.type == RoomType.team ? 2 : 4);
    final ok = await ref
        .read(roomFlowProvider.notifier)
        .createRoom(widget.type, adjusted);
    if (!ok || !mounted) return;
    context.push(widget.type == RoomType.vip
        ? AppConstants.vipRoomLobbyRoute
        : widget.type == RoomType.team
            ? AppConstants.teamRoomLobbyRoute
            : AppConstants.privateRoomLobbyRoute);
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
    if (widget.type == RoomType.private) {
      return const PrivateRoomJoinScreen();
    }
    if (widget.type == RoomType.vip) {
      return const VipRoomJoinScreen();
    }
    final error = ref.watch(roomFlowProvider).error;
    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: SafeArea(
          child: Column(
            children: [
              RoomHeader(
                title: widget.type == RoomType.team ? 'JOIN TEAM' : 'JOIN ROOM',
                subtitle: 'Enter the 6-digit code',
                type: widget.type,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: RoomGlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                letterSpacing: 8),
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: TextStyle(color: Colors.white24),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFFFD45C))),
                            ),
                          ),
                          const SizedBox(height: 18),
                          RoomActionButton(
                              label: 'JOIN',
                              type: widget.type,
                              onPressed: _submit),
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(error,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: Colors.redAccent)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(roomFlowProvider.notifier)
        .joinRoom(widget.type, controller.text);
    if (!ok || !mounted) return;
    context.push(widget.type == RoomType.vip
        ? AppConstants.vipRoomLobbyRoute
        : widget.type == RoomType.team
            ? AppConstants.teamRoomLobbyRoute
            : AppConstants.privateRoomLobbyRoute);
  }
}

Future<void> _join(BuildContext context, RoomType type) async {
  await context.push(type == RoomType.vip
      ? AppConstants.vipRoomJoinRoute
      : type == RoomType.team
          ? AppConstants.teamRoomJoinRoute
          : AppConstants.privateRoomJoinRoute);
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(
      {required this.mode, required this.selected, required this.onTap});
  final LudoRoomMode mode;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: (MediaQuery.sizeOf(context).width - 54) / 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF40CFFF), Color(0xFF168FD2)])
                  : null,
              color: selected ? null : Colors.white10,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? const Color(0xFFFFF0A6) : Colors.white24)),
          child: Stack(alignment: Alignment.center, children: [
            Text(mode.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
            if (selected)
              const PositionedDirectional(
                  start: 0,
                  top: -8,
                  child: Icon(Icons.check_rounded,
                      color: Color(0xFFFFD331), size: 20)),
            if (mode == LudoRoomMode.arrow)
              const PositionedDirectional(
                  end: 0,
                  top: -8,
                  child: Text('HOT',
                      style: TextStyle(
                          color: Color(0xFFFF5A3C),
                          fontSize: 9,
                          fontWeight: FontWeight.w900))),
          ]),
        ),
      );
}

class _VipBottomButton extends StatelessWidget {
  const _VipBottomButton(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
          backgroundColor:
              primary ? const Color(0xFFFFB21D) : const Color(0xFF39245E),
          foregroundColor:
              primary ? const Color(0xFF2B1235) : const Color(0xFFFFD45C),
          side: const BorderSide(color: Color(0xFFFFD45C)),
          padding: const EdgeInsets.symmetric(vertical: 13)));
}

class _LobbyButton extends StatelessWidget {
  const _LobbyButton(
      {required this.label, required this.onTap, this.enabled = true});
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: enabled
                  ? const [Color(0xFFFFFF62), Color(0xFFFFB30B)]
                  : const [Color(0xFFE0E0E0), Color(0xFF999999)],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFFFEF79), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0xFF995900), offset: Offset(0, 5)),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8B5917),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
}

class _GreenJoinButton extends StatelessWidget {
  const _GreenJoinButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 116,
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF50F3C2), Color(0xFF17B994)]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF8DFFE2)),
            boxShadow: const [
              BoxShadow(color: Color(0xFF08745F), offset: Offset(0, 4)),
            ],
          ),
          child: const Text('Join',
              style: TextStyle(
                  color: Color(0xFF176F65),
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ),
      );
}

const _headingStyle =
    TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900);
