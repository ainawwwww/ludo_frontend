import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/room_models.dart';
import '../providers/room_flow_provider.dart';
import '../widgets/room_widgets.dart';

class VipVoiceLoungeScreen extends ConsumerStatefulWidget {
  const VipVoiceLoungeScreen({super.key});

  @override
  ConsumerState<VipVoiceLoungeScreen> createState() =>
      _VipVoiceLoungeScreenState();
}

class _VipVoiceLoungeScreenState extends ConsumerState<VipVoiceLoungeScreen> {
  final messageController = TextEditingController();
  final messages = <String>[
    'Royal Host: Welcome to the lounge!',
    'Sara: Ready for a great match?',
  ];
  bool muted = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void send() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add('You: $text');
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(roomFlowProvider).session;
    return Scaffold(
      body: RoomBackdrop(
        type: RoomType.vip,
        child: Column(
          children: [
            RoomHeader(
              title: 'VIP VOICE LOUNGE',
              subtitle: session == null
                  ? 'Premium live room'
                  : 'Room ${session.code}',
              type: RoomType.vip,
              trailing: IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite link copied')),
                ),
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: .82,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final occupied = index < (session?.participants.length ?? 2);
                  final speaking = index == 0;
                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                          border: Border.all(
                            color: speaking
                                ? const Color(0xFF70F59A)
                                : const Color(0xFFFFD45C),
                            width: speaking ? 3 : 1.5,
                          ),
                          boxShadow: speaking
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF70F59A,
                                    ).withValues(alpha: .4),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          occupied ? Icons.person_rounded : Icons.add_rounded,
                          color: occupied ? Colors.white : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occupied
                            ? (index == 0 ? 'Host' : 'Guest $index')
                            : 'Seat ${index + 1}',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: RoomGlassCard(
                padding: const EdgeInsets.all(12),
                child: ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12),
                  itemBuilder: (_, index) => Text(
                    messages[index],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => muted = !muted),
                    icon: Icon(
                      muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: muted ? Colors.redAccent : const Color(0xFF70F59A),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onSubmitted: (_) => send(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message the lounge...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: send,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFFFFD45C),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    tooltip: 'Back to lobby',
                    icon: const Icon(
                      Icons.sports_esports_rounded,
                      color: Colors.white,
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
