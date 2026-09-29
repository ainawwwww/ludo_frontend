import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../widgets/room_widgets.dart';

class TeamVsScreen extends ConsumerWidget {
  const TeamVsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(roomFlowProvider).session;
    final entry = session?.settings.entryFee ?? 500;
    final reward = entry * 2 - (entry ~/ 10);
    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.team,
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final scale = (constraints.maxWidth / AppConstants.designWidth)
                .clamp(.82, 1.25);
            return SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 10),
              child: Column(children: [
                Image.asset('assets/graphics/rooms/generated/vs_badge.png',
                    width: 190 * scale,
                    height: 145 * scale,
                    fit: BoxFit.contain),
                SizedBox(height: 6 * scale),
                Container(
                  height: 82 * scale,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xFF0E4F8A),
                        Color(0xFF218CC2),
                        Color(0xFF0E4F8A)
                      ]),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Image.asset(
                        'assets/graphics/rooms/generated/coin_podium.png',
                        width: 120 * scale,
                        fit: BoxFit.contain),
                    Expanded(
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('RANK 1   $reward',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24 * scale,
                                    fontWeight: FontWeight.w900)))),
                  ]),
                ),
                SizedBox(height: 14 * scale),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Entry Coins  ',
                      style: TextStyle(
                          color: const Color(0xFFFFD33D),
                          fontSize: 21 * scale,
                          fontWeight: FontWeight.w900)),
                  TextSpan(
                      text: '$entry',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 21 * scale,
                          fontWeight: FontWeight.w900)),
                ])),
                SizedBox(height: 18 * scale),
                SizedBox(
                  height: 390 * scale,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _TeamFlag(
                                asset:
                                    'assets/graphics/rooms/generated/red_team_banner.png',
                                players: [
                              session?.participants.firstOrNull?.name ?? 'You',
                              'Teammate'
                            ])),
                        const SizedBox(width: 4),
                        Expanded(
                            child: _TeamFlag(
                                asset:
                                    'assets/graphics/rooms/generated/blue_team_banner.png',
                                players: const ['Rival One', 'Rival Two'])),
                      ]),
                ),
              ]),
            );
          }),
        ),
      ),
    );
  }
}

class _TeamFlag extends StatelessWidget {
  const _TeamFlag({required this.asset, required this.players});
  final String asset;
  final List<String> players;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        Image.asset(asset, fit: BoxFit.fill),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 82, 28, 52),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Player(name: players[0]),
                _Player(name: players[1]),
              ]),
        ),
      ]);
}

class _Player extends StatelessWidget {
  const _Player({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black54, blurRadius: 2)])),
        const SizedBox(height: 5),
        Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8E8E8),
                border: Border.all(color: const Color(0xFF57ED8A), width: 4)),
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF8D8D8D), size: 42)),
      ]);
}
