// lib/features/rooms/screens/private_room_join_screen.dart
//
// Join-room screen wired to the real API (Phase 5).
// Input: 6-char alphanumeric code (uppercase, no ambiguous chars).
// On success, navigates to PrivateRoomLobbyScreen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/auth/providers/auth_provider.dart';
import 'package:ludo_vibe/features/rooms/models/private_room_dto.dart';
import 'package:ludo_vibe/features/rooms/models/room_models.dart';
import 'package:ludo_vibe/features/rooms/providers/private_room_provider.dart';
import 'package:ludo_vibe/features/rooms/widgets/room_widgets.dart';

class PrivateRoomJoinScreen extends ConsumerStatefulWidget {
  const PrivateRoomJoinScreen({super.key});

  @override
  ConsumerState<PrivateRoomJoinScreen> createState() =>
      _PrivateRoomJoinScreenState();
}

class _PrivateRoomJoinScreenState
    extends ConsumerState<PrivateRoomJoinScreen> {
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

    await ref
        .read(privateRoomProvider.notifier)
        .join(code, myUserId: myUserId);

    if (!mounted) return;
    final state = ref.read(privateRoomProvider);
    if (state.room != null) {
      context.pushReplacement(AppConstants.privateRoomLobbyRoute);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    final cleaned = text.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length >= 6) {
      _controller.text = cleaned.substring(0, 6);
      _join();
    } else if (cleaned.isNotEmpty) {
      _controller.text = cleaned;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateRoomProvider);
    final errorText = _localError ?? state.failure?.message;

    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.private,
        child: Column(
          children: [
            RoomHeader(
              title: 'JOIN PRIVATE ROOM',
              subtitle: 'Enter the code shared by the host',
              type: RoomType.private,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.dialpad_rounded,
                        color: Color(0xFF5FE8FF), size: 64),
                    const SizedBox(height: 28),
                    // Code input
                    TextField(
                      key: const Key('input_room_code'),
                      controller: _controller,
                      focusNode: _focus,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      // Allow only room-code alphabet
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
                        hintStyle:
                            const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                              color: Color(0xFF5FE8FF), width: 2),
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
                          ref
                              .read(privateRoomProvider.notifier)
                              .clearFailure();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: const Key('btn_paste_code'),
                        onPressed: state.isLoading ? null : _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste_rounded,
                            size: 16, color: Color(0xFF5FE8FF)),
                        label: const Text(
                          'Paste from Clipboard',
                          style: TextStyle(
                            color: Color(0xFF5FE8FF),
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
                        key: const Key('btn_join_room'),
                        onPressed: state.isLoading ? null : _join,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2),
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
                          backgroundColor: const Color(0xFF2C6EF2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
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

/// Auto-uppercase formatter for room codes.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
