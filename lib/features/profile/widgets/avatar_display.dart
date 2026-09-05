import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ludo_vibe/core/utils/image_utils.dart';
import 'package:ludo_vibe/features/profile/models/profile_customization_model.dart';

class AvatarDisplay extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final double borderWidth;
  final String? avatarUrl;
  final ProfileFrameItem? frameItem;
  final ProfileOrnamentItem? ornamentItem;
  final bool showOrnament;

  const AvatarDisplay({
    super.key,
    required this.avatarIndex,
    this.size = 80,
    this.borderWidth = 3.5,
    this.avatarUrl,
    this.frameItem,
    this.ornamentItem,
    this.showOrnament = true,
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

    final effectiveFrame = frameItem ?? ProfileFrameItem.allFrames.first;
    final bool hasOrnament = showOrnament &&
        ornamentItem != null &&
        !ornamentItem!.isNone &&
        ornamentItem!.assetPath != null;

    final avatarCore = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: effectiveFrame.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveFrame.glowColor.withOpacity(0.45),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarImage(bgColors, icon, iconColor),
      ),
    );

    // If there's an equipped ornament, render it in a stack with the avatar
    if (hasOrnament) {
      final ornamentSize = size * 2.2;
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Floating Majestic Ornament in background extending wide
            Positioned(
              width: ornamentSize,
              height: ornamentSize,
              child: Opacity(
                opacity: 0.95,
                child: Image.asset(
                  ornamentItem!.assetPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            // Avatar in center
            avatarCore,
          ],
        ),
      );
    }

    return avatarCore;
  }

  Widget _buildAvatarImage(
      List<Color> bgColors, IconData icon, Color iconColor) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallback(bgColors, icon, iconColor);
    }

    final trimmed = avatarUrl!.trim();

    // 1. Asset Image (e.g. Cartoon Avatar Presets)
    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildFallback(bgColors, icon, iconColor),
      );
    }

    // 2. Web Blob or Data URL (e.g. Uploaded from Gallery/Camera on Flutter Web)
    if (kIsWeb &&
        (trimmed.startsWith('blob:') ||
            trimmed.startsWith('data:') ||
            trimmed.startsWith('http'))) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildFallback(bgColors, icon, iconColor),
      );
    }

    // 3. Local File Image on Mobile/Desktop
    if (!kIsWeb &&
        (trimmed.startsWith('/') ||
            trimmed.contains('\\') ||
            trimmed.startsWith('file://'))) {
      try {
        final cleanPath = trimmed.replaceFirst('file://', '');
        final file = File(cleanPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) =>
                _buildFallback(bgColors, icon, iconColor),
          );
        }
      } catch (_) {}
    }

    // 3. Network URL Image
    final formattedUrl = formatAvatarUrl(trimmed);
    if (formattedUrl != null &&
        formattedUrl.isNotEmpty &&
        formattedUrl.startsWith('http')) {
      return CachedNetworkImage(
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
        errorWidget: (context, url, error) =>
            _buildFallback(bgColors, icon, iconColor),
      );
    }

    return _buildFallback(bgColors, icon, iconColor);
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
