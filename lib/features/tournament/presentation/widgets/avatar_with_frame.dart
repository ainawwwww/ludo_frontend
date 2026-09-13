import 'package:flutter/material.dart';

class AvatarWithFrame extends StatelessWidget {
  final String? avatarUrl;
  final String? assetPath;
  final double size;
  final bool isOpponent;

  const AvatarWithFrame({
    super.key,
    this.avatarUrl,
    this.assetPath,
    this.size = 80,
    this.isOpponent = false,
  });

  @override
  Widget build(BuildContext context) {
    final innerSize = size * 0.76;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Avatar Image
          ClipOval(
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: _buildAvatarImage(),
            ),
          ),

          // Gold Ornamental Ring Frame Overlaid
          Image.asset(
            'assets/images/tournament/avatar_frame_gold.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(assetPath!, fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      'assets/images/tournament/player_placeholder_avatar.png',
      fit: BoxFit.cover,
    );
  }
}
