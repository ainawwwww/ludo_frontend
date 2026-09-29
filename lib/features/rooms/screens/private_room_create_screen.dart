// lib/features/rooms/screens/private_room_create_screen.dart
//
// Create-room screen wired to the real API (Phase 5).
// On success, navigates to PrivateRoomLobbyScreen.
// Replaces the mock-backed CreateGameRoomScreen for private-room flows.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/widgets/room_widgets.dart';

class PrivateRoomCreateScreen extends ConsumerStatefulWidget {
  const PrivateRoomCreateScreen({super.key});

  @override
  ConsumerState<PrivateRoomCreateScreen> createState() =>
      _PrivateRoomCreateScreenState();
}

class _PrivateRoomCreateScreenState
    extends ConsumerState<PrivateRoomCreateScreen> {
  int _maxPlayers = 2;
  int _entryFee = 0;
  int _turnSeconds = 15;

  Future<void> _create() async {
    final myUserId = ref.read(authProvider).user?.id;
    if (myUserId == null) return;

    await ref.read(privateRoomProvider.notifier).create(
          maxPlayers: _maxPlayers,
          entryFee: _entryFee,
          turnSeconds: _turnSeconds,
          myUserId: myUserId,
        );

    if (!mounted) return;
    final state = ref.read(privateRoomProvider);
    if (state.room != null) {
      context.pushReplacement(AppConstants.privateRoomLobbyRealRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateRoomProvider);

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.private,
        child: Column(
          children: [
            RoomHeader(
              title: 'CREATE PRIVATE ROOM',
              subtitle: 'Set the table your way',
              type: RoomType.private,
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
                              onTap: () =>
                                  setState(() => _maxPlayers = v),
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
                              onTap: () =>
                                  setState(() => _turnSeconds = v),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: 'ENTRY FEE',
                    children: kAllowedEntryFees
                        .map((v) => _ChoiceChip(
                              label: v == 0 ? 'Free' : '$v',
                              selected: _entryFee == v,
                              onTap: () =>
                                  setState(() => _entryFee = v),
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
                              color:
                                  Colors.redAccent.withOpacity(0.4)),
                        ),
                        child: Text(
                          state.failure!.message,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 13),
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
                  key: const Key('btn_create_room'),
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
                    backgroundColor: const Color(0xFF2C6EF2),
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

// ---------------------------------------------------------------------------
// Internal helpers (copied from old room_entry_screens.dart pattern)

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
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2C6EF2)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2C6EF2)
                  : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight:
                  selected ? FontWeight.w900 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
}
