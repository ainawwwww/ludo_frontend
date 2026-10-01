import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../game/models/ludo_board_args.dart';
import '../../game/models/room_mode.dart';
import '../models/private_room_dto.dart';
import '../models/room_models.dart';
import '../providers/private_room_provider.dart';
import '../providers/room_flow_provider.dart';
import '../providers/team_room_provider.dart';
import '../providers/vip_room_provider.dart';
import '../widgets/room_widgets.dart';

class RoomLobbyScreen extends ConsumerStatefulWidget {
  const RoomLobbyScreen({super.key, required this.type});
  final RoomType type;

  @override
  ConsumerState<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends ConsumerState<RoomLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final myUserId = ref.watch(authProvider).user?.id ?? 0;

    // Listen for navigation events from backend WebSocket (Private & VIP)
    if (widget.type == RoomType.private) {
      ref.listen<PrivateRoomState>(privateRoomProvider, (prev, next) {
        if (next.navEvent == PrivateRoomNavEvent.goToGame) {
          final room = next.room;
          if (room != null) {
            ref.read(privateRoomProvider.notifier).consumeNavEvent();
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
        } else if (next.navEvent == PrivateRoomNavEvent.goHome) {
          ref.read(privateRoomProvider.notifier).consumeNavEvent();
          if (mounted) context.go(AppConstants.homeRoute);
        }
      });
    } else if (widget.type == RoomType.vip) {
      ref.listen<PrivateRoomState>(vipRoomProvider, (prev, next) {
        if (next.navEvent == PrivateRoomNavEvent.goToGame) {
          final room = next.room;
          if (room != null) {
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
        } else if (next.navEvent == PrivateRoomNavEvent.goHome) {
          ref.read(vipRoomProvider.notifier).consumeNavEvent();
          if (mounted) context.go(AppConstants.homeRoute);
        }
      });
    } else if (widget.type == RoomType.team) {
      ref.listen<TeamRoomState>(teamRoomProvider, (prev, next) {
        if (next.navEvent == TeamRoomNavEvent.goToMatchmaking) {
          ref.read(teamRoomProvider.notifier).consumeNavEvent();
          context.push(
            AppConstants.teamVsRoute,
            extra: {
              'isSingle': false,
              'entryFee': next.room?.entryFee ?? 500,
            },
          );
        } else if (next.navEvent == TeamRoomNavEvent.goToGame) {
          ref.read(teamRoomProvider.notifier).consumeNavEvent();
          context.push(
            AppConstants.ludoBoardRoute,
            extra: LudoBoardArgs(
              players: 4,
              bet: next.room?.entryFee ?? 500,
              roomId: next.room?.id,
              gameId: next.matchData?['game_id'] as int?,
              isOnline: true,
              roomMode: RoomMode.team,
              roomCode: next.room?.roomCode,
              turnSeconds: next.room?.turnSeconds ?? 15,
            ),
          );
        } else if (next.navEvent == TeamRoomNavEvent.goHome) {
          ref.read(teamRoomProvider.notifier).consumeNavEvent();
          if (mounted) context.go(AppConstants.homeRoute);
        }
      });
    }

    RoomSession? session;
    bool isLoading = false;

    if (widget.type == RoomType.private) {
      final pState = ref.watch(privateRoomProvider);
      isLoading = pState.isLoading;
      session = pState.room?.toRoomSession(
        currentUserId: pState.myUserId ?? myUserId,
        roomType: RoomType.private,
      );
    } else if (widget.type == RoomType.vip) {
      final vState = ref.watch(vipRoomProvider);
      isLoading = vState.isLoading;
      session = vState.room?.toRoomSession(
        currentUserId: vState.myUserId ?? myUserId,
        roomType: RoomType.vip,
      );
    } else if (widget.type == RoomType.team) {
      final tState = ref.watch(teamRoomProvider);
      isLoading = tState.isLoading;
      session = tState.room?.toRoomSession(
        currentUserId: tState.myUserId ?? myUserId,
        roomType: RoomType.team,
      );
    } else {
      final flow = ref.watch(roomFlowProvider);
      isLoading = flow.isLoading;
      session = flow.session;
    }

    if (session == null) {
      return Scaffold(
        body: RoomBackdrop(
          type: widget.type,
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : RoomActionButton(
                    label: 'BACK TO HOME',
                    type: widget.type,
                    onPressed: () => context.go(AppConstants.homeRoute),
                  ),
          ),
        ),
      );
    }
    final activeSession = session;

    final isTeam = widget.type == RoomType.team;
    final seats = isTeam ? 2 : activeSession.settings.maxPlayers;
    final isHost = activeSession.isHost;

    final myParticipant = activeSession.participants
        .where((p) => p.id == myUserId.toString() || (p.id == 'me'))
        .firstOrNull;
    final isReady = myParticipant?.ready ?? false;

    return Scaffold(
      body: RoomBackdrop(
        type: widget.type,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            return Stack(children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 18, 16, isTeam ? 112 : 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (isTeam ? 130 : 36)),
                  child: Column(children: [
                    Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: _CloseButton(onTap: () async {
                          if (widget.type == RoomType.private) {
                            await ref.read(privateRoomProvider.notifier).leave();
                            if (context.mounted) context.go(AppConstants.homeRoute);
                          } else if (widget.type == RoomType.vip) {
                            await ref.read(vipRoomProvider.notifier).leave();
                            if (context.mounted) context.go(AppConstants.homeRoute);
                          } else if (widget.type == RoomType.team) {
                            await ref.read(teamRoomProvider.notifier).leave();
                            if (context.mounted) context.go(AppConstants.homeRoute);
                          } else {
                            ref.read(roomFlowProvider.notifier).leaveRoom();
                            context.pop();
                          }
                        })),
                    Text(
                        isTeam
                            ? 'TEAM'
                            : (widget.type == RoomType.vip ? 'VIP ROOM' : 'PRIVATE'),
                        style: const TextStyle(
                            color: Color(0xFFFFC928),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                  color: Color(0xFF572600),
                                  offset: Offset(0, 3),
                                  blurRadius: 2)
                            ])),
                    SizedBox(height: compact ? 8 : 18),
                    Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Text('Room ID:',
                              style: TextStyle(
                                  color: Color(0xFFFFD12A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900)),
                          InkWell(
                              onTap: () => _copy(
                                  context, activeSession.code, 'Room ID copied'),
                              child: Text(activeSession.code,
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900))),
                          _SquareIcon(
                              icon: Icons.share_rounded,
                              onTap: () => _share(activeSession.code, isTeam)),
                        ]),
                    const SizedBox(height: 18),
                    Text(
                        isTeam
                            ? 'Invite one teammate to join your team'
                            : 'Share this room ID with friends and\ninvite them',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            height: 1.25,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: compact ? 20 : 38),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(seats, (index) {
                        final participant = activeSession.participants
                            .where((p) => p.seat == index + 1)
                            .firstOrNull;
                        return Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(
                              top: index.isOdd ? 30 : 0, left: 3, right: 3),
                          child: _RibbonSeat(
                              participant: participant,
                              onInvite: () => _share(activeSession.code, isTeam)),
                        ));
                      }),
                    ),
                    SizedBox(height: compact ? 20 : 34),
                    Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                              icon: Icons.sports_esports_rounded,
                              text: activeSession.settings.mode.label),
                          _InfoChip(
                              icon: Icons.auto_awesome_rounded,
                              text: activeSession.settings.magicDice
                                  ? 'Magic On'
                                  : 'Magic Off'),
                          _InfoChip(
                              icon: Icons.monetization_on_rounded,
                              text: '${activeSession.settings.entryFee}'),
                        ]),
                    const SizedBox(height: 14),
                    SizedBox(
                        width: 250,
                        child: _GlossyButton(
                          label: isHost
                              ? (activeSession.canStart ? 'Start' : 'Waiting')
                              : (isReady ? 'Ready' : 'Ready Up'),
                          enabled: isHost ? activeSession.canStart : true,
                          onTap: () async {
                            if (widget.type == RoomType.private) {
                              if (isHost) {
                                if (activeSession.canStart) {
                                  await ref
                                      .read(privateRoomProvider.notifier)
                                      .startMatch();
                                }
                              } else {
                                await ref
                                    .read(privateRoomProvider.notifier)
                                    .setReady(isReady: !isReady);
                              }
                              return;
                            }
                            if (widget.type == RoomType.vip) {
                              if (isHost) {
                                if (activeSession.canStart) {
                                  await ref
                                      .read(vipRoomProvider.notifier)
                                      .startMatch();
                                }
                              } else {
                                await ref
                                    .read(vipRoomProvider.notifier)
                                    .setReady(isReady: !isReady);
                              }
                              return;
                            }
                            if (widget.type == RoomType.team) {
                              if (isHost) {
                                if (activeSession.canStart) {
                                  await ref
                                      .read(teamRoomProvider.notifier)
                                      .startMatchmaking();
                                }
                              } else {
                                await ref
                                    .read(teamRoomProvider.notifier)
                                    .setReady(isReady: !isReady);
                              }
                              return;
                            }

                            if (!activeSession.isHost) {
                              ref.read(roomFlowProvider.notifier).toggleReady();
                              return;
                            }
                            if (!activeSession.canStart) return;
                            if (isTeam) {
                              context.push(AppConstants.teamVsRoute);
                              return;
                            }
                            context.push(AppConstants.ludoBoardRoute, extra: {
                              'players': activeSession.settings.maxPlayers,
                              'bet': activeSession.settings.entryFee,
                              'room_id': activeSession.id,
                              'isOnline': false,
                              'roomMode': activeSession.settings.mode.name,
                              'roomCode': activeSession.code
                            });
                          },
                        )),
                  ]),
                ),
              ),
              if (isTeam)
                PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                      color: const Color(0xCC123C6B),
                      child: Row(children: [
                        Expanded(
                            child: Text('Team Code: ${activeSession.code}',
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900))),
                        IconButton(
                            onPressed: () => _copy(
                                context, activeSession.code, 'Team code copied'),
                            icon: const Icon(Icons.copy_rounded,
                                color: Color(0xFFFFD45C))),
                        IconButton(
                            onPressed: () => _share(activeSession.code, true),
                            icon: const Icon(Icons.share_rounded,
                                color: Color(0xFFFFD45C))),
                      ]),
                    )),
            ]);
          }),
        ),
      ),
    );
  }

  static Future<void> _share(String code, bool team) => Share.share(
      '${team ? 'Join my LudoVibe team' : 'Join my private Ludo room'} with code $code');
  static Future<void> _copy(
      BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RibbonSeat extends StatelessWidget {
  const _RibbonSeat({required this.participant, required this.onInvite});
  final RoomParticipant? participant;
  final VoidCallback onInvite;
  @override
  Widget build(BuildContext context) {
    final occupied = participant != null;
    return InkWell(
      onTap: occupied ? null : onInvite,
      borderRadius: BorderRadius.circular(22),
      child: Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF244A86),
              border: Border.all(
                  color: occupied
                      ? const Color(0xFF48EE8B)
                      : const Color(0xFFFFBE19),
                  width: 5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 7, offset: Offset(0, 4))
              ]),
          child: Icon(occupied ? Icons.person_rounded : Icons.add_rounded,
              color: occupied ? Colors.white70 : const Color(0xFFB9D7FF),
              size: 49),
        ),
        Transform.translate(
            offset: const Offset(0, -7),
            child: ClipPath(
              clipper: _RibbonClipper(),
              child: Container(
                width: double.infinity,
                height: 78,
                padding: const EdgeInsets.fromLTRB(5, 22, 5, 8),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2DBBE8), Color(0xFF167AB5)])),
                child: Column(children: [
                  Text(occupied ? participant!.name : 'Invite',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          color:
                              occupied ? const Color(0xFFFFFF53) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                  if (occupied)
                    Text(participant!.ready ? 'Ready' : 'Not ready',
                        style: TextStyle(
                            color: participant!.ready
                                ? const Color(0xFF85F6FF)
                                : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                ]),
              ),
            )),
      ]),
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(0, 0)
    ..lineTo(s.width, 0)
    ..lineTo(s.width, s.height - 12)
    ..lineTo(s.width * .75, s.height - 7)
    ..lineTo(s.width * .5, s.height)
    ..lineTo(s.width * .25, s.height - 7)
    ..lineTo(0, s.height - 12)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
          color: const Color(0xCC14557C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF58B8DE))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFFFD45C), size: 16),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))
      ]));
}

class _SquareIcon extends StatelessWidget {
  const _SquareIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFF337DB2),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFF7EDCFF))),
          child: Icon(icon, color: Colors.white, size: 23)));
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
          width: 58,
          height: 46,
          decoration: BoxDecoration(
              color: const Color(0xFFC94128),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFB42C), width: 3)),
          child: const Icon(Icons.close_rounded,
              color: Color(0xFFFFE56D), size: 34)));
}

class _GlossyButton extends StatelessWidget {
  const _GlossyButton(
      {required this.label, required this.enabled, required this.onTap});
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: enabled
                    ? const [Color(0xFFFFFF5E), Color(0xFFFFB20D)]
                    : const [Color(0xFFE1E1E1), Color(0xFF9B9B9B)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color:
                    enabled ? const Color(0xFFFFF38E) : const Color(0xFFD9D9D9),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: enabled
                      ? const Color(0xFF9D5C00)
                      : const Color(0xFF656565),
                  offset: const Offset(0, 5))
            ]),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color:
                    enabled ? const Color(0xFF8B5917) : const Color(0xFF777777),
                fontSize: 23,
                fontWeight: FontWeight.w900)),
      ));
}
