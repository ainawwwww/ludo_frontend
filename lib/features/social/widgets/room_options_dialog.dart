import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/social/providers/chat_flow_provider.dart';
import 'package:share_plus/share_plus.dart';

class RoomOptionsDialog extends ConsumerWidget {
  final String roomTitle;
  final String roomCode;
  final String hostName;
  final VoidCallback onLeaveRoom;

  const RoomOptionsDialog({
    super.key,
    required this.roomTitle,
    required this.roomCode,
    required this.hostName,
    required this.onLeaveRoom,
  });

  static void show(
    BuildContext context, {
    required String roomTitle,
    required String roomCode,
    required String hostName,
    required VoidCallback onLeaveRoom,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoomOptionsDialog(
        roomTitle: roomTitle,
        roomCode: roomCode,
        hostName: hostName,
        onLeaveRoom: onLeaveRoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final isFollowing = ref.watch(chatFlowProvider).followedHosts.contains(hostName);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF150D48),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
        border: Border(
          top: BorderSide(color: const Color(0xFF8E2DE2).withOpacity(0.5), width: 1.5 * scale),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36 * scale,
              height: 4 * scale,
              margin: EdgeInsets.only(bottom: 14 * scale),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),

            // Room Title & Code
            Text(
              roomTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Code: $roomCode',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    color: const Color(0xFFB173FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8 * scale),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: roomCode));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room code $roomCode copied to clipboard!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(Icons.copy_rounded, color: const Color(0xFFFFD200), size: 14 * scale),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),

            // Follow Host Button
            ListTile(
              leading: Icon(
                isFollowing ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFF3366),
                size: 24 * scale,
              ),
              title: Text(
                isFollowing ? 'Following Host ($hostName)' : 'Follow Host ($hostName)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.white12 : const Color(0xFFFF3366).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: isFollowing ? Colors.white24 : const Color(0xFFFF3366),
                    width: 1 * scale,
                  ),
                ),
                child: Text(
                  isFollowing ? 'Unfollow' : '+ Follow',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.bold,
                    color: isFollowing ? Colors.white70 : const Color(0xFFFF3366),
                  ),
                ),
              ),
              onTap: () {
                ref.read(chatFlowProvider.notifier).toggleFollowHost(hostName);
              },
            ),
            Divider(color: Colors.white10, height: 1 * scale),

            // Share Room Link
            ListTile(
              leading: Icon(Icons.share_rounded, color: const Color(0xFF00D2FF), size: 24 * scale),
              title: Text(
                'Share Room Link',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'Join my live Ludo room "$roomTitle" on LudoVibe! Room Code: $roomCode\nLet\'s play and chat together!',
                );
              },
            ),
            Divider(color: Colors.white10, height: 1 * scale),

            // Leave Room Button
            ListTile(
              leading: Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 24 * scale),
              title: Text(
                'Leave Room',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onLeaveRoom();
              },
            ),
            SizedBox(height: 8 * scale),
          ],
        ),
      ),
    );
  }
}
