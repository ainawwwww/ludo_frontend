// lib/features/rooms/screens/vip_room_create_screen.dart
//
// Create VIP room screen wired to the real API via vipRoomProvider.
// On success, navigates to VipRoomLobbyScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_failure.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/vip_room_provider.dart';
import 'package:ludo_vibe/features/rooms/widgets/room_widgets.dart';

class VipRoomCreateScreen extends ConsumerStatefulWidget {
  const VipRoomCreateScreen({super.key});

  @override
  ConsumerState<VipRoomCreateScreen> createState() =>
      _VipRoomCreateScreenState();
}

class _VipRoomCreateScreenState extends ConsumerState<VipRoomCreateScreen> {
  int _maxPlayers = 2;
  int _entryFee = kVipAllowedEntryFees.first; // 1000
  int _turnSeconds = 15;

  Future<void> _create() async {
    final myUserId = ref.read(authProvider).user?.id;
    if (myUserId == null) return;

    await ref.read(vipRoomProvider.notifier).create(
          maxPlayers: _maxPlayers,
          entryFee: _entryFee,
          turnSeconds: _turnSeconds,
          myUserId: myUserId,
        );

    if (!mounted) return;
    final state = ref.read(vipRoomProvider);
    if (state.room != null) {
      context.pushReplacement(AppConstants.vipRoomLobbyRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vipRoomProvider);
    final userCoins = ref.watch(authProvider).user?.coins;

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: Column(
          children: [
            const RoomHeader(
              title: 'CREATE VIP ROOM',
              subtitle: 'Set the royal table your way',
              type: RoomType.vip,
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
                        ? 'VIP ENTRY FEE  (Balance: $userCoins)'
                        : 'VIP ENTRY FEE',
                    children: kVipAllowedEntryFees
                        .map((v) => _ChoiceChip(
                              label: '$v',
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
                            if (state.failure is RoomVipSubscriptionRequired) ...[
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                key: const Key('btn_get_vip_pass'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD369),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.workspace_premium_rounded,
                                    size: 18),
                                label: const Text(
                                  'GET VIP PASS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  context.push(AppConstants.subscriptionRoute);
                                },
                              ),
                            ],
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
                                        .read(vipRoomProvider.notifier)
                                        .restoreActiveRoom(myUserId: uid);
                                    if (context.mounted &&
                                        ref.read(vipRoomProvider).room !=
                                            null) {
                                      context.pushReplacement(
                                          AppConstants.vipRoomLobbyRoute);
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
                  key: const Key('btn_create_vip_room'),
                  onPressed: state.isLoading ? null : _create,
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white),
                  label: Text(
                    state.isLoading ? 'CREATING...' : 'CREATE VIP ROOM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
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

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFD4AF37)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFFFD45C) : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white70,
              fontWeight: selected ? FontWeight.w900 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
}
