import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ludo_vibe/core/utils/image_utils.dart';

class AvatarDisplay extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final double borderWidth;
  final String? avatarUrl;

  const AvatarDisplay({
    super.key,
    required this.avatarIndex,
    this.size = 80,
    this.borderWidth = 3.5,
    this.avatarUrl,
  });

  static const List<Map<String, dynamic>> avatarStyles = [
    {
      'name': 'Golden Classic',
      'bgGradient': [Color(0xFF7E57C2), Color(0xFF512DA8)],
      'iconColor': Colors.white,
      'icon': Icons.person,
    },
    {
      'name': 'Royal Prince',
      'bgGradient': [Color(0xFF29B6F6), Color(0xFF0288D1)],
      'iconColor': Colors.white,
      'icon': Icons.face,
    },
    {
      'name': 'Neon King',
      'bgGradient': [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
      'iconColor': Colors.amberAccent,
      'icon': Icons.face_retouching_natural,
    },
    {
      'name': 'Emerald Hero',
      'bgGradient': [Color(0xFF26A69A), Color(0xFF00796B)],
      'iconColor': Colors.white,
      'icon': Icons.sentiment_very_satisfied,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final style = avatarStyles[avatarIndex % avatarStyles.length];
    final List<Color> bgColors = List<Color>.from(style['bgGradient']);
    final IconData icon = style['icon'];
    final Color iconColor = style['iconColor'];
    final formattedUrl = formatAvatarUrl(avatarUrl);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF176),
            Color(0xFFFFD54F),
            Color(0xFFFFB300),
            Color(0xFFFF8F00),
            Color(0xFFFFF59D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: formattedUrl != null && formattedUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: formattedUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: size * 0.3,
                    height: size * 0.3,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallback(bgColors, icon, iconColor),
              )
            : _buildFallback(bgColors, icon, iconColor),
      ),
    );
  }

  Widget _buildFallback(List<Color> bgColors, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: bgColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.58,
          color: iconColor,
        ),
      ),
    );
  }
}
